#!/bin/bash

# TODO: Use stack githash to version the uploads.

# Parse named arguments
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
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/configs/picsure-dictionary/picsure-dictionary.env" "/home/centos/picsure-dictionary.env"
s3_copy "s3://${stack_s3_bucket}/containers/application/dictionary-api.tar.gz" "/home/centos/dictionary-api.tar.gz"

DICTIONARY_API_IMAGE=$(sudo docker load < /home/centos/dictionary-api.tar.gz | cut -d ' ' -f 3)
JAVA_OPTS=" -Xmx8g "

sudo docker stop dictionary-api
sudo docker rm dictionary-api
sudo docker run \
      -e JAVA_OPTS="$JAVA_OPTS" \
      --env-file /home/centos/picsure-dictionary.env \
      --name dictionary-api \
      --restart always \
      --network picsure \
      --log-driver syslog --log-opt tag=dictionary-api \
      --restart always \
      -d "$DICTIONARY_API_IMAGE"