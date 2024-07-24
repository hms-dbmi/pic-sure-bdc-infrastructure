#!/bin/bash

# except values for target_stack and env_private_dns_name as $1 and $2
target_stack=$1
env_private_dns_name=$2
stack_s3_bucket=$3
dataset_s3_object_key=$4
stack_githash=$5

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/releases/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-wildfly.tar.gz" "/home/centos/pic-sure-wildfly.tar.gz"
s3_copy "s3://${stack_s3_bucket}/configs/standalone.xml" "/home/centos/standalone.xml"
s3_copy "s3://${stack_s3_bucket}/data/${dataset_s3_object_key}/fence_mapping.json" "/home/centos/fence_mapping.json"
s3_copy "s3://${stack_s3_bucket}/configs/aggregate-resource.properties" "/home/centos/aggregate-resource.properties"
s3_copy "s3://${stack_s3_bucket}/configs/visualization-resource.properties" "/home/centos/visualization-resource.properties"


WILDFLY_IMAGE=`sudo docker load < /home/centos/pic-sure-wildfly.tar.gz | cut -d ' ' -f 3`
JAVA_OPTS="-Xms2g -Xmx24g -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=1024m -Djava.net.preferIPv4Stack=true -DTARGET_STACK=${target_stack}.${env_private_dns_name}"

sudo docker run -u root --name=wildfly --network=picsure \
                        --restart unless-stopped \
                        --log-driver syslog --log-opt tag=wildfly \
                        -v /var/log/wildfly-docker-logs/:/opt/jboss/wildfly/standalone/log/ \
                        -v /home/centos/standalone.xml:/opt/jboss/wildfly/standalone/configuration/standalone.xml \
                        -v /home/centos/fence_mapping.json:/usr/local/docker-config/fence_mapping.json \
                        -v /home/centos/aggregate-resource.properties:/opt/jboss/wildfly/standalone/configuration/aggregate-data-sharing/pic-sure-aggregate-resource/resource.properties \
                        -v /var/log/wildfly-docker-os-logs/:/var/log/ \
                        -v /home/centos/visualization-resource.properties:/opt/jboss/wildfly/standalone/configuration/visualization/pic-sure-visualization-resource/resource.properties \
                        -p 8080:8080 -e JAVA_OPTS="$JAVA_OPTS" -d $WILDFLY_IMAGE