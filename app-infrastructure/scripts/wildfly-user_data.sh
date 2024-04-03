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
sudo systemctl restart SplunkForwarder || true

echo "user-data progress starting update"
sudo yum -y update

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}
# sleep for awhile because as these files are could still be in the process of being rendered.
# containerize already.
echo "waiting for terraform to render files"
sleep 600

s3_copy s3://${stack_s3_bucket}/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-wildfly.tar.gz /home/centos/pic-sure-wildfly.tar.gz
s3_copy s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/standalone.xml /home/centos/standalone.xml
s3_copy s3://${stack_s3_bucket}/modules/mysql/aws-module.xml /home/centos/mysql_module.xml
s3_copy s3://${stack_s3_bucket}/modules/mysql/aws-secretsmanager-jdbc-2.0.2.jar /home/centos/aws-secretsmanager-jdbc-2.0.2.jar
s3_copy s3://${stack_s3_bucket}/data/${dataset_s3_object_key}/fence_mapping.json /home/centos/fence_mapping.json
s3_copy s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/aggregate-resource.properties /home/centos/aggregate-resource.properties
s3_copy s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/visualization-resource.properties /home/centos/visualization-resource.properties

WILDFLY_IMAGE=`sudo docker load < /home/centos/pic-sure-wildfly.tar.gz | cut -d ' ' -f 3`
JAVA_OPTS="-Xms2g -Xmx26g -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=1024m -Djava.net.preferIPv4Stack=true -DTARGET_STACK=${target_stack}.${env_private_dns_name}"

sudo mkdir /var/log/{wildfly-docker-logs,wildfly-docker-os-logs}

sudo docker run -u root --name=wildfly \
                        --restart unless-stopped \
                        --log-driver syslog --log-opt tag=wildfly \
                        -v /var/log/wildfly-docker-logs/:/opt/jboss/wildfly/standalone/log/ \
                        -v /home/centos/standalone.xml:/opt/jboss/wildfly/standalone/configuration/standalone.xml \
                        -v /home/centos/fence_mapping.json:/usr/local/docker-config/fence_mapping.json \
                        -v /home/centos/aggregate-resource.properties:/opt/jboss/wildfly/standalone/configuration/aggregate-data-sharing/pic-sure-aggregate-resource/resource.properties \
                        -v /home/centos/mysql_module.xml:/opt/jboss/wildfly/modules/system/layers/base/com/sql/mysql/main/module.xml  \
                        -v /home/centos/aws-secretsmanager-jdbc-2.0.2.jar:/opt/jboss/wildfly/modules/system/layers/base/com/sql/mysql/main/aws-secretsmanager-jdbc-2.0.2.jar \
                        -v /var/log/wildfly-docker-os-logs/:/var/log/ \
                        -v /home/centos/visualization-resource.properties:/opt/jboss/wildfly/standalone/configuration/visualization/pic-sure-visualization-resource/resource.properties \
                        -p 8080:8080 -e JAVA_OPTS="$JAVA_OPTS" -d $WILDFLY_IMAGE

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources $${INSTANCE_ID} --tags Key=InitComplete,Value=true
