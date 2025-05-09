#!/bin/bash

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
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

stack_s3_bucket=${stack_s3_bucket:-STACK_S3_BUCKET}
env_private_dns_name=${env_private_dns_name:-ENV_PRIVATE_DNS_NAME}
target_stack=${target_stack:-TARGET_STACK}

if [[ -z "$stack_s3_bucket" || -z "$env_private_dns_name" || -z "$target_stack" ]]; then
  echo "Error: --stack_s3_bucket, --stack_githash, --target_stack, and --env_private_dns_name are required."
  exit 1
fi

# Main S3 copy function with retries
s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/pic-sure-wildfly.tar.gz" "/opt/picsure/pic-sure-wildfly.tar.gz"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/configs/wildfly/standalone.xml" "/opt/picsure/standalone.xml"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/configs/wildfly/aggregate-resource.properties" "/opt/picsure/aggregate-resource.properties"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/configs/wildfly/visualization-resource.properties" "/opt/picsure/visualization-resource.properties"

CONTAINER_WILDFLY="wildfly"
WILDFLY_IMAGE=$(podman load < /opt/picsure/pic-sure-wildfly.tar.gz | cut -d ' ' -f 3)
JAVA_OPTS="-Xms2g -Xmx24g -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=1024m -Djava.net.preferIPv4Stack=true -DTARGET_STACK=${target_stack}.${env_private_dns_name}"

podman rm -f $CONTAINER_NAME

podman run -u root --name=$CONTAINER_NAME --network=picsure \
    --dns=10.89.0.1 \
    --log-opt tag=$CONTAINER_NAME \
    -v /var/log/picsure/wildfly/:/opt/jboss/wildfly/standalone/log/:Z \
    -v /opt/picsure/standalone.xml:/opt/jboss/wildfly/standalone/configuration/standalone.xml:Z \
    -v /opt/picsure/fence_mapping.json:/usr/local/docker-config/fence_mapping.json:z \
    -v /opt/picsure/aggregate-resource.properties:/opt/jboss/wildfly/standalone/configuration/aggregate-data-sharing/pic-sure-aggregate-resource/resource.properties:Z \
    -v /opt/picsure/visualization-resource.properties:/opt/jboss/wildfly/standalone/configuration/visualization/pic-sure-visualization-resource/resource.properties:Z \
    -p 8080:8080 -e JAVA_OPTS="$JAVA_OPTS" -d $WILDFLY_IMAGE

# systemd setup.
podman generate systemd --name $CONTAINER_NAME --restart-policy=always --files

sudo mv container-$CONTAINER_NAME.service /etc/systemd/system/

sudo restorecon -v /etc/systemd/system/container-$CONTAINER_NAME.service

sudo mv container-$CONTAINER_NAME.service /etc/systemd/system/
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable container-$CONTAINER_NAME.service
sudo systemctl restart container-$CONTAINER_NAME.service

echo "Verifying container-$CONTAINER_NAME.service status..."
sudo systemctl is-enabled container-$CONTAINER_NAME.service
sudo systemctl status container-$CONTAINER_NAME.service --no-pager
