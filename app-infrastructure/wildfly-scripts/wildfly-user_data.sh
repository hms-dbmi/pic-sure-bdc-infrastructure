#!/usr/bin/env bash
echo "user-data progress starting update"
sudo yum -y update 
echo "user-data progress finished update installing epel-release"
sudo yum -y install epel-release 
echo "user-data progress finished epel-release starting python-pip"
sudo yum -y install python-pip 
sudo pip install --upgrade pip
echo "user-data progress finished python-pip starting docker-compose"
yes | sudo pip install --ignore-installed requests docker-compose
echo "user-data progress finished docker-compose adding docker-ce repo"
sudo yum-config-manager  --add-repo https://download.docker.com/linux/centos/docker-ce.repo
echo "user-data progress added docker-ce repo starting docker install"
sudo yum -y install docker-ce docker-ce-cli containerd.io
echo "user-data progress finished docker install enabling docker service"
sudo systemctl enable docker
echo "user-data progress finished enabling docker service starting docker"
sudo service docker start
cd /home/centos/
mkdir wildfly
cd wildfly

aws s3 cp s3://avillach-datastage-pic-sure-jenkins-dev-builds-3/releases/jenkins_pipeline_build_stack_githash/pic-sure-wildfly.tar.gz .

WILDFLY_IMAGE=`docker load pic-sure-wildfly.tar.gz | cud -d ' ' -f 3'
JAVA_OPTS="-Xms1024m -Xmx2g -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=256m -Djava.net.preferIPv4Stack=true"
docker run \ 
    -v /var/log/wildfly-docker-logs/:/opt/jboss/wildfly/standalone/logs \
    -v /var/log/wildfly-docker-os-logs/:/var/log \
    -p 8080:8080 \
    -d \
    $WILDFLY_IMAGE
