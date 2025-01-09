#!/bin/bash

stack_s3_bucket="${stack_s3_bucket}"
stack_githash="${stack_githash}"
dataset_s3_object_key="${dataset_s3_object_key}"
genomic_dataset_s3_object_key="${genomic_dataset_s3_object_key}"
environment_name="${environment_name}"
env_private_dns_name="${env_private_dns_name}"
gss_prefix="${gss_prefix}"
target_stack="${target_stack}"

echo "SPLUNK_INDEX=hms_aws_$gss_prefix" | sudo tee /opt/srce/startup.config
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

echo "user-data progress starting update"

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

mkdir -p /opt/local/hpds/all

cd /opt/local/hpds || exit 1
tar -xvf javabins_rekeyed.tar
cd ~ || exit 1

# Load and run docker container.  Then wait for initialization before tagging instance as init complete.
echo "Loading and running docker container"
INIT_MESSAGE="WebApplicationContext: initialization completed"
INIT_TIMEOUT_SECS=2400  # Set your desired timeout in seconds
INIT_START_TIME=$(date +%s)

s3_copy "s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/deploy-auth-hpds.sh" "/home/centos/deploy-auth-hpds.sh"
sudo chmod +x /home/centos/deploy-auth-hpds.sh
sudo /home/centos/deploy-auth-hpds.sh \
--stack_s3_bucket "${stack_s3_bucket}" \
--stack_githash "${stack_githash}" \
--genomic_dataset_s3_object_key "${genomic_dataset_s3_object_key}" \
--environment_name "${environment_name}" \
--target_stack "${target_stack}" \
--env_private_dns_name "${env_private_dns_name}"

echo "Waiting for container to initialize"

CONTAINER_NAME="auth-hpds"
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
