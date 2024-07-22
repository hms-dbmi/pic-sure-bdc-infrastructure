#!/bin/bash

stack_s3_bucket=$1
destigmatized_dataset_s3_object_key=$2

s3_copy s3://${stack_s3_bucket}/data/${destigmatized_dataset_s3_object_key}/destigmatized_javabins_rekeyed.tar.gz /opt/local/hpds/destigmatized_javabins_rekeyed.tar.gz

cd /opt/local/hpds
tar -xvzf destigmatized_javabins_rekeyed.tar.gz
cd ~