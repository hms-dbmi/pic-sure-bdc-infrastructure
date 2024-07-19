#!/bin/bash

stack_s3_bucket=$1

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/configs/psama/psama.env" "/home/centos/psama.env"
s3_copy "s3://${stack_s3_bucket}/releases/psama/psama.tar.gz" "/home/centos/psama.tar.gz"

# This script is responsible for starting or updating the psama container
PSAMA_IMAGE=`sudo docker load < /home/centos/psama.tar.gz | cut -d ' ' -f 3`
PSAMA_OPTS="-Xms1g -Xmx2g -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=512m -Djava.net.preferIPv4Stack=true"

# Stop and remove the existing psama container if it exists
sudo docker stop psama || true
sudo docker rm psama || true
sudo docker run -u root --name=psama --restart always --network=picsure \
--env-file /home/centos/psama.env \
-e JAVA_OPTS="$PSAMA_OPTS" \
-v /home/centos/fence_mapping.json:/config/fence_mapping.json \
-p 8090:8090 \
-d $PSAMA_IMAGE