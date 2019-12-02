#!/usr/bin/env bash

sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://avillach-datastage-pic-sure-jenkins-dev-builds-3/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-hpds-copdgene-ui.tar.gz .
HTTPD_IMAGE=`sudo docker load < pic-sure-hpds-copdgene-ui.tar.gz | cut -d ' ' -f 3`
sudo docker run -v /var/log/httpd-docker-logs/:/var/log -p 80:80 -p 443:443 -d $HTTPD_IMAGE
