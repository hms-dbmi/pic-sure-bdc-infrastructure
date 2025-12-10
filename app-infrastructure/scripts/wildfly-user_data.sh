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


s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

# Add swap space
sudo dd if=/dev/zero of=/swapfile count=15360 bs=1MiB
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# podman network create picsure
# explicit subnet and gateway to ensure networking works
# enable dns resolution so containers on the network can resolve one another.
podman network create \
  --driver=bridge \
  --subnet=10.89.0.0/24 \
  --gateway=10.89.0.1 \
  picsure

PODMAN_IFNAME=$(podman network inspect picsure | jq -r '.[0].network_interface')

nft add rule inet filter forward iifname "$${PODMAN_IFNAME}" accept
nft add rule inet filter forward oifname "$${PODMAN_IFNAME}" accept
nft add rule inet filter input udp dport 53 accept

nft list ruleset > /etc/nftables/nftables.rules
systemctl restart nftables

systemctl enable --now podman

sudo mkdir -p /var/log/picsure/{wildfly,psama,dictionary}

s3_copy "s3://${stack_s3_bucket}/${target_stack}/scripts/deploy-wildfly.sh" "/opt/picsure/deploy-wildfly.sh"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/scripts/deploy-psama.sh" "/opt/picsure/deploy-psama.sh"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/scripts/deploy-dictionary.sh" "/opt/picsure/deploy-dictionary.sh"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/scripts/restart-dictionary-container.sh" "/opt/picsure/restart-dictionary-container.sh"


sudo chmod +x /opt/picsure/deploy-wildfly.sh
sudo chmod +x /opt/picsure/deploy-psama.sh
sudo chmod +x /opt/picsure/deploy-dictionary.sh
sudo chmod +x /opt/picsure/restart-dictionary-container.sh


sudo /opt/picsure/deploy-wildfly.sh --env_private_dns_name "${env_private_dns_name}" --stack_s3_bucket "${stack_s3_bucket}" --target_stack "${target_stack}" --dataset_s3_object_key "${dataset_s3_object_key}"
sudo /opt/picsure/deploy-psama.sh --stack_s3_bucket "${stack_s3_bucket}" --target_stack "${target_stack}" --dataset_s3_object_key "${dataset_s3_object_key}"
sudo /opt/picsure/deploy-dictionary.sh --stack_s3_bucket "${stack_s3_bucket}" --target_stack "${target_stack}"

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources "$INSTANCE_ID" --tags Key=InitComplete,Value=true

echo "user-data progress starting update"
sudo yum -y update
