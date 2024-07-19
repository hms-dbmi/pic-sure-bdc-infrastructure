#!/bin/bash

echo "SPLUNK_INDEX=hms_aws_${gss_prefix}" | sudo tee /opt/srce/startup.config
echo "NESSUS_GROUP=${gss_prefix}_${target_stack}" | sudo tee -a /opt/srce/startup.config

sudo sh /opt/srce/scripts/start-gsstools.sh

echo "
[monitor:///var/log/hpds-docker-logs]
sourcetype = hms_app_logs
source = hpds_logs
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

# Download the hpds docker script
s3_copy s3://${stack_s3_bucket}/configs/auth-hpds-docker.sh /home/centos/auth-hpds-docker.sh

sudo chmod +x /home/centos/auth-hpds-docker.sh

stack_s3_bucket="${stack_s3_bucket}"
dataset_s3_object_key="${dataset_s3_object_key}"
genomic_dataset_s3_object_key="${genomic_dataset_s3_object_key}"

sudo /home/centos/auth-hpds-docker.sh "$stack_s3_bucket" "$dataset_s3_object_key" "$genomic_dataset_s3_object_key"