#!/bin/bash
echo "ENABLE_PODMAN=true" | sudo tee -a /opt/srce/startup.config
echo "SPLUNK_INDEX=hms_aws_${gss_prefix}" | sudo tee -a /opt/srce/startup.config
echo "NESSUS_GROUP=${gss_prefix}_${target_stack}" | sudo tee -a /opt/srce/startup.config

sudo sh /opt/srce/scripts/start-gsstools.sh
sudo systemctl stop SplunkForwarder
/opt/splunkforwarder/bin/splunk enable boot-start -systemd-managed 1 -user splunk || true

mkdir -p /usr/local/docker-config/cert
sudo mkdir -p /var/log/picsure/httpd/
sudo mkdir -p /var/log/picsure/httpd/ssl_mutex

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

s3_copy s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/httpd-vhosts.conf /usr/local/docker-config/httpd-vhosts.conf
s3_copy s3://${stack_s3_bucket}/certs/httpd/ /usr/local/docker-config/cert/ --recursive
s3_copy s3://${stack_s3_bucket}/data/${dataset_s3_object_key}/fence_mapping.json /opt/picsure/fence_mapping.json
s3_copy s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/httpd-docker.sh /opt/picsure/httpd-docker.sh

for i in 1 2 3 4 5; do echo "confirming wildfly resolvable" && sudo curl --connect-timeout 1 $(grep -A30 preprod /usr/local/docker-config/httpd-vhosts.conf | grep wildfly | grep api | cut -d "\"" -f 2 | sed 's/pic-sure-api-2.*//') || if [ $? = 6 ]; then (exit 1); fi && break || sleep 60; done

sudo chmod +x /opt/picsure/httpd-docker.sh

sudo /opt/picsure/httpd-docker.sh "${stack_s3_bucket}" "${stack_githash}"

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources $${INSTANCE_ID} --tags Key=InitComplete,Value=true


echo "Restart splunkforwarder service"
sudo systemctl restart SplunkForwarder
echo "user-data progress starting update"
sudo yum -y update