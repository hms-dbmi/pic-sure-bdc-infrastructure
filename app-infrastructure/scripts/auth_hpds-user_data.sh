#!/bin/bash

stack_s3_bucket="${stack_s3_bucket}"
dataset_s3_object_key="${dataset_s3_object_key}"
genomic_dataset_s3_object_key="${genomic_dataset_s3_object_key}"
environment_name="${environment_name}"
env_private_dns_name="${env_private_dns_name}"
gss_prefix="${gss_prefix}"
target_stack="${target_stack}"

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
upsert_env_var "$CONF_FILE" DATASET_S3_OBJECT_KEY "$dataset_s3_object_key"
upsert_env_var "$CONF_FILE" GENOMIC_DATASET_S3_OBJECT_KEY "$genomic_dataset_s3_object_key"
upsert_env_var "$CONF_FILE" ENVIRONMENT_NAME "$environment_name"
upsert_env_var "$CONF_FILE" ENV_PRIVATE_DNS_NAME "$env_private_dns_name"
upsert_env_var "$CONF_FILE" GSS_PREFIX "$gss_prefix"
upsert_env_var "$CONF_FILE" TARGET_STACK "$target_stack"

echo "ENABLE_PODMAN=true" | sudo tee -a /opt/srce/startup.config
echo "SPLUNK_INDEX=hms_aws_$gss_prefix" | sudo tee -a /opt/srce/startup.config
echo "NESSUS_GROUP=${gss_prefix}_${target_stack}" | sudo tee -a /opt/srce/startup.config

sudo sh /opt/srce/scripts/start-gsstools.sh
echo "user-data progress starting update"


s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

mkdir -p /opt/local/hpds/all
sudo mkdir -p /var/log/picsure/auth-hpds/

# Load and run docker container.  Then wait for initialization before tagging instance as init complete.
echo "Loading and running docker container"
INIT_MESSAGE="WebApplicationContext: initialization completed"
INIT_TIMEOUT_SECS=2400  # Set your desired timeout in seconds
INIT_START_TIME=$(date +%s)

s3_copy "s3://${stack_s3_bucket}/${target_stack}/scripts/deploy-auth-hpds.sh" "/opt/picsure/deploy-auth-hpds.sh"

sudo chmod +x /opt/picsure/deploy-auth-hpds.sh
sudo /opt/picsure/deploy-auth-hpds.sh \
--stack_s3_bucket "${stack_s3_bucket}" \
--genomic_dataset_s3_object_key "${genomic_dataset_s3_object_key}" \
--dataset_s3_object_key "${dataset_s3_object_key}" \
--environment_name "${environment_name}" \
--target_stack "${target_stack}" \
--env_private_dns_name "${env_private_dns_name}"

echo "Waiting for container to initialize"

CONTAINER_NAME="auth-hpds"
while true; do
  status=$(podman logs "$CONTAINER_NAME" 2>&1 | grep "$INIT_MESSAGE")

  if [ -n "$status" ]; then
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

    sleep 5
  fi
done

echo "user-data progress starting update"
sudo yum -y update