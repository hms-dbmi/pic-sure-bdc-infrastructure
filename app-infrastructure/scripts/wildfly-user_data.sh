#!/bin/bash

target_stack="${target_stack}"
env_private_dns_name="${env_private_dns_name}"
stack_s3_bucket="${stack_s3_bucket}"
stack_githash="${stack_githash}"
dataset_s3_object_key="${dataset_s3_object_key}"
gss_prefix="${gss_prefix}"

# This is added to our /etc/environment to make them available to our deploy script
# when executed by our ssm command. Doing this allows us to make values optional.
# If they haven't changed since our last deployment we don't need to pass them to the script(s).
echo "export TARGET_STACK=$target_stack" >> /etc/environment
echo "export ENV_PRIVATE_DNS_NAME=$env_private_dns_name" >> /etc/environment
echo "export STACK_S3_BUCKET=$stack_s3_bucket" >> /etc/environment
echo "export STACK_GITHASH=$stack_githash" >> /etc/environment
echo "export DATASET_S3_OBJECT_KEY=$dataset_s3_object_key" >> /etc/environment
echo "export GSS_PREFIX=$gss_prefix" >> /etc/environment

echo "ENABLE_PODMAN=true" | sudo tee -a /opt/srce/startup.config
echo "SPLUNK_INDEX=hms_aws_${gss_prefix}" | sudo tee -a /opt/srce/startup.config
echo "NESSUS_GROUP=${gss_prefix}_${target_stack}" | sudo tee -a /opt/srce/startup.config

sudo sh /opt/srce/scripts/start-gsstools.sh
sudo systemctl stop SplunkForwarder

/opt/splunkforwarder/bin/splunk enable boot-start -systemd-managed 1 -user splunk  || true

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

# Add swap space
sudo dd if=/dev/zero of=/swapfile count=15360 bs=1MiB
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

sudo docker network create picsure
sudo mkdir -p /var/log/picsure/{wildfly,psama,dictionary}

s3_copy "s3://${stack_s3_bucket}/${target_stack}/scripts/deploy-wildfly.sh" "/opt/picsure/deploy-wildfly.sh"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/scripts/deploy-psama.sh" "/opt/picsure/deploy-psama.sh"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/scripts/deploy-dictionary.sh" "/opt/picsure/deploy-dictionary.sh"

sudo chmod +x /opt/picsure/deploy-wildfly.sh
sudo chmod +x /opt/picsure/deploy-psama.sh
sudo chmod +x /opt/picsure/deploy-dictionary.sh

sudo /opt/picsure/deploy-wildfly.sh --env_private_dns_name "${env_private_dns_name}" --stack_s3_bucket "${stack_s3_bucket}" --stack_githash "${stack_githash}" --target_stack "${target_stack}"

sudo /opt/picsure/deploy-psama.sh --stack_s3_bucket "${stack_s3_bucket}" --target_stack "${target_stack}"
sudo /opt/picsure/deploy-dictionary.sh --stack_s3_bucket "${stack_s3_bucket}" --stack_githash "$stack_githash" --target_stack "${target_stack}"

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources "$INSTANCE_ID" --tags Key=InitComplete,Value=true

echo "Restart splunkforwarder service"
sudo systemctl restart SplunkForwarder
echo "user-data progress starting update"
sudo yum -y update
