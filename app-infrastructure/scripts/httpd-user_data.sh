#!/usr/bin/env bash
#echo "user-data progress starting update"
#sudo yum -y update 
#echo "user-data progress finished update installing epel-release"
#sudo yum-config-manager  --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#echo "user-data progress added docker-ce repo starting docker install"
#sudo yum -y install docker-ce docker-ce-cli containerd.io
#echo "user-data progress finished docker install enabling docker service"
#sudo systemctl enable docker
#echo "user-data progress finished enabling docker service starting docker"
#sudo service docker start
#sudo mkdir /home/centos/httpd
#sudo chown centos:centos -R /home/centos
#cd /home/centos/httpd
#sudo yum -y install python3-pip
#sudo pip3 install --no-input awscli --upgrade
#sudo /usr/local/bin/aws s3 cp s3://avillach-datastage-pic-sure-jenkins-dev-builds-3/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-hpds-copdgene-ui.tar.gz .

HTTPD_IMAGE=`sudo docker load < pic-sure-hpds-copdgene-ui.tar.gz | cut -d ' ' -f 3`
sudo docker run -v /var/log/httpd-docker-logs/:/var/log -p 80:80 -p 443:443 -d $HTTPD_IMAGE
