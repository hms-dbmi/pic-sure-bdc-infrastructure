#!/bin/bash
stack_s3_bucket=$1

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

## pull configs and images from s3
s3_copy "s3://${stack_s3_bucket}/configs/picsure-dictionary/picsure-dictionary.env" "/home/centos/picsure-dictionary.env"
s3_copy "s3://${stack_s3_bucket}/containers/application/dictionary-api.tar.gz" "/home/centos/dictionary-api.tar.gz"

# load docker images
DICTIONARY_API_IMAGE=`sudo docker load < /home/centos/dictionary-api.tar.gz | cut -d ' ' -f 3`
JAVA_OPTS="-Xmx16g"

sudo docker stop dictionary-api
sudo docker rm dictionary-api
sudo docker run \
      -e $JAVA_OPTS \
      --env-file /home/centos/picsure-dictionary.env \
      --name dictionary-api \
      --restart always \
      --network picsure \
      --log-driver syslog --log-opt tag=dictionary-api \
      --restart always \
      -d $DICTIONARY_API_IMAGE