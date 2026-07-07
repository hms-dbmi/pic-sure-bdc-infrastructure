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

if [[ -z "$stack_s3_bucket" ]]; then
  echo "Error: --stack_s3_bucket is required."
  exit 1
fi
# Note: --environment_name is accepted (and sourced from $ENVIRONMENT_NAME) for
# forward-compatibility, but is not required here: this script is invoked
# identically from all four app-instance user-data scripts (B3), and only
# auth_hpds-user_data.sh exports ENVIRONMENT_NAME today. environment_name is
# not otherwise used in this script's logic below.

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/monitoring/containers/node-exporter.tar.gz" "/opt/picsure/node-exporter.tar.gz"
s3_copy "s3://${stack_s3_bucket}/monitoring/containers/podman-exporter.tar.gz" "/opt/picsure/podman-exporter.tar.gz"

NODE_EXPORTER_IMAGE=$(podman load < /opt/picsure/node-exporter.tar.gz | cut -d ' ' -f 3)
PODMAN_EXPORTER_IMAGE=$(podman load < /opt/picsure/podman-exporter.tar.gz | cut -d ' ' -f 3)

CONTAINER_NAME=node-exporter
# Stop and remove any existing container and systemd service.
sudo systemctl stop container-$CONTAINER_NAME.service 2>/dev/null || true
podman rm -f $CONTAINER_NAME || true

# Create the container without starting it — systemd will handle startup.
podman create --name=$CONTAINER_NAME --net host --pid host \
--log-opt tag=$CONTAINER_NAME \
-v /:/host:ro,rslave \
"$NODE_EXPORTER_IMAGE" \
--path.rootfs=/host \
--web.listen-address=:9100

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

CONTAINER_NAME=podman-exporter
# podman-exporter needs the podman API socket. It's not enabled by default;
# enable it here (idempotent) before touching the socket path below.
sudo systemctl enable --now podman.socket

if [ -S /run/podman/podman.sock ]; then
  # Stop and remove any existing container and systemd service.
  sudo systemctl stop container-$CONTAINER_NAME.service 2>/dev/null || true
  podman rm -f $CONTAINER_NAME || true

  # Create the container without starting it — systemd will handle startup.
  podman create --name=$CONTAINER_NAME --net host --privileged \
  --log-opt tag=$CONTAINER_NAME \
  -v /run/podman/podman.sock:/run/podman/podman.sock:Z \
  -e CONTAINER_HOST=unix:///run/podman/podman.sock \
  "$PODMAN_EXPORTER_IMAGE" \
  --web.listen-address=:9882

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
  echo "WARN: podman.sock missing; skipping podman-exporter"
fi

# Open the exporter ports on the host firewall. This codebase programs the
# base nftables ruleset directly (see wildfly-user_data.sh), rather than
# firewalld, so match that mechanism here. Guard each rule so re-running
# this script (redeploys) doesn't stack duplicate rules.
open_port() {
  local proto=$1
  local port=$2
  if ! sudo nft list chain inet filter input 2>/dev/null | grep -qE "${proto} dport ${port} accept"; then
    sudo nft add rule inet filter input "$proto" dport "$port" accept
  fi
}

open_port tcp 9100
open_port tcp 9882

sudo nft list ruleset | sudo tee /etc/nftables/nftables.rules > /dev/null
sudo systemctl restart nftables
