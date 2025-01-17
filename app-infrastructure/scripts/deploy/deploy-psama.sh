#!/bin/bash

enable_debug=false
spring_profile="prod"

# Parse named arguments
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

if [[ -z "$stack_s3_bucket" || -z "$dataset_s3_object_key" || -z "$target_stack" ]]; then
  echo "Error: --stack_s3_bucket and --dataset_s3_object_key are required."
  exit 1
fi

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/${target_stack}/configs/psama/psama.env" "/home/centos/psama.env"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/psama.tar.gz" "/home/centos/psama.tar.gz"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/data/${dataset_s3_object_key}/fence_mapping.json" "/home/centos/fence_mapping.json"

PSAMA_IMAGE=$(sudo docker load < /home/centos/psama.tar.gz | cut -d ' ' -f 3)
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

sudo docker stop psama || true
sudo docker rm psama || true
sudo docker run -u root --name=psama --restart always --network=picsure \
--env-file /home/centos/psama.env \
-v /var/log/psama-docker-os-logs/:/var/log/ \
-v /var/log/psama-docker-logs/:/opt/psama/logs/ \
-e JAVA_OPTS="$PSAMA_OPTS" \
--log-driver syslog --log-opt tag=wildfly \
-v /home/centos/fence_mapping.json:/config/fence_mapping.json \
"$PSAMA_PORTS" \
-d "$PSAMA_IMAGE"