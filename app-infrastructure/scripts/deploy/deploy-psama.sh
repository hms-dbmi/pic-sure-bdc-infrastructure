#!/bin/bash

enable_debug=false
spring_profile="prod"

while [[ $# -gt 0 ]]; do
  case $1 in
    --stack_s3_bucket)
      stack_s3_bucket="$2"
      shift 2
      ;;
    --dataset_s3_object_key)
      dataset_s3_object_key="$2"
      shift 2
      ;;
    --enable_debug)
      enable_debug="$2"
      shift 2
      ;;
    --spring_profile)
      spring_profile="$2"
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
dataset_s3_object_key=${dataset_s3_object_key:-DATASET_S3_OBJECT_KEY}
target_stack=${target_stack:-TARGET_STACK}

if [[ -z "$stack_s3_bucket" || -z "$dataset_s3_object_key" || -z "$target_stack" ]]; then
  echo "Error: --stack_s3_bucket, --target_stack and --dataset_s3_object_key are required."
  exit 1
fi

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/configs/psama/psama.env" "/opt/picsure/psama.env"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/psama.tar.gz" "/opt/picsure/psama.tar.gz"
s3_copy "s3://${stack_s3_bucket}/data/${dataset_s3_object_key}/fence_mapping.json" "/opt/picsure/fence_mapping.json"

chmod 644 "/opt/picsure/psama.env"
chmod 644 "/opt/picsure/psama.tar.gz"
# This script is responsible for starting or updating the psama container
PSAMA_IMAGE=$(podman load < /opt/picsure/psama.tar.gz | cut -d ' ' -f 3)
PSAMA_OPTS="-Xms1g -Xmx2g -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=512m -Djava.net.preferIPv4Stack=true"

# Add remote debugging options if enabled.
if [ "$enable_debug" = true ]; then
  PSAMA_OPTS="$PSAMA_OPTS -agentlib:jdwp=transport=dt_socket,address=*:9000,server=y,suspend=n"
  PSAMA_PORTS="-p 8090:8090 -p 9000:9000 -p 8000:8000"
  # Add the spring profile when debugging is enabled
  PSAMA_OPTS="$PSAMA_OPTS -Dspring.profiles.active=dev"
else
  PSAMA_PORTS="-p 8090:8090"
  # Default spring profile for non-debugging mode
  PSAMA_OPTS="$PSAMA_OPTS -Dspring.profiles.active=$spring_profile"
fi

CONTAINER_NAME=psama
podman rm -f $CONTAINER_NAME || true
podman run -u root --privileged --name=$CONTAINER_NAME --network=picsure \
    --dns=10.89.0.1 \
    --env-file /opt/picsure/psama.env \
    -v /var/log/picsure/psama/:/var/log/:Z \
    -e JAVA_OPTS="$PSAMA_OPTS" \
    --log-opt tag=$CONTAINER_NAME \
    -v /opt/picsure/fence_mapping.json:/config/fence_mapping.json:z \
    $PSAMA_PORTS \
    -d $PSAMA_IMAGE

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
