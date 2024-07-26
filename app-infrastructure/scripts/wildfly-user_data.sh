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
## temp - Installing docker
sudo yum update -y
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo yum remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
docker --version
####

# sleep for awhile because as these files are could still be in the process of being rendered.
# containerize already.
echo "waiting for terraform to render files"
sleep 300

# make picsure network
sudo docker network create picsure
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
