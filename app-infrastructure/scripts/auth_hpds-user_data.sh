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
               \"file_path\":\"/var/log/hpds-docker-logs/*\",
               \"log_group_name\":\"hpds-logs\",
               \"log_stream_name\":\"{instance_id} ${stack_githash} hpds-app-logs\",
               \"timestamp_format\":\"UTC\"
            }
         ]
      }
		}
	}


}

" > /opt/aws/amazon-cloudwatch-agent/etc/custom_config.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/custom_config.json  -s


for i in 1 2 3 4 5; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://${stack_s3_bucket}/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-hpds.tar.gz . && break || sleep 45; done
mkdir -p /opt/local/hpds/all

aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr0masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr1masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr2masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr3masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr4masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr5masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr6masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr7masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr8masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr9masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr10masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr11masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr12masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr13masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr14masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr15masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr16masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr17masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr18masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr19masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr20masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr21masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/chr22masks.bin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/BucketIndexBySample.javabin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/Gene_with_variant_infoStore.javabin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/Variant_class_infoStore.javabin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/Variant_consequence_calculated_infoStore.javabin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/Variant_frequency_as_text_infoStore.javabin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/Variant_severity_infoStore.javabin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/BucketIndexBySampleStorage.javabin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/Gene_with_variant_infoStoreStorage.javabin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/Variant_class_infoStoreStorage.javabin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/Variant_consequence_calculated_infoStoreStorage.javabin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/Variant_frequency_as_text_infoStoreStorage.javabin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/Variant_severity_infoStoreStorage.javabin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/variantIndex_fbbis.javabin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/variantIndex_fbbis_storage.javabin /opt/local/hpds/all/
aws s3 cp s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/variantStore.javabin /opt/local/hpds/all/

for i in 1 2 3 4 5; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://${stack_s3_bucket}/data/${dataset_s3_object_key}/javabins_rekeyed.tar.gz /opt/local/hpds/javabins_rekeyed.tar.gz  && break || sleep 45; done
cd /opt/local/hpds/
tar zxvf javabins_rekeyed.tar.gz

cd ~

sudo mkdir -p /var/log/hpds-docker-logs

HPDS_IMAGE=`sudo docker load < /pic-sure-hpds.tar.gz | cut -d ' ' -f 3`
sudo docker run --name=auth-hpds \
                --restart unless-stopped \
                --log-driver syslog --log-opt tag=auth-hpds \
                -v /opt/local/hpds:/opt/local/hpds \
                -p 8080:8080 \
                -e CATALINA_OPTS=" -XX:+UseParallelGC -XX:SurvivorRatio=250 -Xms10g -Xmx110g -DCACHE_SIZE=2500 -DSMALL_TASK_THREADS=1 -DLARGE_TASK_THREADS=1 -DSMALL_JOB_LIMIT=100 -DID_BATCH_SIZE=5000 '-DALL_IDS_CONCEPT=NONE'  '-DID_CUBE_NAME=NONE'"  \
                -d $HPDS_IMAGE

sudo docker logs -f hpds > /var/log/hpds-docker-logs/hpds.log &

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/local/bin/aws --region=us-east-1 ec2 create-tags --resources $${INSTANCE_ID} --tags Key=InitComplete,Value=true

