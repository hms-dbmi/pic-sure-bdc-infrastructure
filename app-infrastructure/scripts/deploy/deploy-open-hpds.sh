#!/bin/bash

while [[ $# -gt 0 ]]; do
  case $1 in
    --stack_s3_bucket)
      stack_s3_bucket="$2"
      shift 2
      ;;
    --destigmatized_dataset_s3_object_key)
      destigmatized_dataset_s3_object_key="$2"
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
destigmatized_dataset_s3_object_key=${destigmatized_dataset_s3_object_key:-$DESTIGMATIZED_DATASET_S3_OBJECT_KEY}
target_stack=${target_stack:-$TARGET_STACK}

if [[ -z "$stack_s3_bucket" || -z "$destigmatized_dataset_s3_object_key" || -z "$target_stack" ]]; then
  echo "Error: --stack_s3_bucket, --target_stack and --destigmatized_dataset_s3_object_key are required"
  exit 1
fi


s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

echo "Downloading Files"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/pic-sure-hpds.tar.gz" "/opt/picsure/pic-sure-hpds.tar.gz"
s3_copy "s3://${stack_s3_bucket}/data/${destigmatized_dataset_s3_object_key}/destigmatized_javabins_rekeyed.tar" "/opt/local/hpds/destigmatized_javabins_rekeyed.tar"
s3_copy "s3://${stack_s3_bucket}/configs/hpds/${target_stack}/open-hpds.env" "/opt/picsure/open-hpds.env"

echo "Unpacking destigmatized_javabins_rekeyed.tar"
cd /opt/local/hpds || exit
tar -xvf destigmatized_javabins_rekeyed.tar
cd ~ || exit
echo "Completed unpacking destigmatized_javabins_rekeyed.tar"

chmod 644 /opt/local/hpds/*
chmod 644 /opt/picsure/*

CONTAINER_NAME=open-hpds

echo "Loading and running container"
HPDS_IMAGE=$(podman load < /opt/picsure/pic-sure-hpds.tar.gz | cut -d ' ' -f 3)

# Stop and remove any existing container and systemd service.
sudo systemctl stop container-$CONTAINER_NAME.service 2>/dev/null || true
podman rm -f $CONTAINER_NAME || true

# Create the container without starting it — systemd will handle startup.
podman create --privileged --name=$CONTAINER_NAME \
                -v /var/log/picsure/open-hpds/:/var/log/:Z \
                -v /opt/local/hpds:/opt/local/hpds:Z \
                --log-opt tag=$CONTAINER_NAME \
                -p 8080:8080 \
                --env-file /opt/picsure/open-hpds.env \
                "$HPDS_IMAGE"
echo "Container created."

echo "Setting up podman for $CONTAINER_NAME"
# systemd setup.
podman generate systemd --name $CONTAINER_NAME --restart-policy=always --files
sudo mv container-$CONTAINER_NAME.service /etc/systemd/system/
sudo restorecon -v /etc/systemd/system/container-$CONTAINER_NAME.service

sudo systemctl daemon-reload
sudo systemctl enable container-$CONTAINER_NAME.service
sudo systemctl start container-$CONTAINER_NAME.service

echo "Verifying container-$CONTAINER_NAME.service status..."
sudo systemctl is-enabled container-$CONTAINER_NAME.service
# Status check is informational — Jenkins log polling verifies actual startup.
sudo systemctl status container-$CONTAINER_NAME.service --no-pager || true
echo "Completed podman setup for $CONTAINER_NAME"