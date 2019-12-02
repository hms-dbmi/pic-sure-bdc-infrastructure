#!/usr/bin/env bash
sudo /usr/local/bin/aws -region us-east-1a s3 cp s3://avillach-datastage-pic-sure-jenkins-dev-builds-3/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-hpds.tar.gz .

HPDS_IMAGE=`sudo docker load < pic-sure-hpds.tar.gz | cut -d ' ' -f 3`
ENTRY_POINT='java -XX:+UseParallelGC -XX:SurvivorRatio=250 -Xms1g -Xmx4g -server -jar hpds.jar -httpPort 8080 -DCACHE_SIZE=10000 -DSMALL_TASK_THREADS=1 -DLARGE_TASK_THREADS=1 -DSMALL_JOB_LIMIT=100 -DID_BATCH_SIZE=2000 "-DALL_IDS_CONCEPT=NONE"  "-DID_CUBE_NAME=NONE" > /var/log/hpds.log'
sudo docker run -v /var/log/hpds-docker-logs/:/var/log -p 8080:8080 --entrypoint=$ENTRY_POINT -d $HPDS_IMAGE
