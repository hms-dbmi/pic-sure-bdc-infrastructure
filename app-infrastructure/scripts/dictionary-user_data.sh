#!/bin/bash

echo "SPLUNK_INDEX=hms_aws_${gss_prefix}" > /opt/srce/startup.config
echo "NESSUS_GROUP=${gss_prefix}_${target_stack}" >> /opt/srce/startup.config

sudo sh /opt/srce/scripts/start-gsstools.sh

echo "user-data progress starting update"
sudo yum -y update

for i in {1..10}; do sudo /usr/bin/aws --region us-east-1 s3 cp s3://${stack_s3_bucket}/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-hpds-dictionary-resource.tar.gz /home/centos/pic-sure-hpds-dictionary-resource.tar.gz && break || sleep 30; done

sudo mkdir -p /usr/local/docker-config/search/
sudo mkdir -p /var/log/dictionary-docker-logs

DICTIONARY_IMAGE=`sudo docker load < /home/centos/pic-sure-hpds-dictionary-resource.tar.gz | cut -d ' ' -f 3`
sudo docker run --name=dictionary \
                --log-driver syslog --log-opt tag=dictionary \
                -v /var/log/dictionary-docker-logs/:/usr/local/tomcat/logs/ \
                -e CATALINA_OPTS=" -Xms1g -Xmx12g " \
                -p 8080:8080 -d $DICTIONARY_IMAGE

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources $${INSTANCE_ID} --tags Key=InitComplete,Value=true
