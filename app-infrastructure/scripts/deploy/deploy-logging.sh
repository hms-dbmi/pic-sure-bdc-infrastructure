#!/bin/bash
set -euo pipefail

while [[ $# -gt 0 ]]; do
  case $1 in
    --stack_s3_bucket)
      stack_s3_bucket="$2"
      shift 2
      ;;
    --target_stack)
      target_stack="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Source /etc/environment for fallback values (set during initial provisioning)
if [[ -f /etc/environment ]]; then
  set -a
  source /etc/environment
  set +a
fi

stack_s3_bucket=${stack_s3_bucket:-${STACK_S3_BUCKET:-}}
target_stack=${target_stack:-${TARGET_STACK:-}}

if [[ -z "$stack_s3_bucket" || -z "$target_stack" ]]; then
  echo "Error: --stack_s3_bucket and --target_stack are required."
  exit 1
fi

# Fail closed: if all attempts fail, abort the deploy rather than continuing
# with whatever stale file is already on disk.
s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && return 0
    sleep 30
  done
  echo "ERROR: aws s3 cp failed after 5 attempts: $*" >&2
  exit 1
}

# Migration fallback. logging.env moved from a per-stack key back to one stackless key, because a
# single LOGGING_API_KEY now serves every stack. Prefer the shared object, accept this stack's
# per-stack object until the Render job has written the shared one, and stop with instructions
# when neither exists.
s3_object_exists() {
  sudo /usr/bin/aws --region us-east-1 s3api head-object \
    --bucket "$stack_s3_bucket" --key "$1" >/dev/null 2>&1
}

s3_copy_shared_or_stack() {
  local shared_key=$1
  local stack_key=$2
  local destination=$3
  shift 3

  if s3_object_exists "$shared_key"; then
    s3_copy "s3://${stack_s3_bucket}/${shared_key}" "$destination"
    return 0
  fi

  if s3_object_exists "$stack_key"; then
    echo "WARNING: s3://${stack_s3_bucket}/${shared_key} is missing; using s3://${stack_s3_bucket}/${stack_key} instead." >&2
    echo "WARNING: run 'Render PIC-SURE Configuration' with RENDER_LOGGING to write the shared object every stack reads." >&2
    s3_copy "s3://${stack_s3_bucket}/${stack_key}" "$destination"
    return 0
  fi

  echo "ERROR: no configuration file found for stack ${target_stack}." >&2
  echo "ERROR:   looked for s3://${stack_s3_bucket}/${shared_key}" >&2
  echo "ERROR:   and        s3://${stack_s3_bucket}/${stack_key}" >&2
  echo "ERROR:" >&2
  echo "ERROR: A container started without it would come up misconfigured, so this deploy stops here." >&2
  echo "ERROR: To fix it:" >&2
  local step
  for step in "$@"; do
    echo "ERROR:   ${step}" >&2
  done
  echo "ERROR:" >&2
  echo "ERROR: Then re-run this deploy. If you believe the object does exist, check that the" >&2
  echo "ERROR: instance role grants s3:GetObject on both keys above; a denied read looks identical" >&2
  echo "ERROR: to a missing object here." >&2
  exit 1
}

s3_copy_shared_or_stack \
  "configs/pic-sure-logging/logging.env" \
  "configs/pic-sure-logging/${target_stack}/logging.env" \
  "/opt/picsure/logging.env" \
  "1. In Jenkins, run 'Render PIC-SURE Configuration' with TARGET_STACK=${target_stack} and" \
  "   RENDER_LOGGING, RENDER_GATEWAY, RENDER_OPERATIONS, RENDER_VISUALIZATION and" \
  "   RENDER_DICTIONARY all true. On a first render it mints the shared LOGGING_API_KEY and" \
  "   writes configs/pic-sure-logging/logging.env; the consumers must render together so they" \
  "   agree on the key." \
  "2. Re-upload psama.env through 'Upload PSAMA Configuration', which adds the key, then redeploy" \
  "   pic-sure-logging, gateway, operations, visualization, dictionary-api and psama." \
  "3. Put the same key in configs/pic-sure-frontend/${target_stack}/bdc.env via 'Upload" \
  "   PIC-SURE-Frontend Configuration' and redeploy the frontend, or its audit events are" \
  "   answered with 401 and dropped."

s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/pic-sure-logging.tar.gz" "/opt/picsure/pic-sure-logging.tar.gz"

LOGGING_IMAGE=$(podman load < /opt/picsure/pic-sure-logging.tar.gz | cut -d ' ' -f 3)
CONTAINER_NAME=pic-sure-logging

podman rm -f $CONTAINER_NAME || true
podman run --privileged --name=$CONTAINER_NAME \
      --dns=10.89.0.1 \
      --env-file /opt/picsure/logging.env \
      -e LOG_DIR=/app/logs \
      -v /var/log/picsure/logging/:/app/logs \
      --network picsure \
      --log-opt tag=$CONTAINER_NAME \
      -d "$LOGGING_IMAGE"

# systemd setup.
podman generate systemd --name $CONTAINER_NAME --restart-policy=always --files
sudo mv container-$CONTAINER_NAME.service /etc/systemd/system/
sudo restorecon -v /etc/systemd/system/container-$CONTAINER_NAME.service

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable container-$CONTAINER_NAME.service
sudo systemctl restart container-$CONTAINER_NAME.service

echo "Verifying container-$CONTAINER_NAME.service status..."
sudo systemctl is-enabled container-$CONTAINER_NAME.service
sudo systemctl status container-$CONTAINER_NAME.service --no-pager || true

# Fail the script if the container is not running, so Jenkins reports the real error.
if ! podman ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "ERROR: Container '$CONTAINER_NAME' is not running after startup."
  echo "--- Full container inspect ---"
  podman inspect $CONTAINER_NAME 2>&1 || true
  exit 1
fi
