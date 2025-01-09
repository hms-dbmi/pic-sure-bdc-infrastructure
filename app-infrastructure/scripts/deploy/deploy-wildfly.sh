#!/bin/bash

# except values for target_stack and env_private_dns_name as $1 and $2
target_stack=$1
env_private_dns_name=$2
stack_s3_bucket=$3
stack_githash=$4

# Parse named arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --stack_s3_bucket)
      stack_s3_bucket="$2"
      shift 2
      ;;
    --target_stack)
      target_stack="$2"
      shift 2
      ;;
    --env_private_dns_name)
      env_private_dns_name="$2"
      shift 2
      ;;
    --stack_githash)
      stack_githash="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$stack_s3_bucket" || -z "$stack_githash" || -z "$target_stack" || -z "$env_private_dns_name" ]]; then
  echo "Error: --stack_s3_bucket, --stack_githash, --target_stack, and --env_private_dns_name are required."
  exit 1
fi

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-wildfly.tar.gz" "/home/centos/pic-sure-wildfly.tar.gz"
s3_copy "s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/standalone.xml" "/home/centos/standalone.xml"
s3_copy "s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/aggregate-resource.properties" "/home/centos/aggregate-resource.properties"
s3_copy "s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/visualization-resource.properties" "/home/centos/visualization-resource.properties"

WILDFLY_IMAGE=$(sudo docker load < /home/centos/pic-sure-wildfly.tar.gz | cut -d ' ' -f 3)
JAVA_OPTS="-Xms2g -Xmx24g -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=1024m -Djava.net.preferIPv4Stack=true -DTARGET_STACK=${target_stack}.${env_private_dns_name}"

sudo docker run -u root --name=wildfly --network=picsure \
                        --restart unless-stopped \
                        --log-driver syslog --log-opt tag=wildfly \
                        -v /var/log/wildfly-docker-logs/:/opt/jboss/wildfly/standalone/log/ \
                        -v /home/centos/standalone.xml:/opt/jboss/wildfly/standalone/configuration/standalone.xml \
                        -v /home/centos/aggregate-resource.properties:/opt/jboss/wildfly/standalone/configuration/aggregate-data-sharing/pic-sure-aggregate-resource/resource.properties \
                        -v /var/log/wildfly-docker-os-logs/:/var/log/ \
                        -v /home/centos/visualization-resource.properties:/opt/jboss/wildfly/standalone/configuration/visualization/pic-sure-visualization-resource/resource.properties \
                        -p 8080:8080 -e JAVA_OPTS="$JAVA_OPTS" -d "$WILDFLY_IMAGE"
