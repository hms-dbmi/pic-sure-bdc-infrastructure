#!/bin/bash

sudo sh /opt/srce/scripts/start-gsstools.sh

echo "user-data progress starting update"
sudo yum -y update

s3_copy() {
  local src=$1
  local dest=$2
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $src $dest "$@" && break || sleep 30
  done
}

mkdir -p /opt/local/hpds/all
s3_copy s3://${stack_s3_bucket}/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-hpds.tar.gz /home/centos/pic-sure-hpds.tar.gz
s3_copy s3://${stack_s3_bucket}/data/${dataset_s3_object_key}/javabins_rekeyed.tar.gz /opt/local/hpds/javabins_rekeyed.tar.gz
s3_copy s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/ /opt/local/hpds/all/ --recursive

cd /opt/local/hpds
tar -xvzf javabins_rekeyed.tar.gz
cd ~

HPDS_IMAGE=`sudo docker load < /home/centos/pic-sure-hpds.tar.gz | cut -d ' ' -f 3`
sudo docker run --name=auth-hpds \
                --restart unless-stopped \
                --log-driver syslog --log-opt tag=auth-hpds \
                -v /opt/local/hpds:/opt/local/hpds \
                -p 8080:8080 \
                --entrypoint=java -d $HPDS_IMAGE \
                -XX:+UseParallelGC -XX:SurvivorRatio=250 -Xms10g -Xmx110g -server -jar hpds.jar \
                -httpPort 8080 -DCACHE_SIZE=2500 -DSMALL_TASK_THREADS=1 -DLARGE_TASK_THREADS=1 -DSMALL_JOB_LIMIT=100 -DID_BATCH_SIZE=5000 "-DALL_IDS_CONCEPT=NONE"  "-DID_CUBE_NAME=NONE"

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources $${INSTANCE_ID} --tags Key=InitComplete,Value=true
