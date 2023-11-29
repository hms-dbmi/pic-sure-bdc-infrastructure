#!/bin/bash

echo "SPLUNK_INDEX=hms_aws_${gss_prefix}" | sudo tee /opt/srce/startup.config
echo "NESSUS_GROUP=${gss_prefix}_${target_stack}" | sudo tee -a /opt/srce/startup.config

sudo sh /opt/srce/scripts/start-gsstools.sh

echo "
[monitor:///var/log/httpd-docker-logs/]
sourcetype = hms_app_logs
source = httpd_logs
index=hms_aws_${gss_prefix}
" | sudo tee -a /opt/splunkforwarder/etc/system/local/inputs.conf
sudo systemctl restart SplunkForwarder || true

echo "user-data progress starting update"
sudo yum -y update

mkdir -p /usr/local/docker-config/cert
mkdir -p /var/log/httpd-docker-logs/ssl_mutex

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}
# sleep for awhile as these files could still be in the process of being rendered.
echo "waiting for terraform to render files"
sleep 1200

s3_copy s3://${stack_s3_bucket}/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-ui.tar.gz /home/centos/pic-sure-ui.tar.gz
s3_copy s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/httpd-vhosts.conf /usr/local/docker-config/httpd-vhosts.conf
s3_copy s3://${stack_s3_bucket}/certs/httpd/ /usr/local/docker-config/cert/ --recursive
s3_copy s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/picsureui_settings.json /usr/local/docker-config/picsureui_settings.json
s3_copy s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/banner_config.json /usr/local/docker-config/banner_config.json
s3_copy s3://${stack_s3_bucket}/data/${dataset_s3_object_key}/fence_mapping.json /home/centos/fence_mapping.json

for i in 1 2 3 4 5; do echo "confirming wildfly resolvable" && sudo curl --connect-timeout 1 $(grep -A30 preprod /usr/local/docker-config/httpd-vhosts.conf | grep wildfly | grep api | cut -d "\"" -f 2 | sed 's/pic-sure-api-2.*//') || if [ $? = 6 ]; then (exit 1); fi && break || sleep 60; done

sudo mkdir -p /var/log/httpd-docker-logs

HTTPD_IMAGE=`sudo docker load < /home/centos/pic-sure-ui.tar.gz | cut -d ' ' -f 3`
sudo docker run --name=httpd \
                --restart unless-stopped \
                --log-driver syslog --log-opt tag=httpd \
                -v /var/log/httpd-docker-logs/:/usr/local/apache2/logs/ \
                -v /usr/local/docker-config/picsureui_settings.json:/usr/local/apache2/htdocs/picsureui/settings/settings.json \
                -v /usr/local/docker-config/banner_config.json:/usr/local/apache2/htdocs/picsureui/banner_config.json \
                -v /home/centos/fence_mapping.json:/usr/local/apache2/htdocs/picsureui/studyAccess/studies-data.json \
                -v /usr/local/docker-config/cert:/usr/local/apache2/cert/ \
                -v /usr/local/docker-config/httpd-vhosts.conf:/usr/local/apache2/conf/extra/httpd-vhosts.conf \
                -p 443:443 -d $HTTPD_IMAGE

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources $${INSTANCE_ID} --tags Key=InitComplete,Value=true
