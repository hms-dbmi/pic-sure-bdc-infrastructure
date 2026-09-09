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
    --dataset_s3_object_key)
       dataset_s3_object_key="$2"
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

# Migration fallback. These config objects moved from a stack-independent key to a per-stack one.
# Prefer the per-stack object, accept the pre-migration one while the copy is outstanding, and
# stop with instructions when neither exists. Writes always target the per-stack key, so the
# fallback retires itself once the object has been copied.
s3_object_exists() {
  sudo /usr/bin/aws --region us-east-1 s3api head-object \
    --bucket "$stack_s3_bucket" --key "$1" >/dev/null 2>&1
}

s3_copy_stack_or_legacy() {
  local stack_key=$1
  local legacy_key=$2
  local destination=$3
  shift 3

  if s3_object_exists "$stack_key"; then
    s3_copy "s3://${stack_s3_bucket}/${stack_key}" "$destination"
    return 0
  fi

  if s3_object_exists "$legacy_key"; then
    echo "WARNING: s3://${stack_s3_bucket}/${stack_key} is missing; using s3://${stack_s3_bucket}/${legacy_key} instead." >&2
    echo "WARNING: that object has no stack segment, so every stack reads it. Copy it to the per-stack key to finish the migration." >&2
    s3_copy "s3://${stack_s3_bucket}/${legacy_key}" "$destination"
    return 0
  fi

  echo "ERROR: no configuration file found for stack ${target_stack}." >&2
  echo "ERROR:   looked for s3://${stack_s3_bucket}/${stack_key}" >&2
  echo "ERROR:   and        s3://${stack_s3_bucket}/${legacy_key}" >&2
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

s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/pic-sure-frontend.tar.gz" "/opt/picsure/pic-sure-frontend.tar.gz"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/configs/httpd/httpd-vhosts.conf" "/usr/local/docker-config/httpd-vhosts.conf"
s3_copy_stack_or_legacy \
  "configs/pic-sure-frontend/${target_stack}/bdc.env" \
  "configs/pic-sure-frontend/bdc.env" \
  "/opt/picsure/bdc.env" \
  "1. Get a starting file: run 'Download PIC-SURE-Frontend Configuration' against a stack that" \
  "   has one, or copy PIC-SURE-Frontend/.env.example from the frontend repository." \
  "2. Set LOGGING_API_KEY to the value in this stack's rendered" \
  "   configs/pic-sure-logging/${target_stack}/logging.env. A mismatch is not fatal to the" \
  "   frontend, but pic-sure-logging answers its audit events with 401 and they are dropped." \
  "3. Upload it with 'Upload PIC-SURE-Frontend Configuration', TARGET_STACK=${target_stack}." \
  "   bdc.env is per stack; configuration.json on that job is shared and does not need changing."
s3_copy "s3://${stack_s3_bucket}/certs/httpd/" "/usr/local/docker-config/cert/" --recursive

CONTAINER_NAME=httpd
podman rm -f httpd || true
podman system prune -a -f || true

chmod o+rx /usr/local/docker-config
chmod o+rx /usr/local/docker-config/cert
chmod o+rx /opt/picsure

find /opt/picsure -type f ! -name ".*" -exec chmod 644 {} \;
find /usr/local/docker-config -type f ! -name ".*" -exec chmod 644 {} \;
find /usr/local/docker-config/cert -type f ! -name "*.key" -exec chmod 644 {} \;
find /usr/local/docker-config/cert -type f -name "*.key" -exec chmod 600 {} \;

HTTPD_IMAGE=$(podman load < /opt/picsure/pic-sure-frontend.tar.gz | cut -d ' ' -f 3)

# Stop and remove any existing container and systemd service.
sudo systemctl stop container-$CONTAINER_NAME.service 2>/dev/null || true
podman rm -f $CONTAINER_NAME || true

# Create the container without starting it — systemd will handle startup.
podman create --privileged -u root --name=$CONTAINER_NAME \
--log-opt tag=$CONTAINER_NAME \
--env-file /opt/picsure/bdc.env \
-v /var/log/picsure/httpd/:/usr/local/apache2/logs/:Z \
-v /usr/local/docker-config/cert:/usr/local/apache2/cert/:Z \
-v /usr/local/docker-config/httpd-vhosts.conf:/usr/local/apache2/conf/extra/httpd-vhosts.conf:Z \
-p 443:443 "$HTTPD_IMAGE"

# systemd setup.
podman generate systemd --name $CONTAINER_NAME --restart-policy=always --files
sudo mv container-$CONTAINER_NAME.service /etc/systemd/system/
sudo restorecon -v /etc/systemd/system/container-$CONTAINER_NAME.service

sudo systemctl daemon-reload
sudo systemctl enable container-$CONTAINER_NAME.service
sudo systemctl start --no-block container-$CONTAINER_NAME.service

echo "Verifying container-$CONTAINER_NAME.service status..."
sudo systemctl is-enabled container-$CONTAINER_NAME.service
# Status check is informational — Jenkins log polling verifies actual startup.
sudo systemctl status container-$CONTAINER_NAME.service --no-pager || true

# Give systemd a moment to start the container, then fail the script if it is
# not running, so Jenkins reports the real error.
sleep 10
if ! podman ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "ERROR: Container '$CONTAINER_NAME' is not running after startup."
  echo "--- Full container inspect ---"
  podman inspect $CONTAINER_NAME 2>&1 || true
  exit 1
fi
