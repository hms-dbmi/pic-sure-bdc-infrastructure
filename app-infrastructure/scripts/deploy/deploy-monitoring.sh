#!/bin/bash

while [[ $# -gt 0 ]]; do
  case $1 in
    --stack_s3_bucket)
       stack_s3_bucket="$2"
       shift 2
       ;;
    --environment_name)
       environment_name="$2"
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
environment_name=${environment_name:-$ENVIRONMENT_NAME}

if [[ -z "$stack_s3_bucket" || -z "$environment_name" ]]; then
  echo "Error: --stack_s3_bucket and --environment_name are required."
  exit 1
fi

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

mkdir -p /usr/local/docker-config/monitoring/secrets

s3_copy "s3://${stack_s3_bucket}/monitoring/containers/prometheus.tar.gz" "/opt/picsure/prometheus.tar.gz"
s3_copy "s3://${stack_s3_bucket}/monitoring/containers/grafana.tar.gz" "/opt/picsure/grafana.tar.gz"
s3_copy "s3://${stack_s3_bucket}/monitoring/config-bundle.tar.gz" "/opt/picsure/monitoring-bundle.tar.gz"
s3_copy "s3://${stack_s3_bucket}/monitoring/monitoring.env" "/opt/picsure/monitoring.env"
s3_copy "s3://${stack_s3_bucket}/monitoring/app-token" "/usr/local/docker-config/monitoring/secrets/app-token"

chmod 600 /usr/local/docker-config/monitoring/secrets/app-token

# Extract the config bundle (yields prometheus/, grafana/ under the monitoring dir).
tar -xzf /opt/picsure/monitoring-bundle.tar.gz -C /usr/local/docker-config/monitoring/

# Render the prometheus config for this region/environment.
sed -e "s/__REGION__/us-east-1/" -e "s/__ENVIRONMENT_NAME__/$environment_name/" \
  /usr/local/docker-config/monitoring/prometheus/prometheus-bdc.yml > /usr/local/docker-config/monitoring/prometheus/prometheus.yml

PROMETHEUS_IMAGE=$(podman load < /opt/picsure/prometheus.tar.gz | cut -d ' ' -f 3)
GRAFANA_IMAGE=$(podman load < /opt/picsure/grafana.tar.gz | cut -d ' ' -f 3)

podman network exists monitoring || podman network create monitoring

sudo mkdir -p /var/lib/prometheus
sudo mkdir -p /var/lib/grafana

CONTAINER_NAME=prometheus
# Stop and remove any existing container and systemd service.
sudo systemctl stop container-$CONTAINER_NAME.service 2>/dev/null || true
podman rm -f $CONTAINER_NAME || true

# Create the container without starting it — systemd will handle startup.
podman create --network monitoring --name=$CONTAINER_NAME \
--log-opt tag=$CONTAINER_NAME \
-p 127.0.0.1:9090:9090 \
-v /usr/local/docker-config/monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:Z \
-v /usr/local/docker-config/monitoring/prometheus/rules:/etc/prometheus/rules:Z \
-v /usr/local/docker-config/monitoring/secrets:/etc/prometheus/secrets:Z \
-v /var/lib/prometheus:/prometheus:Z \
"$PROMETHEUS_IMAGE" \
--config.file=/etc/prometheus/prometheus.yml \
--storage.tsdb.retention.time=90d \
--storage.tsdb.path=/prometheus

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

CONTAINER_NAME=grafana
# Stop and remove any existing container and systemd service.
sudo systemctl stop container-$CONTAINER_NAME.service 2>/dev/null || true
podman rm -f $CONTAINER_NAME || true

# Create the container without starting it — systemd will handle startup.
podman create --network monitoring --name=$CONTAINER_NAME \
--log-opt tag=$CONTAINER_NAME \
-p 127.0.0.1:3000:3000 \
--env-file /opt/picsure/monitoring.env \
-e GF_PATHS_DATA=/var/lib/grafana-data \
-v /usr/local/docker-config/monitoring/grafana/provisioning:/etc/grafana/provisioning:Z \
-v /usr/local/docker-config/monitoring/grafana/dashboards:/var/lib/grafana/dashboards:Z \
-v /var/lib/grafana:/var/lib/grafana-data:Z \
"$GRAFANA_IMAGE"

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
