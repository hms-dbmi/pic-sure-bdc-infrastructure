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

# Source /etc/environment for fallback values (set during initial provisioning)
if [[ -f /etc/environment ]]; then
  set -a
  source /etc/environment
  set +a
fi

stack_s3_bucket=${stack_s3_bucket:-$STACK_S3_BUCKET}
target_stack=${target_stack:-$TARGET_STACK}

if [[ -z "$stack_s3_bucket" || -z "$target_stack" ]]; then
  echo "Error: --stack_s3_bucket and --target_stack are required."
  exit 1
fi


s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/pic-sure-frontend.tar.gz" "/opt/picsure/pic-sure-frontend.tar.gz"
s3_copy "s3://${stack_s3_bucket}/${target_stack}/configs/httpd/httpd-vhosts.conf" "/usr/local/docker-config/httpd-vhosts.conf"
s3_copy "s3://${stack_s3_bucket}/configs/pic-sure-frontend/bdc.env" "/opt/picsure/bdc.env"
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

# Stop and remove any existing container and systemd service.
sudo systemctl stop container-$CONTAINER_NAME.service 2>/dev/null || true
podman rm -f $CONTAINER_NAME || true

# Create the container without starting it — systemd will handle startup.
podman create --privileged -u root --name=$CONTAINER_NAME \
--log-opt tag=$CONTAINER_NAME \
--env-file /opt/picsure/bdc.env \
-v /var/log/picsure/httpd/:/usr/local/apache2/logs/:Z \
-v /usr/local/docker-config/cert:/usr/local/apache2/cert/:Z \
-v /usr/local/docker-config/httpd-vhosts.conf:/usr/local/apache2/conf/extra/httpd-vhosts.conf:Z \
-p 443:443 -p 127.0.0.1:8081:8081 "$HTTPD_IMAGE"

# systemd setup.
podman generate systemd --name $CONTAINER_NAME --restart-policy=always --files
sudo mv container-$CONTAINER_NAME.service /etc/systemd/system/
sudo restorecon -v /etc/systemd/system/container-$CONTAINER_NAME.service

sudo systemctl daemon-reload
sudo systemctl enable container-$CONTAINER_NAME.service
sudo systemctl start --no-block container-$CONTAINER_NAME.service

echo "Verifying container-$CONTAINER_NAME.service status..."
sudo systemctl is-enabled container-$CONTAINER_NAME.service
# Status check is informational — Jenkins log polling verifies actual startup.
sudo systemctl status container-$CONTAINER_NAME.service --no-pager || true

# monitoring: apache-exporter (guarded — httpd deploys are unaffected until the
# monitoring S3 artifact exists; exporters are additive, never deploy-blocking).
if aws s3 ls "s3://${stack_s3_bucket}/monitoring/containers/apache-exporter.tar.gz" >/dev/null 2>&1; then
  s3_copy "s3://${stack_s3_bucket}/monitoring/containers/apache-exporter.tar.gz" "/opt/picsure/apache-exporter.tar.gz"

  APACHE_EXPORTER_IMAGE=$(podman load < /opt/picsure/apache-exporter.tar.gz | cut -d ' ' -f 3)

  CONTAINER_NAME=apache-exporter
  # Stop and remove any existing container and systemd service.
  sudo systemctl stop container-$CONTAINER_NAME.service 2>/dev/null || true
  podman rm -f $CONTAINER_NAME || true

  # Create the container without starting it — systemd will handle startup.
  podman create --name=$CONTAINER_NAME --net host \
  --log-opt tag=$CONTAINER_NAME \
  "$APACHE_EXPORTER_IMAGE" \
  --scrape_uri=http://127.0.0.1:8081/server-status?auto \
  --telemetry.address=:9117

  # systemd setup.
  podman generate systemd --name $CONTAINER_NAME --restart-policy=always --files
  sudo mv container-$CONTAINER_NAME.service /etc/systemd/system/
  sudo restorecon -v /etc/systemd/system/container-$CONTAINER_NAME.service

  sudo systemctl daemon-reload
  sudo systemctl enable container-$CONTAINER_NAME.service
  sudo systemctl start --no-block container-$CONTAINER_NAME.service

  echo "Verifying container-$CONTAINER_NAME.service status..."
  sudo systemctl is-enabled container-$CONTAINER_NAME.service
  # Status check is informational — Jenkins log polling verifies actual startup.
  sudo systemctl status container-$CONTAINER_NAME.service --no-pager || true

  # Open the exporter port on the host firewall (same nftables mechanism used
  # by deploy-exporters.sh — this codebase programs the base ruleset directly
  # rather than firewalld). Guarded so redeploys don't stack duplicate rules.
  if ! sudo nft list chain inet filter input 2>/dev/null | grep -qE "tcp dport 9117 accept"; then
    sudo nft add rule inet filter input tcp dport 9117 accept
  fi
  sudo nft list ruleset | sudo tee /etc/nftables/nftables.rules > /dev/null
  sudo systemctl restart nftables
else
  echo "Skipping apache-exporter: s3://${stack_s3_bucket}/monitoring/containers/apache-exporter.tar.gz not found."
fi
