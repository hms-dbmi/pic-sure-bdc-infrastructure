#!/bin/bash
echo "ENABLE_PODMAN=true" | sudo tee -a /opt/srce/startup.config
echo "SPLUNK_INDEX=hms_aws_${gss_prefix}" | sudo tee -a /opt/srce/startup.config
echo "NESSUS_GROUP=${gss_prefix}_${target_stack}" | sudo tee -a /opt/srce/startup.config

sudo sh /opt/srce/scripts/start-gsstools.sh

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}
# sleep for awhile because as these files are could still be in the process of being rendered.
# containerize already.
echo "waiting for terraform to render files"
sleep 180

# Add swap space
sudo dd if=/dev/zero of=/swapfile count=15360 bs=1MiB
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# podman network create picsure
podman network create picsure

PODMAN_IFNAME=$(podman network inspect picsure | jq -r '.[0].network_interface')

nft add rule inet filter forward iifname "${PODMAN_IFNAME}" accept
nft add rule inet filter forward oifname "${PODMAN_IFNAME}" accept

nft list ruleset > /etc/nftables/nftables.rules
systemctl restart nftables

systemctl enable --now podman


sudo mkdir -p /var/log/picsure/{wildfly,psama,dictionary}

# Download the wildfly and psama docker scripts
s3_copy s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/wildfly-docker.sh /opt/picsure/wildfly-docker.sh
s3_copy s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/psama-docker.sh /opt/picsure/psama-docker.sh
s3_copy s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/dictionary-docker.sh /opt/picsure/dictionary-docker.sh


target_stack="${target_stack}"
env_private_dns_name="${env_private_dns_name}"
stack_s3_bucket="${stack_s3_bucket}"
stack_githash="${stack_githash}"
dataset_s3_object_key="${dataset_s3_object_key}"

bash /opt/picsure/wildfly-docker.sh "$target_stack" "$env_private_dns_name" "$stack_s3_bucket" "$stack_githash" "$dataset_s3_object_key"
bash /opt/picsure/psama-docker.sh "$stack_s3_bucket"
bash /opt/picsure/dictionary-docker.sh "$stack_s3_bucket"

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources $${INSTANCE_ID} --tags Key=InitComplete,Value=true

echo "user-data progress starting update"
sudo yum -y update