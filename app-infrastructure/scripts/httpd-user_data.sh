#!/bin/bash

stack_s3_bucket="${stack_s3_bucket}"
gss_prefix="${gss_prefix}"
target_stack="${target_stack}"
dataset_s3_object_key="${dataset_s3_object_key}"

echo "ENABLE_PODMAN=true" | sudo tee -a /opt/srce/startup.config
echo "export STACK_S3_BUCKET=$stack_s3_bucket" /etc/environment
echo "export GSS_PREFIX=$gss_prefix" >> /etc/environment
echo "export TARGET_STACK=$target_stack" >> /etc/environment
echo "NESSUS_GROUP=${gss_prefix}_${target_stack}" | sudo tee -a /opt/srce/startup.config

sudo sh /opt/srce/scripts/start-gsstools.sh

mkdir -p /usr/local/docker-config/cert
sudo mkdir -p /var/log/picsure/httpd/
sudo mkdir -p /var/log/picsure/httpd/ssl_mutex

# Main S3 copy function with retries
s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/${target_stack}/scripts/deploy-httpd.sh" "/opt/picsure/deploy-httpd.sh"

for i in 1 2 3 4 5; do echo "confirming wildfly resolvable" && sudo curl --connect-timeout 1 "$(grep -A30 preprod /usr/local/docker-config/httpd-vhosts.conf | grep wildfly | grep api | cut -d "\"" -f 2 | sed 's/pic-sure-api-2.*//')" || if [ $? = 6 ]; then (exit 1); fi && break || sleep 60; done

sudo chmod +x /opt/picsure/deploy-httpd.sh
sudo /opt/picsure/deploy-httpd.sh --stack_s3_bucket "${stack_s3_bucket}" --target_stack "${target_stack}" --dataset_s3_object_key "${dataset_s3_object_key}"

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources "$INSTANCE_ID" --tags Key=InitComplete,Value=true

echo "user-data progress starting update"
sudo yum -y update
