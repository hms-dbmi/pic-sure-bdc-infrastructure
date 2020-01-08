#!/usr/bin/env bash
mkdir -p /usr/local/docker-config/cert
mkdir -p /var/log/httpd-docker-logs/ssl_mutex
for i in 1 2 3 4 5 6 7 8 9; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://${stack_s3_bucket}/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-ui.tar.gz . && break || sleep 45; done
for i in 1 2 3 4 5; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/httpd-vhosts.conf /usr/local/docker-config/httpd-vhosts.conf && break || sleep 15; done
for i in 1 2 3 4 5; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://${stack_s3_bucket}/certs/httpd/server.chain /usr/local/docker-config/cert/server.chain && break || sleep 15; done
for i in 1 2 3 4 5; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://${stack_s3_bucket}/certs/httpd/server.crt /usr/local/docker-config/cert/server.crt && break || sleep 15; done
for i in 1 2 3 4 5; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://${stack_s3_bucket}/certs/httpd/server.key /usr/local/docker-config/cert/server.key && break || sleep 15; done
for i in 1 2 3 4 5; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/psamaui_settings.json /usr/local/docker-config/psamaui_settings.json && break || sleep 15; done
for i in 1 2 3 4 5; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://${stack_s3_bucket}/configs/jenkins_pipeline_build_${stack_githash}/picsureui_settings.json /usr/local/docker-config/picsureui_settings.json && break || sleep 15; done

HTTPD_IMAGE=`sudo docker load < pic-sure-ui.tar.gz | cut -d ' ' -f 3`
sudo docker run -v /var/log/httpd-docker-logs/:/usr/local/apache2/logs/ -v /usr/local/docker-config/picsureui_settings.json:/usr/local/apache2/htdocs/picsureui/settings/settings.json -v /usr/local/docker-config/psamaui_settings.json:/usr/local/apache2/htdocs/psamaui/settings/settings.json -v /usr/local/docker-config/cert:/usr/local/apache2/cert/ -v /usr/local/docker-config/httpd-vhosts.conf:/usr/local/apache2/conf/extra/httpd-vhosts.conf -p 80:80 -p 443:443 -d $HTTPD_IMAGE
