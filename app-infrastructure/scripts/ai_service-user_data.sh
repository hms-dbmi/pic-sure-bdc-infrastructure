#!/bin/bash
set -euo pipefail

# Tag the instance so 'Await Initialization' can gate on the outcome. Any
# failure exits through the trap and tags InitComplete=failed instead of
# leaving the instance half-configured but tagged successful.
tag_init_complete() {
  INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
  sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources "$INSTANCE_ID" --tags Key=InitComplete,Value="$1"
}
trap 'rc=$?; [ "$rc" -eq 0 ] || tag_init_complete failed' EXIT

stack_s3_bucket="${stack_s3_bucket}"
environment_name="${environment_name}"
env_private_dns_name="${env_private_dns_name}"
gss_prefix="${gss_prefix}"
target_stack="${target_stack}"

echo "export STACK_S3_BUCKET=$stack_s3_bucket" >> /etc/environment
echo "export ENVIRONMENT_NAME=$environment_name" >> /etc/environment
echo "export ENV_PRIVATE_DNS_NAME=$env_private_dns_name" >> /etc/environment
echo "export GSS_PREFIX=$gss_prefix" >> /etc/environment
echo "export TARGET_STACK=$target_stack" >> /etc/environment

echo "ENABLE_PODMAN=true" | sudo tee -a /opt/srce/startup.config
echo "SPLUNK_INDEX=hms_aws_$gss_prefix" | sudo tee -a /opt/srce/startup.config
echo "NESSUS_GROUP=$${gss_prefix}_$${target_stack}" | sudo tee -a /opt/srce/startup.config

sudo sh /opt/srce/scripts/start-gsstools.sh

# Fail closed: if all attempts fail, abort (the EXIT trap tags InitComplete=failed).
s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && return 0
    sleep 30
  done
  echo "ERROR: aws s3 cp failed after 5 attempts: $*" >&2
  exit 1
}

sudo mkdir -p /opt/picsure
s3_copy "s3://${stack_s3_bucket}/${target_stack}/scripts/deploy-ai-service.sh" "/opt/picsure/deploy-ai-service.sh"
sudo chmod +x /opt/picsure/deploy-ai-service.sh

# Exits non-zero when the container is not running, which tags the instance failed.
sudo /opt/picsure/deploy-ai-service.sh --stack_s3_bucket "${stack_s3_bucket}" --target_stack "${target_stack}"

tag_init_complete true

echo "user-data progress starting update"
sudo yum -y update --allowerasing || echo "WARNING: yum update failed (non-fatal)"
