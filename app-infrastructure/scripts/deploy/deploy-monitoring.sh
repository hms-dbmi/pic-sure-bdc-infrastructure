#!/bin/bash

public_dns=""
staging_dns=""
mysql_host=""

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
    --public_dns)
       public_dns="$2"
       shift 2
       ;;
    --staging_dns)
       staging_dns="$2"
       shift 2
       ;;
    --mysql_host)
       mysql_host="$2"
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
# prometheus (prom/prometheus) runs as uid 65534 (nobody) inside the
# container, so it needs read access to the mounted token file (and its
# parent dir needs to remain traversable) once the M4 per-service scrape
# jobs (which use this token) are enabled.
sudo chown 65534:65534 /usr/local/docker-config/monitoring/secrets/app-token
sudo chmod 755 /usr/local/docker-config/monitoring/secrets

# Extract the config bundle (yields prometheus/, grafana/, blackbox/ under the monitoring dir).
tar -xzf /opt/picsure/monitoring-bundle.tar.gz -C /usr/local/docker-config/monitoring/

# Merge the FISMA-only grafana assets (provisioning-bdc/, dashboards-bdc/) into the
# same provisioning/dashboards trees the aio sync populates. Guarded with [ -d ]
# so older bundles that predate these directories still deploy cleanly.
if [ -d /usr/local/docker-config/monitoring/grafana/provisioning-bdc/datasources ]; then
  cp -r /usr/local/docker-config/monitoring/grafana/provisioning-bdc/datasources/. \
    /usr/local/docker-config/monitoring/grafana/provisioning/datasources/
fi
if [ -d /usr/local/docker-config/monitoring/grafana/dashboards-bdc ]; then
  cp /usr/local/docker-config/monitoring/grafana/dashboards-bdc/*.json \
    /usr/local/docker-config/monitoring/grafana/dashboards/
fi

# Render the prometheus config for this region/environment. __PUBLIC_DNS__/
# __STAGING_DNS__ are only substituted when a value was passed in — if either
# is empty, the token is left in prometheus.yml verbatim (an obviously-broken
# target, not a silently-wrong one) and a WARN is emitted below.
sed_args=(-e "s/__REGION__/us-east-1/" -e "s/__ENVIRONMENT_NAME__/$environment_name/")
if [[ -n "$public_dns" ]]; then
  sed_args+=(-e "s/__PUBLIC_DNS__/$public_dns/")
else
  echo "WARN: blackbox public probes unrendered (--public_dns empty)"
fi
if [[ -n "$staging_dns" ]]; then
  sed_args+=(-e "s/__STAGING_DNS__/$staging_dns/")
else
  echo "WARN: blackbox staging probe unrendered (--staging_dns empty)"
fi

sed "${sed_args[@]}" \
  /usr/local/docker-config/monitoring/prometheus/prometheus-bdc.yml > /usr/local/docker-config/monitoring/prometheus/prometheus.yml

PROMETHEUS_IMAGE=$(podman load < /opt/picsure/prometheus.tar.gz | cut -d ' ' -f 3)
GRAFANA_IMAGE=$(podman load < /opt/picsure/grafana.tar.gz | cut -d ' ' -f 3)

podman network exists monitoring || podman network create monitoring

sudo mkdir -p /var/lib/prometheus
sudo mkdir -p /var/lib/grafana

# Container images run as unprivileged, image-defined UIDs, not root — the
# host-mounted data dirs must be owned accordingly or the containers crash on
# first boot trying to write their data files.
sudo chown 65534:65534 /var/lib/prometheus   # prom/prometheus runs as nobody
sudo chown 472:472 /var/lib/grafana          # grafana image runs as uid 472

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

s3_copy "s3://${stack_s3_bucket}/monitoring/containers/blackbox-exporter.tar.gz" "/opt/picsure/blackbox-exporter.tar.gz"

BLACKBOX_IMAGE=$(podman load < /opt/picsure/blackbox-exporter.tar.gz | cut -d ' ' -f 3)

CONTAINER_NAME=blackbox-exporter
# Stop and remove any existing container and systemd service.
sudo systemctl stop container-$CONTAINER_NAME.service 2>/dev/null || true
podman rm -f $CONTAINER_NAME || true

# Create the container without starting it — systemd will handle startup.
# No published host port: only prometheus (same podman `monitoring` network)
# needs to reach it, at blackbox-exporter:9115.
podman create --network monitoring --name=$CONTAINER_NAME \
--log-opt tag=$CONTAINER_NAME \
-v /usr/local/docker-config/monitoring/blackbox/blackbox.yml:/etc/blackbox/blackbox.yml:Z \
"$BLACKBOX_IMAGE" \
--config.file=/etc/blackbox/blackbox.yml

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

# mysqld_exporter: only started when a MySQL host was passed in AND the
# credentials secret exists in S3 — exporters are additive, never
# deploy-blocking (mirrors the apache-exporter guard in deploy-httpd.sh).
if [[ -n "$mysql_host" ]] && sudo /usr/bin/aws --region us-east-1 s3 ls "s3://${stack_s3_bucket}/monitoring/db-exporters.env" >/dev/null 2>&1; then
  s3_copy "s3://${stack_s3_bucket}/monitoring/containers/mysqld-exporter.tar.gz" "/opt/picsure/mysqld-exporter.tar.gz"
  s3_copy "s3://${stack_s3_bucket}/monitoring/db-exporters.env" "/usr/local/docker-config/monitoring/secrets/db-exporters.env"

  chmod 600 /usr/local/docker-config/monitoring/secrets/db-exporters.env

  # --mysqld.username isn't sourced from the env-file (podman --env-file only
  # sets container env, it doesn't substitute into command args), so pull it
  # out of the fetched secret the same way compose's ${VAR:-default} would.
  MONITORING_MYSQL_USER=$(grep -m1 '^MONITORING_MYSQL_USER=' /usr/local/docker-config/monitoring/secrets/db-exporters.env | cut -d '=' -f2-)
  MONITORING_MYSQL_USER=${MONITORING_MYSQL_USER:-monitoring}

  MYSQLD_EXPORTER_IMAGE=$(podman load < /opt/picsure/mysqld-exporter.tar.gz | cut -d ' ' -f 3)

  CONTAINER_NAME=mysqld-exporter
  # Stop and remove any existing container and systemd service.
  sudo systemctl stop container-$CONTAINER_NAME.service 2>/dev/null || true
  podman rm -f $CONTAINER_NAME || true

  # Create the container without starting it — systemd will handle startup.
  podman create --network monitoring --name=$CONTAINER_NAME \
  --log-opt tag=$CONTAINER_NAME \
  --env-file /usr/local/docker-config/monitoring/secrets/db-exporters.env \
  "$MYSQLD_EXPORTER_IMAGE" \
  --mysqld.username="$MONITORING_MYSQL_USER" \
  --mysqld.address="${mysql_host}:3306"

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
else
  echo "WARN: skipping mysqld-exporter (--mysql_host empty or s3://${stack_s3_bucket}/monitoring/db-exporters.env not found)"
fi
