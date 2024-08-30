#!/bin/bash

echo "SPLUNK_INDEX=hms_aws_${gss_prefix}" | sudo tee /opt/srce/startup.config
echo "NESSUS_GROUP=${gss_prefix}_${target_stack}" | sudo tee -a /opt/srce/startup.config

sudo sh /opt/srce/scripts/start-gsstools.sh

echo "
[monitor:///var/log/wildfly-docker-logs]
sourcetype = hms_app_logs
source = wildfly_logs
index=hms_aws_${gss_prefix}

[monitor:///var/log/wildfly-docker-os-logs]
sourcetype = hms_app_logs
source = wildfly_logs
index=hms_aws_${gss_prefix}
" | sudo tee -a /opt/splunkforwarder/etc/system/local/inputs.conf
/opt/splunkforwarder/bin/splunk enable boot-start -systemd-managed 1 -user splunk && sudo systemctl restart SplunkForwarder || true

echo "user-data progress starting update"
sudo yum -y update

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

echo "waiting for terraform to render files"
sleep 300

# NFT Rules
sudo nft add rule ip filter INPUT tcp dport 8080 accept
sudo nft add rule ip filter OUTPUT tcp sport 8080 accept

sudo nft add rule ip filter INPUT tcp dport 8090 accept
sudo nft add rule ip filter OUTPUT tcp sport 8090 accept

sudo nft add rule ip filter INPUT tcp dport 5432 accept
sudo nft add rule ip filter OUTPUT tcp sport 5432 accept

sudo nft add rule ip filter INPUT tcp dport 3306 accept
sudo nft add rule ip filter OUTPUT tcp sport 3306 accept

# Creating network for wildfly
docker network create \
  --driver=bridge \
  --subnet=172.18.0.0/16 \
  --gateway=172.18.0.1 \
  --opt com.docker.network.bridge.name=docker1 \
  picsure

# NFT Rules for the picsure network
sudo nft add rule ip filter INPUT iifname "docker1" accept
sudo nft add rule ip filter FORWARD oifname "docker1" ct state established,related accept
sudo nft add rule ip filter FORWARD oifname "docker1" jump DOCKER
sudo nft add rule ip filter FORWARD iifname "docker1" oifname != "docker1" accept
sudo nft add rule ip filter FORWARD iifname "docker1" oifname "docker1" accept
sudo nft add rule ip filter OUTPUT oifname "docker1" accept
sudo nft add rule ip filter DOCKER-ISOLATION-STAGE-1 iifname "docker1" oifname != "docker1" jump DOCKER-ISOLATION-STAGE-2
sudo nft add rule ip filter DOCKER-ISOLATION-STAGE-2 oifname "docker1" drop
sudo nft add rule ip nat POSTROUTING oifname != "docker1" ip saddr 172.18.0.0/16 masquerade
sudo nft add rule ip nat DOCKER iifname "docker1" return

# Add new rules to the nftables.rules so they propagate on service restarts
sudo nft list ruleset > /etc/nftables/nftables.rules

sudo mkdir /var/log/{wildfly-docker-logs,wildfly-docker-os-logs}

# Download the wildfly and psama docker scripts
s3_copy s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/wildfly-docker.sh /opt/picsure/wildfly-docker.sh
s3_copy s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/psama-docker.sh /opt/picsure/psama-docker.sh

sudo chmod +x /opt/picsure/wildfly-docker.sh
sudo chmod +x /opt/picsure/psama-docker.sh

target_stack="${target_stack}"
env_private_dns_name="${env_private_dns_name}"
stack_s3_bucket="${stack_s3_bucket}"
stack_githash="${stack_githash}"
dataset_s3_object_key="${dataset_s3_object_key}"

sudo /opt/picsure/wildfly-docker.sh "$target_stack" "$env_private_dns_name" "$stack_s3_bucket" "$stack_githash" "$dataset_s3_object_key"
sudo /opt/picsure/psama-docker.sh "$stack_s3_bucket" "$stack_githash"

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources $${INSTANCE_ID} --tags Key=InitComplete,Value=true
