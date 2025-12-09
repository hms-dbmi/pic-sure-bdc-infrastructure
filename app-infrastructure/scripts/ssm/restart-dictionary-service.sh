#!/bin/bash
set -euo pipefail

# Optional: allow override via env or first arg
CONTAINER_NAME="${CONTAINER_NAME:-${1:-dictionary-api}}"
SERVICE_NAME="container-${CONTAINER_NAME}.service"

echo "Restarting ${SERVICE_NAME}..."

# Sanity check: does the unit exist?
if ! systemctl list-unit-files | grep -q "^${SERVICE_NAME}"; then
  echo "ERROR: ${SERVICE_NAME} does not exist. Aborting."
  exit 1
fi

# In case any units changed since last deploy
sudo systemctl daemon-reload

# Restart the service (this will restart the podman-managed container)
sudo systemctl restart "${SERVICE_NAME}"

# Optional: make sure it is enabled (idempotent)
sudo systemctl enable "${SERVICE_NAME}" >/dev/null 2>&1 || true

# Verify status
if sudo systemctl is-active --quiet "${SERVICE_NAME}"; then
  echo "Service ${SERVICE_NAME} is active."
else
  echo "ERROR: Service ${SERVICE_NAME} is not active after restart."
  sudo systemctl status "${SERVICE_NAME}" --no-pager || true
  exit 1
fi

echo "Done."