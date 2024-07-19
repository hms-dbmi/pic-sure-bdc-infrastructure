#!/bin/bash

stack_s3_bucket=$1
dataset_s3_object_key=$2
genomic_dataset_s3_object_key=$3

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

mkdir -p /opt/local/hpds/all
s3_copy s3://${stack_s3_bucket}/releases/pic-sure-hpds.tar.gz /home/centos/pic-sure-hpds.tar.gz
s3_copy s3://${stack_s3_bucket}/data/${dataset_s3_object_key}/javabins_rekeyed.tar.gz /opt/local/hpds/javabins_rekeyed.tar.gz
s3_copy s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/ /opt/local/hpds/all/ --recursive

cd /opt/local/hpds
tar -xvzf javabins_rekeyed.tar.gz
cd ~

# Load and run docker container.  Then wait for initialization before tagging instance as init complete.
echo "Loading and running docker container"
INIT_MESSAGE="WebApplicationContext: initialization completed"
INIT_TIMEOUT_SECS=2400  # Set your desired timeout in seconds
INIT_START_TIME=$(date +%s)

CONTAINER_NAME="auth-hpds"

HPDS_IMAGE=`sudo docker load < /home/centos/pic-sure-hpds.tar.gz | cut -d ' ' -f 3`
sudo docker run --name=$CONTAINER_NAME \
                --restart unless-stopped \
                --log-driver syslog --log-opt tag=auth-hpds \
                -v /opt/local/hpds:/opt/local/hpds \
                -p 8080:8080 \
                -e JAVA_OPTS=" -XX:+UseParallelGC -XX:SurvivorRatio=250 -Xms10g -Xmx128g -Dserver.port=8080 -Dspring.profiles.active=bdc-auth -DCACHE_SIZE=2500 -DID_BATCH_SIZE=5000 -DALL_IDS_CONCEPT=NONE -DID_CUBE_NAME=NONE "  \
                -d $HPDS_IMAGE

