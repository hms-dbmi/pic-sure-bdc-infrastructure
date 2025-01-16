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
   --dataset_s3_object_key)
      dataset_s3_object_key="$2"
      shift 2
      ;;
    --genomic_dataset_s3_object_key)
      genomic_dataset_s3_object_key="$2"
      shift 2
      ;;
    --environment_name)
      environment_name="$2"
      shift 2
      ;;
    --target_stack)
      target_stack="$2"
      shift 2
      ;;
    --env_private_dns_name)
      env_private_dns_name="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$stack_s3_bucket" || -z "$stack_githash" || -z "$genomic_dataset_s3_object_key" || -z "$dataset_s3_object_key" || -z "$environment_name" || -z "$target_stack" || -z "$env_private_dns_name" ]]; then
  echo "Error: --stack_s3_bucket, --stack_githash, --genomic_dataset_s3_object_key, --dataset_s3_object_key, --environment_name, --target_stack, and --env_private_dns_name are required"
  exit 1
fi

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/pic-sure-hpds.tar.gz" "/home/centos/pic-sure-hpds.tar.gz"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/data/${dataset_s3_object_key}/javabins_rekeyed.tar" "/opt/local/hpds/javabins_rekeyed.tar"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/data/${genomic_dataset_s3_object_key}/all/" "/opt/local/hpds/all/" --recursive

HPDS_IMAGE=$(sudo docker load < /home/centos/pic-sure-hpds.tar.gz | cut -d ' ' -f 3)
sudo docker stop auth-hpds || true
sudo docker rm auth-hpds || true
sudo docker run --name=auth-hpds \
                --restart unless-stopped \
                --log-driver syslog --log-opt tag=auth-hpds \
                -v /opt/local/hpds:/opt/local/hpds \
                -p 8080:8080 \
                -e JAVA_OPTS=" -XX:+UseParallelGC -XX:SurvivorRatio=250 -Xms10g -Xmx128g -Dserver.port=8080 -Dspring.profiles.active=bdc-auth-${environment_name} -DTARGET_STACK=${target_stack}.${env_private_dns_name} -DCACHE_SIZE=2500 -DID_BATCH_SIZE=5000 -DALL_IDS_CONCEPT=NONE -DID_CUBE_NAME=NONE "  \
                -d "$HPDS_IMAGE"