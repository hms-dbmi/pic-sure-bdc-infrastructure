#!/bin/bash

echo "SPLUNK_INDEX=hms_aws_${gss_prefix}" | sudo tee /opt/srce/startup.config
echo "NESSUS_GROUP=${gss_prefix}_${target_stack}" | sudo tee -a /opt/srce/startup.config

sudo sh /opt/srce/scripts/start-gsstools.sh

echo "
[monitor:///var/log/hpds-docker-logs]
sourcetype = hms_app_logs
source = hpds_logs
index=hms_aws_${gss_prefix}
" | sudo tee -a /opt/splunkforwarder/etc/system/local/inputs.conf
sudo systemctl restart SplunkForwarder || true

echo "user-data progress starting update"
sudo yum -y update

s3_copy() {
  for i in {1..5}; do
    sudo /usr/bin/aws --region us-east-1 s3 cp $* && break || sleep 30
  done
}

s3_copy s3://${stack_s3_bucket}/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-hpds.tar.gz /home/centos/pic-sure-hpds.tar.gz

s3_copy s3://${stack_s3_bucket}/data/${destigmatized_dataset_s3_object_key}/destigmatized_javabins_rekeyed.tar.gz /opt/local/hpds/destigmatized_javabins_rekeyed.tar.gz

cd /opt/local/hpds
tar -xvzf destigmatized_javabins_rekeyed.tar.gz
cd ~

HPDS_IMAGE=`sudo docker load < /home/centos/pic-sure-hpds.tar.gz | cut -d ' ' -f 3`
sudo docker run --name=open-hpds \
                --restart unless-stopped \
                --log-driver syslog --log-opt tag=open-hpds \
                -v /opt/local/hpds:/opt/local/hpds -p 8080:8080 \
                -e CATALINA_OPTS=" -XX:+UseParallelGC -XX:SurvivorRatio=250 -Xms10g -Xmx40g -DCACHE_SIZE=2500 -DSMALL_TASK_THREADS=1 -DLARGE_TASK_THREADS=1 -DSMALL_JOB_LIMIT=100 -DID_BATCH_SIZE=5000 " \
                -d $HPDS_IMAGE

# Waiting for application to finish initialization
INIT_MESSAGE="WebApplicationContext: initialization completed"
INIT_TIMEOUT_SEX=2400  # Set your desired timeout in seconds
INIT_START_TIME=$(date +%s)

while [ true ]; do
  if docker logs --tail 0 --follow "$CONTAINER_NAME" | grep -q "$INIT_MESSAGE"; then
    echo "$CONTAINER_NAME container has initialized."
    
    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
    sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources $INSTANCE_ID --tags Key=InitComplete,Value=true

    break
  fi
  
  # Timeout 
  CURRENT_TIME=$(date +%s)
  ELAPSED_TIME=$((CURRENT_TIME - INIT_START_TIME))

  if [ "$ELAPSED_TIME" -ge "$INIT_TIMEOUT_SEX" ]; then
    echo "Timeout reached ($INIT_TIMEOUT_SEX seconds). The $CONTAINER_NAME container initialization didn't complete."
    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
    sudo /usr/bin/aws --region=us-east-1 ec2 create-tags --resources $INSTANCE_ID --tags Key=InitComplete,Value=failed

    break
  else
    sleep 20
  fi
done