#!/bin/bash

stack_s3_bucket=$1
stack_githash=$2

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

mkdir -p /opt/local/hpds/all
s3_copy s3://${stack_s3_bucket}/releases/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-hpds.tar.gz /home/centos/pic-sure-hpds.tar.gz

CONTAINER_NAME="auth-hpds"

HPDS_IMAGE=`sudo docker load < /home/centos/pic-sure-hpds.tar.gz | cut -d ' ' -f 3`
sudo docker run --name=$CONTAINER_NAME \
                --restart unless-stopped \
                --log-driver syslog --log-opt tag=auth-hpds \
                -v /opt/local/hpds:/opt/local/hpds \
                -p 8080:8080 \
                -e JAVA_OPTS=" -XX:+UseParallelGC -XX:SurvivorRatio=250 -Xms10g -Xmx128g -Dserver.port=8080 -Dspring.profiles.active=bdc-auth -DCACHE_SIZE=2500 -DID_BATCH_SIZE=5000 -DALL_IDS_CONCEPT=NONE -DID_CUBE_NAME=NONE "  \
                -d $HPDS_IMAGE