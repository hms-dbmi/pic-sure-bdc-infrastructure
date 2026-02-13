#!/bin/bash

while [[ $# -gt 0 ]]; do
  case $1 in
    --stack_s3_bucket)
       stack_s3_bucket="$2"
       shift 2
       ;;
    --target_stack)
       target_stack="$2"
       shift 2
       ;;
    --dataset_s3_object_key)
       dataset_s3_object_key="$2"
       shift 2
       ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

stack_s3_bucket=${stack_s3_bucket:-STACK_S3_BUCKET}
target_stack=${target_stack:-TARGET_STACK}

if [[ -z "$stack_s3_bucket" || -z "$target_stack" ]]; then
  echo "Error: --stack_s3_bucket and --dataset_s3_object_key are required."
  exit 1
fi


s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/pic-sure-frontend.tar.gz" "/opt/picsure/pic-sure-frontend.tar.gz"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/configs/httpd/httpd-vhosts.conf" "/usr/local/docker-config/httpd-vhosts.conf"
s3_copy "s3://${stack_s3_bucket}/data/${dataset_s3_object_key}/fence_mapping.json" "/opt/picsure/fence_mapping.json"
s3_copy "s3://${stack_s3_bucket}/certs/httpd/" "/usr/local/docker-config/cert/" --recursive

CONTAINER_NAME=httpd
podman rm -f httpd || true
podman system prune -a -f || true

chmod o+rx /usr/local/docker-config
chmod o+rx /usr/local/docker-config/cert
chmod o+rx /opt/picsure

find /opt/picsure -type f ! -name ".*" -exec chmod 644 {} \;
find /usr/local/docker-config -type f ! -name ".*" -exec chmod 644 {} \;
find /usr/local/docker-config/cert -type f ! -name "*.key" -exec chmod 644 {} \;
find /usr/local/docker-config/cert -type f -name "*.key" -exec chmod 600 {} \;

HTTPD_IMAGE=$(podman load < /opt/picsure/pic-sure-frontend.tar.gz | cut -d ' ' -f 3)
podman run --privileged -u root --name=$CONTAINER_NAME \
--log-opt tag=$CONTAINER_NAME \
-v /var/log/picsure/httpd/:/usr/local/apache2/logs/:Z \
-v /opt/picsure/fence_mapping.json:/usr/local/apache2/htdocs/picsureui/studyAccess/studies-data.json:Z \
-v /usr/local/docker-config/cert:/usr/local/apache2/cert/:Z \
-v /usr/local/docker-config/httpd-vhosts.conf:/usr/local/apache2/conf/extra/httpd-vhosts.conf:Z \
-p 443:443 \
-p 4443:4443 -d "$HTTPD_IMAGE"

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
