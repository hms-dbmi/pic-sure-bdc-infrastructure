#!/bin/bash
echo "ENABLE_PODMAN=true" | sudo tee -a /opt/srce/startup.config
echo "SPLUNK_INDEX=hms_aws_${gss_prefix}" | sudo tee -a /opt/srce/startup.config
echo "NESSUS_GROUP=${gss_prefix}_${target_stack}" | sudo tee -a /opt/srce/startup.config

sudo sh /opt/srce/scripts/start-gsstools.sh
echo "user-data progress starting update"

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp "$@" --no-progress && break || sleep 30
  done
}

mkdir -p /opt/local/hpds/all
sudo mkdir -p /var/log/picsure/auth-hpds/

s3_copy s3://${stack_s3_bucket}/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-hpds.tar.gz /opt/picsure/pic-sure-hpds.tar.gz
s3_copy s3://${stack_s3_bucket}/data/${dataset_s3_object_key}/javabins_rekeyed.tar /opt/local/hpds/javabins_rekeyed.tar
s3_copy s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/ /opt/local/hpds/all/ --recursive

cd /opt/local/hpds
tar -xvf javabins_rekeyed.tar
cd ~

# Load and run docker container.  Then wait for initialization before tagging instance as init complete.
echo "Loading and running container"
INIT_MESSAGE="WebApplicationContext: initialization completed"
INIT_TIMEOUT_SECS=2400  # Set your desired timeout in seconds
INIT_START_TIME=$(date +%s)

CONTAINER_NAME="auth-hpds"

chmod 644 /opt/local/hpds/*
chmod 644 /opt/local/hpds/all/*
chmod 644 /opt/picsure/*

HPDS_IMAGE=`podman load < /opt/picsure/pic-sure-hpds.tar.gz | cut -d ' ' -f 3`
CONTAINER_NAME="auth-hpds"

podman rm -f $CONTAINER_NAME || true

podman run -u root --privileged --name=$CONTAINER_NAME \
                -v /var/log/picsure/auth-hpds/:/var/log/:Z \
                --log-opt tag=auth-hpds \
                -v /opt/local/hpds:/opt/local/hpds:Z \
                -p 8080:8080 \
                -e JAVA_OPTS=" -XX:+UseParallelGC -XX:SurvivorRatio=250 -Xms10g -Xmx128g -Dserver.port=8080 -Dspring.profiles.active=bdc-auth-${environment_name} -DTARGET_STACK=${target_stack}.${env_private_dns_name} -DCACHE_SIZE=2500 -DID_BATCH_SIZE=5000 -DALL_IDS_CONCEPT=NONE -DID_CUBE_NAME=NONE "  \
                -d $HPDS_IMAGE

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

echo "Waiting for container to initialize"
while true; do
  status=$(podman logs "$CONTAINER_NAME" 2>&1 | grep "$INIT_MESSAGE")

  if [ -z $status ];then
    echo "$CONTAINER_NAME container has initialized."

    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
    sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources $INSTANCE_ID --tags Key=InitComplete,Value=true
    break
  else
    CURRENT_TIME=$(date +%s)
    ELAPSED_TIME=$((CURRENT_TIME - INIT_START_TIME))

    if [ "$ELAPSED_TIME" -ge "$INIT_TIMEOUT_SECS" ]; then
      echo "Timeout reached ($INIT_TIMEOUT_SECS seconds). The $CONTAINER_NAME container initialization didn't complete."
      INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
      sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources $INSTANCE_ID --tags Key=InitComplete,Value=failed

      break
    fi
  fi
done

echo "user-data progress starting update"
sudo yum -y update
