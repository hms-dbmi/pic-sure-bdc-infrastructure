#!/bin/bash

echo "SPLUNK_INDEX=hms_aws_${gss_prefix}" | sudo tee /opt/srce/startup.config
echo "NESSUS_GROUP=${gss_prefix}_${target_stack}" | sudo tee -a /opt/srce/startup.config

sudo sh /opt/srce/scripts/start-gsstools.sh
echo "
[monitor:///var/log/dictionary-docker-logs/]
sourcetype = hms_app_logs
source = dictionary_logs
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

s3_copy s3://${stack_s3_bucket}/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-hpds-dictionary-resource.tar.gz /opt/picsure/pic-sure-hpds-dictionary-resource.tar.gz

s3_copy s3://${stack_s3_bucket}/data/${dataset_s3_object_key}/fence_mapping.json /opt/picsure/fence_mapping.json
echo "pulled fence mapping"

sudo mkdir -p /usr/local/docker-config/search/
sudo mkdir -p /var/log/dictionary-docker-logs

DICTIONARY_IMAGE=`sudo docker load < /opt/picsure/pic-sure-hpds-dictionary-resource.tar.gz | cut -d ' ' -f 3`
sudo docker run --name=dictionary \
                --log-driver syslog --log-opt tag=dictionary \
                -v /var/log/dictionary-docker-logs/:/usr/local/tomcat/logs/ \
                -v /opt/picsure/fence_mapping.json:/usr/local/docker-config/search/fence_mapping.json \
                -e CATALINA_OPTS=" -Xms1g -Xmx12g " \
                -p 8080:8080 -d $DICTIONARY_IMAGE

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources $${INSTANCE_ID} --tags Key=InitComplete,Value=true
