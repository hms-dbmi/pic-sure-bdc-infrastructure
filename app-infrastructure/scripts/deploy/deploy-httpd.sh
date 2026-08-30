#!/bin/bash
set -euo pipefail

artifact_etag=""

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
    --artifact_prefix)
       artifact_prefix="$2"
       shift 2
       ;;
    --artifact_etag)
       artifact_etag="$2"
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
artifact_prefix=${artifact_prefix:-${target_stack}/containers}

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

s3_get_exact() {
  local bucket="$1"
  local key="$2"
  local etag="$3"
  local destination="$4"
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3api get-object \
      --bucket "$bucket" \
      --key "$key" \
      --if-match "$etag" \
      "$destination" >/dev/null && return 0
    sleep 30
  done
  echo "ERROR: exact S3 artifact download failed after 5 attempts: s3://${bucket}/${key}" >&2
  exit 1
}

if [[ "$artifact_prefix" == "${target_stack}/banner-rollout/"* ]]; then
  [[ -n "$artifact_etag" ]] || { echo "ERROR: banner frontend deploy requires the verified artifact ETag." >&2; exit 2; }
  s3_get_exact "$stack_s3_bucket" "$artifact_prefix/pic-sure-frontend.tar.gz" "$artifact_etag" "/opt/picsure/pic-sure-frontend.tar.gz"
else
  s3_copy "s3://${stack_s3_bucket}/${artifact_prefix}/pic-sure-frontend.tar.gz" "/opt/picsure/pic-sure-frontend.tar.gz"
fi
s3_copy "s3://${stack_s3_bucket}/${target_stack}/configs/httpd/httpd-vhosts.conf" "/usr/local/docker-config/httpd-vhosts.conf"
s3_copy "s3://${stack_s3_bucket}/configs/pic-sure-frontend/bdc.env" "/opt/picsure/bdc.env"
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
