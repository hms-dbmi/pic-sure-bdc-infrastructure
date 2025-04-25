#!/bin/bash

stack_s3_bucket=$1
stack_githash=$2

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

s3_copy s3://${stack_s3_bucket}/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-frontend.tar.gz /opt/picsure/pic-sure-frontend.tar.gz

podman stop httpd || true
podman rm httpd || true
podman system prune -a -f || true

chmod o+rx /usr/local/docker-config
chmod o+rx /usr/local/docker-config/cert
chmod o+rx /opt/picsure

find /opt/picsure -type f ! -name ".*" -exec chmod 644 {} \;
find /usr/local/docker-config -type f ! -name ".*" -exec chmod 644 {} \;
find /usr/local/docker-config/cert -type f ! -name "*.key" -exec chmod 644 {} \;
find /usr/local/docker-config/cert -type f -name "*.key" -exec chmod 600 {} \;

HTTPD_IMAGE=`podman load < /opt/picsure/pic-sure-frontend.tar.gz | cut -d ' ' -f 3`

CONTAINER_NAME=httpd

podman run --privileged -u root --name=$CONTAINER_NAME \
--log-opt tag=$CONTAINER_NAME \
-v /var/log/picsure/httpd/:/usr/local/apache2/logs/:Z \
-v /opt/picsure/fence_mapping.json:/usr/local/apache2/htdocs/picsureui/studyAccess/studies-data.json:Z \
-v /usr/local/docker-config/cert:/usr/local/apache2/cert/:Z \
-v /usr/local/docker-config/httpd-vhosts.conf:/usr/local/apache2/conf/extra/httpd-vhosts.conf:Z \
-p 443:443 -d $HTTPD_IMAGE