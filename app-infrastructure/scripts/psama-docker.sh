#!/bin/bash

stack_s3_bucket=$1
enable_debug=${2:-false}
spring_profile=${3:-prod}

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/configs/psama/psama.env" "/home/centos/psama.env"
s3_copy "s3://${stack_s3_bucket}/releases/psama/psama.tar.gz" "/home/centos/psama.tar.gz"

# This script is responsible for starting or updating the psama container
PSAMA_IMAGE=$(sudo docker load < /home/centos/psama.tar.gz | cut -d ' ' -f 3)
PSAMA_OPTS="-Xms1g -Xmx2g -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=512m -Djava.net.preferIPv4Stack=true"

# Add remote debugging options if enabled.
# To enable remote debugging, set the second script argument to true.
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

# Stop and remove the existing psama container if it exists
sudo docker stop psama || true
sudo docker rm psama || true
sudo docker run -u root --name=psama --restart always --network=picsure \
--env-file /home/centos/psama.env \
-v /var/log/picsure/psama/:/var/log/ \
-e JAVA_OPTS="$PSAMA_OPTS" \
--log-opt tag=psama \
-v /home/centos/fence_mapping.json:/config/fence_mapping.json \
$PSAMA_PORTS \
-d $PSAMA_IMAGE