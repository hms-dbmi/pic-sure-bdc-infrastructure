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
sudo mkdir /home/centos/hpds
sudo chown centos:centos -R /home/centos
cd /home/centos/hpds
sudo yum -y install python3-pip
sudo pip3 install --no-input awscli --upgrade

