#!/bin/bash
sudo yum install wget -y
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/centos/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U amazon-cloudwatch-agent.rpm
sudo touch /opt/aws/amazon-cloudwatch-agent/etc/custom_config.json
echo "
{
	\"metrics\": {
		\"metrics_collected\": {
			\"cpu\": {
				\"measurement\": [
					\"cpu_usage_idle\",
					\"cpu_usage_user\",
					\"cpu_usage_system\"
				],
				\"metrics_collection_interval\": 300,
				\"totalcpu\": false
			},
			\"disk\": {
				\"measurement\": [
					\"used_percent\"
				],
				\"metrics_collection_interval\": 600,
				\"resources\": [
					\"*\"
				]
			},
			\"mem\": {
				\"measurement\": [
					\"mem_used_percent\",
                                        \"mem_available\",
                                        \"mem_available_percent\",
                                       \"mem_total\",
                                        \"mem_used\"
				],
				\"metrics_collection_interval\": 600
			}
		}
	},
	\"logs\":{
   \"logs_collected\":{
      \"files\":{
         \"collect_list\":[
            {
               \"file_path\":\"/var/log/secure\",
               \"log_group_name\":\"secure\",
               \"log_stream_name\":\"{instance_id} secure\",
               \"timestamp_format\":\"UTC\"
            },
            {
               \"file_path\":\"/var/log/messages\",
               \"log_group_name\":\"messages\",
               \"log_stream_name\":\"{instance_id} messages\",
               \"timestamp_format\":\"UTC\"
            },
						{
               \"file_path\":\"/var/log/audit/audit.log\",
               \"log_group_name\":\"audit.log\",
               \"log_stream_name\":\"{instance_id} audit.log\",
               \"timestamp_format\":\"UTC\"
            },
						{
               \"file_path\":\"/var/log/yum.log\",
               \"log_group_name\":\"yum.log\",
               \"log_stream_name\":\"{instance_id} yum.log\",
               \"timestamp_format\":\"UTC\"
            },
            {
               \"file_path\":\"/var/log/visualization-docker-logs/*\",
               \"log_group_name\":\"visualization-logs\",
               \"log_stream_name\":\"{instance_id} ${stack_githash} visualization-app-logs\",
               \"timestamp_format\":\"UTC\"
            }
         ]
      }
		}
	}
}
" > /opt/aws/amazon-cloudwatch-agent/etc/custom_config.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/custom_config.json  -s


sudo mkdir -p /var/log/visualization-docker-logs
for i in 1 2 3 4 5 6 7 8 9; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://${stack_s3_bucket}/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-hpds-visualization-resource.tar.gz . && break || sleep 45; done

sudo mkdir -p /usr/local/docker-config
sudo echo "search.url=http://open-hpds.${target-stack}.datastage.hms.harvard.edu:8080/PIC-SURE/search/70c837be-5ffc-11eb-ae93-0242ac130002"  > /usr/local/docker-config/application.properties
sudo echo "picSure.url=http://auth-hpds.${target-stack}.datastage.hms.harvard.edu:8080/PIC-SURE/query/sync" >> /usr/local/docker-config/application.properties
sudo echo "UUID=ca0ad4a9-130a-3a8a-ae00-e35b07f1108b"

VISUALIZATION_IMAGE=`sudo docker load < pic-sure-hpds-visualization-resource.tar.gz | cut -d ' ' -f 3'`
sudo docker run --name=visualization -v /var/log/visualization-docker-logs:/usr/local/tomcat/logs -v /usr/local/docker-config/application.properties:/usr/local/docker-config/application.properties -p 8080:8080 -d $VISUALIZATION_IMAGE

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/local/bin/aws --region=us-east-1 ec2 create-tags --resources $${INSTANCE_ID} --tags Key=InitComplete,Value=true
