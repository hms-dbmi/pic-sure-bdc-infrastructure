#!/bin/bash

# except values for target_stack and env_private_dns_name as $1 and $2
target_stack=$1
env_private_dns_name=$2
stack_s3_bucket=$3
stack_githash=$4
dataset_s3_object_key=$5

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-wildfly.tar.gz" "/opt/picsure/pic-sure-wildfly.tar.gz"
s3_copy "s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/standalone.xml" "/opt/picsure/standalone.xml"
s3_copy "s3://${stack_s3_bucket}/data/${dataset_s3_object_key}/fence_mapping.json" "/opt/picsure/fence_mapping.json"
s3_copy "s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/aggregate-resource.properties" "/opt/picsure/aggregate-resource.properties"
s3_copy "s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/visualization-resource.properties" "/opt/picsure/visualization-resource.properties"


WILDFLY_IMAGE=`sudo docker load < /opt/picsure/pic-sure-wildfly.tar.gz | cut -d ' ' -f 3`
JAVA_OPTS="-Xms2g -Xmx24g -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=1024m -Djava.net.preferIPv4Stack=true -DTARGET_STACK=${target_stack}.${env_private_dns_name}"

sudo docker run -u root --name=wildfly \
                        --restart unless-stopped \
                        --log-driver syslog --log-opt tag=wildfly \
                        -v /var/log/wildfly-docker-logs/:/opt/jboss/wildfly/standalone/log/ \
                        -v /opt/picsure/standalone.xml:/opt/jboss/wildfly/standalone/configuration/standalone.xml \
                        -v /opt/picsure/fence_mapping.json:/usr/local/docker-config/fence_mapping.json \
                        -v /opt/picsure/aggregate-resource.properties:/opt/jboss/wildfly/standalone/configuration/aggregate-data-sharing/pic-sure-aggregate-resource/resource.properties \
                        -v /var/log/wildfly-docker-os-logs/:/var/log/ \
                        -v /opt/picsure/visualization-resource.properties:/opt/jboss/wildfly/standalone/configuration/visualization/pic-sure-visualization-resource/resource.properties \
                        -p 8080:8080 -e JAVA_OPTS="$JAVA_OPTS" -d $WILDFLY_IMAGE
