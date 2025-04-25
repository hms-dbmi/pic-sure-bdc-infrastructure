#!/bin/bash
stack_s3_bucket=$1

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

## pull configs and images from s3
s3_copy "s3://${stack_s3_bucket}/configs/picsure-dictionary/picsure-dictionary.env" "/opt/picsure/picsure-dictionary.env"
s3_copy "s3://${stack_s3_bucket}/containers/application/dictionary-api.tar.gz" "/opt/picsure/dictionary-api.tar.gz"

# load docker images
DICTIONARY_API_IMAGE=`podman load < /opt/picsure/dictionary-api.tar.gz | cut -d ' ' -f 3`

CONTAINER_NAME=dictionary-api
JAVA_OPTS=" -Xmx8g "

podman rm -f $CONTAINER_NAME | true

podman run --privileged --name=$CONTAINER_NAME \
      --dns=10.89.0.1 \
      --log-opt tag=$CONTAINER_NAME \
      --env-file /opt/picsure/picsure-dictionary.env \
      --name dictionary-api \
      --network picsure \
      -v /var/log/picsure/dictionary/:/var/log/ \
      -e JAVA_OPTS="$JAVA_OPTS" \
      -d $DICTIONARY_API_IMAGE

# systemd setup.
podman generate systemd --name $CONTAINER_NAME --restart-policy=always --files

sudo mv container-$CONTAINER_NAME.service /etc/systemd/system/

sudo restorecon -v /etc/systemd/system/container-$CONTAINER_NAME.service

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable container-$CONTAINER_NAME.service
sudo systemctl restart container-$CONTAINER_NAME.service

echo "Verifying container-$CONTAINER_NAME.service status..."
sudo systemctl is-enabled container-$CONTAINER_NAME.service
sudo systemctl status container-$CONTAINER_NAME.service --no-pager