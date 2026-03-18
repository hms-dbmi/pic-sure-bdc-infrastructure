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

s3_copy "s3://${stack_s3_bucket}/configs/picsure-dictionary/picsure-dictionary.env" "/opt/picsure/picsure-dictionary.env"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/dictionary-api.tar.gz" "/opt/picsure/dictionary-api.tar.gz"

DICTIONARY_API_IMAGE=$(podman load < /opt/picsure/dictionary-api.tar.gz | cut -d ' ' -f 3)
JAVA_OPTS=" -Xmx10g "
CONTAINER_NAME=dictionary-api

# Stop and remove any existing container and systemd service.
sudo systemctl stop container-$CONTAINER_NAME.service 2>/dev/null || true
podman rm -f $CONTAINER_NAME || true

# Create the container without starting it — systemd will handle startup.
podman create --privileged --name=$CONTAINER_NAME \
      --dns=10.89.0.1 \
      --env-file /opt/picsure/picsure-dictionary.env \
       -v /var/log/picsure/dictionary/:/var/log/:Z \
      --network picsure \
      --log-opt tag=$CONTAINER_NAME \
      -e JAVA_OPTS="$JAVA_OPTS" \
      "$DICTIONARY_API_IMAGE"

# systemd setup.
podman generate systemd --name $CONTAINER_NAME --restart-policy=always --files
sudo mv container-$CONTAINER_NAME.service /etc/systemd/system/
sudo restorecon -v /etc/systemd/system/container-$CONTAINER_NAME.service

# Serialize systemd operations across parallel deploys to avoid D-Bus race conditions.
{
  flock -w 120 9 || { echo "ERROR: timed out waiting for systemd lock"; exit 1; }
  sudo systemctl daemon-reload
  sudo systemctl enable container-$CONTAINER_NAME.service
  sudo systemctl start --no-block container-$CONTAINER_NAME.service
} 9>/var/lock/picsure-systemd.lock

echo "Verifying container-$CONTAINER_NAME.service status..."
sudo systemctl is-enabled container-$CONTAINER_NAME.service
# Status check is informational — Jenkins log polling verifies actual Spring Boot startup.
sudo systemctl status container-$CONTAINER_NAME.service --no-pager || true
