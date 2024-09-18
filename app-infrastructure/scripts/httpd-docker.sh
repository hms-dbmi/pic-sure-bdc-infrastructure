#!/bin/bash

stack_s3_bucket=$1
stack_githash=$2

s3_copy s3://${stack_s3_bucket}/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-frontend.tar.gz /home/centos/pic-sure-frontend.tar.gz

HTTPD_IMAGE=`sudo docker load < /home/centos/pic-sure-frontend.tar.gz | cut -d ' ' -f 3`
sudo docker stop httpd || true
sudo docker rm httpd || true
sudo docker run --name=httpd \
                --restart unless-stopped \
                --log-driver syslog --log-opt tag=httpd \
                -v /var/log/httpd-docker-logs/:/usr/local/apache2/logs/ \
                -v /home/centos/fence_mapping.json:/usr/local/apache2/htdocs/picsureui/studyAccess/studies-data.json \
                -v /usr/local/docker-config/cert:/usr/local/apache2/cert/ \
                -v /usr/local/docker-config/httpd-vhosts.conf:/usr/local/apache2/conf/extra/httpd-vhosts.conf \
                -p 443:443 -d $HTTPD_IMAGE