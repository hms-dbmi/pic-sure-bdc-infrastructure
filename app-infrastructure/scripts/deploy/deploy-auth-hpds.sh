#!/bin/bash

while [[ $# -gt 0 ]]; do
  case $1 in
    --stack_s3_bucket)
      stack_s3_bucket="$2"
      shift 2
      ;;
   --dataset_s3_object_key)
      dataset_s3_object_key="$2"
      shift 2
      ;;
    --genomic_dataset_s3_object_key)
      genomic_dataset_s3_object_key="$2"
      shift 2
      ;;
    --environment_name)
      environment_name="$2"
      shift 2
      ;;
    --target_stack)
      target_stack="$2"
      shift 2
      ;;
    --env_private_dns_name)
      env_private_dns_name="$2"
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
dataset_s3_object_key=${dataset_s3_object_key:-$DATASET_S3_OBJECT_KEY}
genomic_dataset_s3_object_key=${genomic_dataset_s3_object_key:-$GENOMIC_DATASET_S3_OBJECT_KEY}
target_stack=${target_stack:-$TARGET_STACK}
environment_name=${environment_name:-$ENVIRONMENT_NAME}
env_private_dns_name=${env_private_dns_name:-$ENV_PRIVATE_DNS_NAME}



if [[ -z "$stack_s3_bucket" || -z "$genomic_dataset_s3_object_key" || -z "$dataset_s3_object_key" || -z "$environment_name" || -z "$target_stack" || -z "$env_private_dns_name" ]]; then
  echo "Error: --stack_s3_bucket, --genomic_dataset_s3_object_key, --dataset_s3_object_key, --environment_name, --target_stack, and --env_private_dns_name are required"
  exit 1
fi

# Determine whether the dataset keys changed since the previous run.
# A missing last-execution file means this is the first run — always download.
download_dataset=true
download_genomic_dataset=true
last_execution_file="/opt/picsure/deploy-script-last-execution-values.txt"
if [[ -f "$last_execution_file" ]]; then
  prev_dataset_s3_object_key=$(awk -F'"' '/^export dataset_s3_object_key=/{print $2}' "$last_execution_file")
  prev_genomic_dataset_s3_object_key=$(awk -F'"' '/^export genomic_dataset_s3_object_key=/{print $2}' "$last_execution_file")
  if [[ "$prev_dataset_s3_object_key" == "$dataset_s3_object_key" ]]; then
    download_dataset=false
  fi
  if [[ "$prev_genomic_dataset_s3_object_key" == "$genomic_dataset_s3_object_key" ]]; then
    download_genomic_dataset=false
  fi
fi

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/pic-sure-hpds.tar.gz" "/opt/picsure/pic-sure-hpds.tar.gz"
s3_copy "s3://${stack_s3_bucket}/configs/hpds/${target_stack}/auth-hpds.env" "/opt/picsure/auth-hpds.env"

if [[ "$download_dataset" == "true" ]]; then
  s3_copy "s3://${stack_s3_bucket}/data/${dataset_s3_object_key}/javabins_rekeyed.tar" "/opt/local/hpds/javabins_rekeyed.tar"
  cd /opt/local/hpds || exit 1
  tar -xvf javabins_rekeyed.tar
  cd ~ || exit 1
else
  echo "Skipping javabins download — dataset_s3_object_key unchanged from previous run (${dataset_s3_object_key})"
fi

if [[ "$download_genomic_dataset" == "true" ]]; then
  s3_copy "s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/" "/opt/local/hpds/all/" --recursive
else
  echo "Skipping genomic dataset download — genomic_dataset_s3_object_key unchanged from previous run (${genomic_dataset_s3_object_key})"
fi

# Record values only after downloads so a failed run doesn't cause the next run
# to incorrectly skip redownloading.
cat << EOF > "$last_execution_file"
export stack_s3_bucket="${stack_s3_bucket}"
export dataset_s3_object_key="${dataset_s3_object_key}"
export genomic_dataset_s3_object_key="${genomic_dataset_s3_object_key}"
export environment_name="${environment_name}"
export target_stack="${target_stack}"
export env_private_dns_name="${env_private_dns_name}"
EOF

chmod 644 /opt/local/hpds/*
chmod 644 /opt/local/hpds/all/*
chmod 644 /opt/picsure/auth-hpds.env
chmod 644 /opt/picsure/pic-sure-hpds.tar.gz

echo "Loading and running container"
CONTAINER_NAME="auth-hpds"
HPDS_IMAGE=$(podman load < /opt/picsure/pic-sure-hpds.tar.gz | cut -d ' ' -f 3)

# Stop and remove any existing container and systemd service.
sudo systemctl stop container-$CONTAINER_NAME.service 2>/dev/null || true
podman rm -f $CONTAINER_NAME || true

# Create the container without starting it — systemd will handle startup.
podman create --privileged --name=$CONTAINER_NAME \
                -v /var/log/picsure/auth-hpds/:/var/log/:Z \
                -v /opt/local/hpds:/opt/local/hpds:Z \
                --log-opt tag=$CONTAINER_NAME \
                -p 8080:8080 \
                --env-file /opt/picsure/auth-hpds.env \
                "$HPDS_IMAGE"

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