#!/bin/bash

while [[ $# -gt 0 ]]; do
  case $1 in
    --stack_s3_bucket)
      stack_s3_bucket="$2"
      shift 2
      ;;
    --stack_githash)
      stack_githash="$2"
      shift 2
      ;;
    --destigmatized_dataset_s3_object_key)
      destigmatized_dataset_s3_object_key="$2"
      shift 2
      ;;
    --target_stack)
      target_stack="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$stack_s3_bucket" || -z "$stack_githash" || -z "$destigmatized_dataset_s3_object_key" ]]; then
  echo "Error: --stack_s3_bucket, --stack_githash and --destigmatized_dataset_s3_object_key are required"
  exit 1
fi

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/pic-sure-hpds.tar.gz" "/home/centos/pic-sure-hpds.tar.gz"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/data/${destigmatized_dataset_s3_object_key}/destigmatized_javabins_rekeyed.tar" "/opt/local/hpds/destigmatized_javabins_rekeyed.tar"

CONTAINER_NAME="open-hpds"
HPDS_IMAGE=$(sudo docker load < /home/centos/pic-sure-hpds.tar.gz | cut -d ' ' -f 3)
sudo docker run --name=$CONTAINER_NAME \
                --restart unless-stopped \
                --log-driver syslog --log-opt tag=open-hpds \
                -v /opt/local/hpds:/opt/local/hpds \
                -p 8080:8080 \
                -e JAVA_OPTS=" -XX:+UseParallelGC -XX:SurvivorRatio=250 -Xms10g -Xmx40g -Dserver.port=8080 -Dspring.profiles.active=open -DCACHE_SIZE=2500 -DSMALL_TASK_THREADS=1 -DLARGE_TASK_THREADS=1 -DSMALL_JOB_LIMIT=100 -DID_BATCH_SIZE=5000 " \
                -d "$HPDS_IMAGE"