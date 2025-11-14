#!/bin/bash

stack_s3_bucket="${stack_s3_bucket}"
gss_prefix="${gss_prefix}"
target_stack="${target_stack}"
dataset_s3_object_key="${dataset_s3_object_key}"

# Persist configuration in a dedicated env file for deploy scripts and services
upsert_env_var() {
  local file="$1" key="$2" value="$3"

  sudo mkdir -p "$(dirname "$file")"
  sudo touch "$file"

  # Replace if exists, else append
  if ! sudo grep -q "^${key}=" "$file"; then
    echo "${key}=${value}" | sudo tee -a "$file" >/dev/null
  else
    sudo sed -i "s|^${key}=.*|${key}=${value}|" "$file"
  fi

  sudo chmod 600 "$file"
}
CONF_FILE=/etc/picsure/picsure.env
upsert_env_var "$CONF_FILE" STACK_S3_BUCKET "$stack_s3_bucket"
upsert_env_var "$CONF_FILE" GSS_PREFIX "$gss_prefix"
upsert_env_var "$CONF_FILE" TARGET_STACK "$target_stack"
upsert_env_var "$CONF_FILE" DATASET_S3_OBJECT_KEY "$dataset_s3_object_key"

echo "ENABLE_PODMAN=true" | sudo tee -a /opt/srce/startup.config
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

# Check if wildfly is resolvable after httpd-vhosts.conf has been downloaded
for i in 1 2 3 4 5; do echo "confirming wildfly resolvable" && sudo curl --connect-timeout 1 "$(grep -A30 preprod /usr/local/docker-config/httpd-vhosts.conf | grep wildfly | grep api | cut -d "\"" -f 2 | sed 's/pic-sure-api-2.*//')" || if [ $? = 6 ]; then (exit 1); fi && break || sleep 60; done

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources "$INSTANCE_ID" --tags Key=InitComplete,Value=true

echo "user-data progress starting update"
sudo yum -y update
