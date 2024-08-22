#!/bin/bash
stack_s3_bucket=$1

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

## pull configs and images from s3
s3_copy "s3://${stack_s3_bucket}/configs/dictionary/weights.csv" "/home/centos/weights.csv"
s3_copy "s3://${stack_s3_bucket}/containers/application/dictionary-api.tar.gz" "/home/centos/dictionary-api.tar.gz"
s3_copy "s3://${stack_s3_bucket}/containers/application/dictionary-weights.tar.gz" "/home/centos/dictionary-weights.tar.gz"

# load docker images
DICTIONARY_API_IMAGE=`sudo docker load < /home/centos/dictionary-api.tar.gz | cut -d ' ' -f 3`
DICTIONARY_WEIGHTS_IMAGE=`sudo docker load < /home/centos/dictionary-weights.tar.gz | cut -d ' ' -f 3`

# a blank env files.  db connections will need to use secrets manager
touch .env

# run containers
# Going to try the picsure network....

sudo docker run \
      --name dictionary-api \
      --restart always \
      --env-file=.env \
      --network picsure \
      --log-driver syslog --log-opt tag=dictionary-api \
      --restart always \
      -d $DICTIONARY_API_IMAGE

sudo docker run \
      --restart always \
      --name dictionary-weights \
      --env-file=.env \
      --network picsure \
      --log-driver syslog --log-opt tag=dictionary-weights \
      -v /home/centos/weights.csv:/weights.csv \
      -d $DICTIONARY_WEIGHTS_IMAGE
