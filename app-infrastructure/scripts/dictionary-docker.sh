#!/bin/bash

stack_s3_bucket=$1
dataset_s3_object_key=$2

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

s3_copy s3://${stack_s3_bucket}/releases/pic-sure-hpds-dictionary-resource.tar.gz /home/centos/pic-sure-hpds-dictionary-resource.tar.gz

s3_copy s3://${stack_s3_bucket}/data/${dataset_s3_object_key}/fence_mapping.json /home/centos/fence_mapping.json
echo "pulled fence mapping"

sudo mkdir -p /usr/local/docker-config/search/
sudo mkdir -p /var/log/dictionary-docker-logs

DICTIONARY_IMAGE=`sudo docker load < /home/centos/pic-sure-hpds-dictionary-resource.tar.gz | cut -d ' ' -f 3`
sudo docker run --name=dictionary \
                --log-driver syslog --log-opt tag=dictionary \
                -v /var/log/dictionary-docker-logs/:/usr/local/tomcat/logs/ \
                -v /home/centos/fence_mapping.json:/usr/local/docker-config/search/fence_mapping.json \
                -e CATALINA_OPTS=" -Xms1g -Xmx12g " \
                -p 8080:8080 -d $DICTIONARY_IMAGE