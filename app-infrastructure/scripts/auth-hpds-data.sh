#!/bin/bash

stack_s3_bucket=$1
dataset_s3_object_key=$2
genomic_dataset_s3_object_key=$3

s3_copy s3://${stack_s3_bucket}/data/${dataset_s3_object_key}/javabins_rekeyed.tar.gz /opt/local/hpds/javabins_rekeyed.tar.gz
s3_copy s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/ /opt/local/hpds/all/ --recursive

cd /opt/local/hpds
tar -xvzf javabins_rekeyed.tar.gz
cd ~