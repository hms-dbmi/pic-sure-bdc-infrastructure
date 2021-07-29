#!/usr/bin/env bash
echo "user-data progress starting update"
sudo yum -y update
echo "user-data progress finished update installing epel-release"
sudo yum-config-manager  --add-repo https://download.docker.com/linux/centos/docker-ce.repo
echo "user-data progress added docker-ce repo starting docker install"
sudo yum -y install docker-ce docker-ce-cli containerd.io
echo "user-data progress finished docker install enabling docker service"
sudo systemctl enable docker
echo "user-data progress finished enabling docker service starting docker"
sudo service docker start
sudo mkdir /home/centos/wildfly
sudo chown centos:centos -R /home/centos
cd /home/centos/wildfly
sudo yum -y install python3-pip
sudo pip3 install --no-input awscli --upgrade
# not sure why the binary was installing without exec privileges
sudo chmod +x /usr/local/bin/aws

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo hostnamectl set-hostname ${INSTANCE_ID}
sudo /usr/local/bin/aws --region=us-east-1 ec2 create-tags --resources ${INSTANCE_ID} --tags Key=InitComplete,Value=true
