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

# Source /etc/environment for fallback values set during initial provisioning.
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

s3_copy "s3://${stack_s3_bucket}/configs/pic-sure-visualization/${target_stack}/visualization.env" "/opt/picsure/visualization.env"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/pic-sure-visualization.tar.gz" "/opt/picsure/pic-sure-visualization.tar.gz"

chmod 644 "/opt/picsure/visualization.env"
chmod 644 "/opt/picsure/pic-sure-visualization.tar.gz"

VISUALIZATION_IMAGE=$(podman load < /opt/picsure/pic-sure-visualization.tar.gz | cut -d ' ' -f 3)
CONTAINER_NAME=visualization

sudo mkdir -p /var/log/picsure/visualization

# Stop and remove any existing container and systemd service.
sudo systemctl stop container-$CONTAINER_NAME.service 2>/dev/null || true
podman rm -f $CONTAINER_NAME || true

# Create the container without starting it; systemd handles startup.
podman create -u root --privileged --name=$CONTAINER_NAME --network=picsure \
    --dns=10.89.0.1 \
    --env-file /opt/picsure/visualization.env \
    -e SERVER_PORT=80 \
    -v /var/log/picsure/visualization/:/var/log/picsure/visualization/:Z \
    --log-opt tag=$CONTAINER_NAME \
    "$VISUALIZATION_IMAGE"

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

if ! podman ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "ERROR: Container '$CONTAINER_NAME' is not running after startup."
  podman inspect $CONTAINER_NAME 2>&1 || true
  exit 1
fi
