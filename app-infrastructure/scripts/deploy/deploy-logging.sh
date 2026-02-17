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

stack_s3_bucket=${stack_s3_bucket:-STACK_S3_BUCKET}
target_stack=${target_stack:-TARGET_STACK}

if [[ -z "$stack_s3_bucket" || -z "$target_stack" ]]; then
  echo "Error: --stack_s3_bucket and --target_stack are required."
  exit 1
fi

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/configs/pic-sure-logging/logging.env" "/opt/picsure/logging.env"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/pic-sure-logging.tar.gz" "/opt/picsure/pic-sure-logging.tar.gz"

LOGGING_IMAGE=$(podman load < /opt/picsure/pic-sure-logging.tar.gz | cut -d ' ' -f 3)
CONTAINER_NAME=pic-sure-logging

podman rm -f $CONTAINER_NAME || true
podman run --name=$CONTAINER_NAME \
      --dns=10.89.0.1 \
      --env-file /opt/picsure/logging.env \
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
sudo systemctl status container-$CONTAINER_NAME.service --no-pager
