#!/usr/bin/env bash
for i in 1 2 3 4 5; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://avillach-datastage-pic-sure-jenkins-dev-builds-3/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-wildfly.tar.gz . && break || sleep 30; done
for i in 1 2 3 4 5; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://avillach-datastage-pic-sure-jenkins-dev-builds-3/configs/jenkins_pipeline_build_${stack_githash}/standalone.xml /home/centos/standalone.xml && break || sleep 30; done
for i in 1 2 3 4 5; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://avillach-datastage-pic-sure-jenkins-dev-builds-3/modules/mysql/module.xml /home/centos/mysql_module.xml && break || sleep 30; done
for i in 1 2 3 4 5; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://avillach-datastage-pic-sure-jenkins-dev-builds-3/modules/mysql/mysql-connector-java-5.1.38.jar /home/centos/mysql-connector-java-5.1.38.jar && break || sleep 30; done

WILDFLY_IMAGE=`sudo docker load < pic-sure-wildfly.tar.gz | cut -d ' ' -f 3`
JAVA_OPTS="-Xms1024m -Xmx2g -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=256m -Djava.net.preferIPv4Stack=true"
sudo docker run -v /var/log/wildfly-docker-logs/:/opt/jboss/wildfly/standalone/logs -v /home/centos/standalone.xml:/opt/jboss/wildfly/standalone/configuration/standalone.xml -v /home/centos/mysql_module.xml:/opt/jboss/wildfly/modules/system/layers/base/com/sql/mysql/main/module.xml  -v /home/centos/mysql-connector-java-5.1.38.jar:/opt/jboss/wildfly/modules/system/layers/base/com/sql/mysql/main/mysql-connector-java-5.1.38.jar -v /var/log/wildfly-docker-os-logs/:/var/log -p 8080:8080 -e JAVA_OPTS="$JAVA_OPTS" -d $WILDFLY_IMAGE
