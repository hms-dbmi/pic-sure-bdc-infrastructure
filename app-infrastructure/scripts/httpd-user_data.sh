#!/bin/bash

stack_s3_bucket="${stack_s3_bucket}"
gss_prefix="${gss_prefix}"
target_stack="${target_stack}"
dataset_s3_object_key="${dataset_s3_object_key}"

echo "ENABLE_PODMAN=true" | sudo tee -a /opt/srce/startup.config
echo "export STACK_S3_BUCKET=$stack_s3_bucket" >> /etc/environment
echo "export GSS_PREFIX=$gss_prefix" >> /etc/environment
echo "export TARGET_STACK=$target_stack" >> /etc/environment
echo "NESSUS_GROUP=${gss_prefix}_${target_stack}" | sudo tee -a /opt/srce/startup.config

sudo sh /opt/srce/scripts/start-gsstools.sh

mkdir -p /usr/local/docker-config/cert
sudo mkdir -p /var/log/picsure/httpd/
sudo mkdir -p /var/log/picsure/httpd/ssl_mutex


s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/${target_stack}/scripts/deploy-httpd.sh" "/opt/picsure/deploy-httpd.sh"

sudo chmod +x /opt/picsure/deploy-httpd.sh
sudo /opt/picsure/deploy-httpd.sh --stack_s3_bucket "${stack_s3_bucket}" --target_stack "${target_stack}" --dataset_s3_object_key "${dataset_s3_object_key}"

# Check if the gateway host is resolvable after httpd-vhosts.conf has been downloaded
# Probes the gateway's /system/status endpoint via any non-health /picsure RewriteRule target
for i in 1 2 3 4 5; do echo "confirming gateway resolvable" && sudo curl --connect-timeout 1 "$(grep 'picsure/(' /usr/local/docker-config/httpd-vhosts.conf | grep RewriteRule | grep -v health | head -1 | cut -d "\"" -f 2 | sed 's|:8080/.*|:8080/system/status|')" || if [ $? = 6 ]; then (exit 1); fi && break || sleep 60; done

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources "$INSTANCE_ID" --tags Key=InitComplete,Value=true

echo "user-data progress starting update"
sudo yum -y update
