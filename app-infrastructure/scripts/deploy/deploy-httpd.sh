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

if [[ -z "$stack_s3_bucket" || -z "$stack_githash" ]]; then
  echo "Error: --stack_s3_bucket and --dataset_s3_object_key are required."
  exit 1
fi

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/pic-sure-frontend.tar.gz" "/home/centos/pic-sure-frontend.tar.gz"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/configs/httpd-vhosts.conf" "/usr/local/docker-config/httpd-vhosts.conf"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/certs/httpd/" "/usr/local/docker-config/cert/" --recursive

sudo docker stop httpd || true
sudo docker rm httpd || true
sudo docker system prune -a -f || true

HTTPD_IMAGE=$(sudo docker load < /home/centos/pic-sure-frontend.tar.gz | cut -d ' ' -f 3)
sudo docker run --name=httpd \
--restart unless-stopped \
--log-driver syslog --log-opt tag=httpd \
-v /var/log/httpd-docker-logs/:/usr/local/apache2/logs/ \
-v /usr/local/docker-config/cert:/usr/local/apache2/cert/ \
-v /usr/local/docker-config/httpd-vhosts.conf:/usr/local/apache2/conf/extra/httpd-vhosts.conf \
-p 443:443 -d "$HTTPD_IMAGE"