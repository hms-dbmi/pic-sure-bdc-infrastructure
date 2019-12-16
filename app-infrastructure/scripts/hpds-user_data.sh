#!/usr/bin/env bash
for i in 1 2 3 4 5; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://avillach-datastage-pic-sure-jenkins-dev-builds-3/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-hpds.tar.gz . && break || sleep 30; done
mkdir -p /opt/local/hpds/all
for i in 1 2 3 4 5; do sudo /usr/local/bin/aws --region us-east-1 s3 cp ${dataset_s3_url} /opt/local/hpds/hpds_data.tar.gz && break || sleep 30; done
for i in 1 2 3 4 5; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://avillach-datastage-pic-sure-jenkins-dev-builds-3/configs/jenkins_pipeline_build_${stack_githash}/hpds-log4j.properties /opt/local/hpds/log4j.properties && break || sleep 30; done
cd /opt/local/hpds
tar -xvzf hpds_data.tar.gz
cd ~

HPDS_IMAGE=`sudo docker load < /pic-sure-hpds.tar.gz | cut -d ' ' -f 3`
sudo docker run --name=hpds -v /var/log/hpds-docker-logs/:/var/log -v /opt/local/hpds:/opt/local/hpds -p 8080:8080 --entrypoint=java -d $HPDS_IMAGE -XX:+UseParallelGC -XX:SurvivorRatio=250 -Xms1g -Xmx12g -server -jar hpds.jar -httpPort 8080 -DCACHE_SIZE=10000 -DSMALL_TASK_THREADS=1 -DLARGE_TASK_THREADS=1 -DSMALL_JOB_LIMIT=100 -DID_BATCH_SIZE=2000 "-DALL_IDS_CONCEPT=NONE"  "-DID_CUBE_NAME=NONE"
sudo docker logs -f hpds > /var/log/hpds-docker-logs/hpds.log &
