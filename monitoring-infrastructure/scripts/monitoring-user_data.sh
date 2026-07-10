#!/bin/bash

stack_s3_bucket="${stack_s3_bucket}"
environment_name="${environment_name}"
gss_prefix="${gss_prefix}"
env_public_dns_name="${env_public_dns_name}"
env_staging_dns_name="${env_staging_dns_name}"
monitoring_mysql_host="${monitoring_mysql_host}"

echo "ENABLE_PODMAN=true" | sudo tee -a /opt/srce/startup.config
echo "export STACK_S3_BUCKET=$stack_s3_bucket" >> /etc/environment
echo "NESSUS_GROUP=${gss_prefix}_monitoring" | sudo tee -a /opt/srce/startup.config

sudo sh /opt/srce/scripts/start-gsstools.sh

sudo mkdir -p /var/log/picsure/monitoring /opt/picsure /usr/local/docker-config/monitoring

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/monitoring/deploy-monitoring.sh" "/opt/picsure/deploy-monitoring.sh"

sudo chmod +x /opt/picsure/deploy-monitoring.sh
sudo /opt/picsure/deploy-monitoring.sh --stack_s3_bucket "${stack_s3_bucket}" --environment_name "${environment_name}" \
  --public_dns "${env_public_dns_name}" --staging_dns "${env_staging_dns_name}" --mysql_host "${monitoring_mysql_host}"

# monitoring exporters (node_exporter + podman-exporter) — self-observability:
# the monitoring host's ec2_sd discovery includes itself, so it must also run
# exporters. Scraped over its own private IP (self-referencing SG rule).
s3_copy "s3://${stack_s3_bucket}/monitoring/deploy-exporters.sh" "/opt/picsure/deploy-exporters.sh"
sudo chmod +x /opt/picsure/deploy-exporters.sh
sudo /opt/picsure/deploy-exporters.sh --stack_s3_bucket "${stack_s3_bucket}" || echo "WARN: exporter deploy failed; continuing"

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources "$INSTANCE_ID" --tags Key=InitComplete,Value=true

echo "user-data progress starting update"
sudo yum -y update
