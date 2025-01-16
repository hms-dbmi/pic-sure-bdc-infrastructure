#!/bin/bash

stack_s3_bucket="${stack_s3_bucket}"
stack_githash="${stack_githash}"
gss_prefix="${gss_prefix}"
destigmatized_dataset_s3_object_key="${destigmatized_dataset_s3_object_key}"
target_stack="${target_stack}"

echo "SPLUNK_INDEX=hms_aws_${gss_prefix}" | sudo tee /opt/srce/startup.config
echo "NESSUS_GROUP=${gss_prefix}_${target_stack}" | sudo tee -a /opt/srce/startup.config

sudo sh /opt/srce/scripts/start-gsstools.sh

echo "
[monitor:///var/log/hpds-docker-logs]
sourcetype = hms_app_logs
source = hpds_logs
index=hms_aws_${gss_prefix}
" | sudo tee -a /opt/splunkforwarder/etc/system/local/inputs.conf

sudo systemctl stop SplunkForwarder

/opt/splunkforwarder/bin/splunk enable boot-start -systemd-managed 1 -user splunk || true

cd /opt/local/hpds || exit
tar -xvf destigmatized_javabins_rekeyed.tar
cd ~ || exit

# Waiting for application to finish initialization
INIT_MESSAGE="WebApplicationContext: initialization completed"
INIT_TIMEOUT_SEX=2400  # Set your desired timeout in seconds
INIT_START_TIME=$(date +%s)

s3_copy "s3://${stack_s3_bucket}/${target_stack}/scripts/deploy-open-hpds.sh" "/home/centos/deploy-open-hpds.sh"
sudo chmod +x /home/centos/deploy-open-hpds.sh
sudo /home/centos/deploy-open-hpds.sh \
--stack_s3_bucket "${stack_s3_bucket}" \
--stack_githash "${stack_githash}" \
--destigmatized_dataset_s3_object_key "${destigmatized_dataset_s3_object_key}" \
--target_stack "${target_stack}"

echo "Waiting for container to initialize"
CONTAINER_NAME="open-hpds"
while true; do
  status=$(docker logs "$CONTAINER_NAME" 2>&1 | grep "$INIT_MESSAGE")

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


echo "Restart splunkforwarder service"
sudo systemctl restart SplunkForwarder
echo "user-data progress starting update"
sudo yum -y update