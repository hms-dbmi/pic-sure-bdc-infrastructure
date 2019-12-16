#!/usr/bin/env bash

for i in 1 2 3 4 5; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://avillach-datastage-pic-sure-jenkins-dev-builds-3/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-hpds-copdgene-ui.tar.gz . && break || sleep 45; done
HTTPD_IMAGE=`sudo docker load < pic-sure-hpds-copdgene-ui.tar.gz | cut -d ' ' -f 3`
sudo docker run -v /var/log/httpd-docker-logs/:/usr/local/apache2/logs/ -v /usr/local/docker-config/picsure_settings.json:/usr/local/apache2/htdocs/picsureui/settings/settings.json -v /usr/local/docker-config/psama_settings.json:/usr/local/apache2/htdocs/psamaui/settings/settings.json -v /usr/local/docker-config/:/usr/local/apache2/cert/ -v /usr/local/docker-config/httpd-vhosts.conf:/usr/local/apache2/conf/extra/httpd-vhosts.conf -p 80:80 -p 443:443 -d $HTTPD_IMAGE
