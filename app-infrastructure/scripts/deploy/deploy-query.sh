#!/bin/bash

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

stack_s3_bucket=${stack_s3_bucket:-$STACK_S3_BUCKET}
target_stack=${target_stack:-$TARGET_STACK}

if [[ -z "$stack_s3_bucket" || -z "$target_stack" ]]; then
  echo "Error: --stack_s3_bucket and --target_stack are required."
  exit 1
fi

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/configs/query/${target_stack}/query.env" "/opt/picsure/query.env"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/pic-sure-hpds-query-service.tar.gz" "/opt/picsure/pic-sure-hpds-query-service.tar.gz"

CONTAINER_NAME="pic-sure-hpds-query-service"
QUERY_IMAGE=$(podman load < /opt/picsure/pic-sure-hpds-query-service.tar.gz | cut -d ' ' -f 3)
JAVA_OPTS="-Xms1g -Xmx8g -Djava.net.preferIPv4Stack=true"

# Stop and remove any existing container and systemd service.
sudo systemctl stop container-$CONTAINER_NAME.service 2>/dev/null || true
podman rm -f $CONTAINER_NAME || true

# Create the container without starting it — systemd will handle startup.
podman create --name=$CONTAINER_NAME --network=picsure \
    --dns=10.89.0.1 \
    --log-opt tag=$CONTAINER_NAME \
    --env-file /opt/picsure/query.env \
    -e JAVA_OPTS="$JAVA_OPTS" "$QUERY_IMAGE"

# systemd setup.
podman generate systemd --name $CONTAINER_NAME --restart-policy=always --files
sudo mv container-$CONTAINER_NAME.service /etc/systemd/system/
sudo restorecon -v /etc/systemd/system/container-$CONTAINER_NAME.service
sudo systemctl daemon-reload
sudo systemctl enable container-$CONTAINER_NAME.service
sudo systemctl start --no-block container-$CONTAINER_NAME.service

echo "Waiting for container to initialize..."
sleep 10

echo "Verifying container-$CONTAINER_NAME.service status..."
sudo systemctl is-enabled container-$CONTAINER_NAME.service
sudo systemctl status container-$CONTAINER_NAME.service --no-pager || true

echo "--- Journald logs for container-$CONTAINER_NAME.service ---"
sudo journalctl -u container-$CONTAINER_NAME.service --no-pager -n 50 || true

# Fail the script if the container is not running, so Jenkins reports the real error.
if ! podman ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "ERROR: Container '$CONTAINER_NAME' is not running after startup."
  echo "--- Full container inspect ---"
  podman inspect $CONTAINER_NAME 2>&1 || true
  exit 1
fi
