#!/bin/bash

stack_s3_bucket="${stack_s3_bucket}"
gss_prefix="${gss_prefix}"
destigmatized_dataset_s3_object_key="${destigmatized_dataset_s3_object_key}"
target_stack="${target_stack}"

echo "ENABLE_PODMAN=true" | sudo tee -a /opt/srce/startup.config
echo "SPLUNK_INDEX=hms_aws_${gss_prefix}" | sudo tee -a /opt/srce/startup.config
echo "NESSUS_GROUP=${gss_prefix}_${target_stack}" | sudo tee -a /opt/srce/startup.config

sudo sh /opt/srce/scripts/start-gsstools.sh

# Waiting for application to finish initialization
INIT_MESSAGE="WebApplicationContext: initialization completed"
INIT_TIMEOUT_SEX=2400  # Set your desired timeout in seconds
INIT_START_TIME=$(date +%s)

sudo mkdir -p /var/log/picsure/open-hpds/

# Check if S3 object exists before attempting to copy it
check_s3_exists() {
  sudo /usr/bin/aws --region us-east-1 s3 ls "$1" >/dev/null 2>&1
}

# Copy S3 objects in parallel
s3_copy_parallel() {
  local src="$1"
  local dest="$2"
  shift 2
  if check_s3_exists "$src"; then
    sudo /usr/bin/aws --region us-east-1 s3 cp "$src" "$dest" --no-progress "$@" &
  else
    echo "Warning: $src does not exist, retrying..."
    return 1
  fi
}

# Main S3 copy function with retries
s3_copy() {
  for i in {1..5}; do
    s3_copy_parallel "$@" && break || sleep 10
  done
  wait
}

s3_copy "s3://${stack_s3_bucket}/${target_stack}/scripts/deploy-open-hpds.sh" "/opt/picsure/deploy-open-hpds.sh"
sudo chmod +x /opt/picsure/deploy-open-hpds.sh
sudo /opt/picsure/deploy-open-hpds.sh \
--stack_s3_bucket "${stack_s3_bucket}" \
--destigmatized_dataset_s3_object_key "${destigmatized_dataset_s3_object_key}" \
--target_stack "${target_stack}"

echo "Waiting for container to initialize"
CONTAINER_NAME="open-hpds"
while true; do
  status=$(podman logs "$CONTAINER_NAME" 2>&1 | grep "$INIT_MESSAGE")

  if [ -z $status ];then
    echo "$CONTAINER_NAME container has initialized."

    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
    sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources "$INSTANCE_ID" --tags Key=InitComplete,Value=true
    break
  else
    CURRENT_TIME=$(date +%s)
    ELAPSED_TIME=$((CURRENT_TIME - INIT_START_TIME))

    if [ "$ELAPSED_TIME" -ge "$INIT_TIMEOUT_SECS" ]; then
      echo "Timeout reached ($INIT_TIMEOUT_SECS seconds). The $CONTAINER_NAME container initialization didn't complete."
      INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
      sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources "$INSTANCE_ID" --tags Key=InitComplete,Value=failed

      break
    fi
  fi
done

echo "user-data progress starting update"
sudo yum -y update
