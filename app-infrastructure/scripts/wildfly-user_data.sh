#!/usr/bin/env bash
sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://avillach-datastage-pic-sure-jenkins-dev-builds-3/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-wildfly.tar.gz .

WILDFLY_IMAGE=`sudo docker load < pic-sure-wildfly.tar.gz | cut -d ' ' -f 3`
JAVA_OPTS="-Xms1024m -Xmx2g -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=256m -Djava.net.preferIPv4Stack=true"
sudo docker run -v /var/log/wildfly-docker-logs/:/opt/jboss/wildfly/standalone/logs -v /var/log/wildfly-docker-os-logs/:/var/log -p 8080:8080 -e JAVA_OPTS="$JAVA_OPTS" -d $WILDFLY_IMAGE
