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
               \"file_path\":\"/var/log/genomic-docker-logs/*\",
               \"log_group_name\":\"genomic-logs\",
               \"log_stream_name\":\"{instance_id} ${deployment_githash} genomic-app-logs\",
               \"timestamp_format\":\"UTC\"
            }
         ]
      }
		}
	}


}

" > /opt/aws/amazon-cloudwatch-agent/etc/custom_config.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/custom_config.json  -s


#!/bin/bash


mkdir -p /usr/local/docker-config/cert
mkdir -p /var/log/genomic-docker-logs/ssl_mutex


INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/local/bin/aws --region=us-east-1 ec2 create-tags --resources $${INSTANCE_ID} --tags Key=InitComplete,Value=true

cd /home/centos/ensemble-vep

aws sts assume-role --role-arn ${arn_role_cnc} --role-session-name "get-genomic-source-file" > assume-role-output.txt

export AWS_ACCESS_KEY_ID=`grep AccessKeyId assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g"`
export AWS_SECRET_ACCESS_KEY=`grep SecretAccessKey assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g"`
export AWS_SESSION_TOKEN=`grep SessionToken assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g"`

nohup aws s3 cp s3://${input_s3_bucket}/${study_name}_${study_id}_TOPMed_WGS_freeze.9b.chr${chrom_number}.hg38${consent_group_tag}.vcf.gz . &

wait

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

nohup bcftools view -Oz --threads 40 -f PASS,. ${study_name}_${study_id}_TOPMed_WGS_freeze.9b.chr${chrom_number}.hg38${consent_group_tag}.vcf.gz > ${study_id}${consent_group_tag}.chr${chrom_number}.filtered.vcf.gz &

wait

nohup bcftools annotate --threads 40 --rename-chrs chrm_rename.txt ${study_id}${consent_group_tag}.chr${chrom_number}.filtered.vcf.gz | bgzip > ${study_id}${consent_group_tag}.chr${chrom_number}.renamed.vcf.gz &

wait

nohup bcftools norm --threads 40 -m -any -f Homo_sapiens.GRCh38.dna.primary_assembly.fa -o sampleChrm11.normalized.vcf.gz ${study_id}${consent_group_tag}.chr${chrom_number}.renamed.vcf.gz &

wait

nohup bgzip -d ${study_id}${consent_group_tag}.chr${chrom_number}.normalized.vcf.gz &                        

wait

nohup ./vep \
--cache \
--merged \
--fork 4 \
--dir_cache /root/.vep \
--species homo_sapiens \
--input_file ${study_id}${consent_group_tag}.chr${chrom_number}.normalized.vcf \
--format vcf \
--output_file ${study_id}${consent_group_tag}.chr${chrom_number}.annotated.vcf \
--no_stats \
--force_overwrite \
--assembly GRCh38 \
--fields "Allele,Consequence,IMPACT,SYMBOL,Feature_type,Feature,gnomAD_AF,CLIN_SIG,ENSP" \
--fasta /root/.vep/homo_sapiens/107_GRCh38/Homo_sapiens.GRCh38.dna.toplevel.fa.gz \
--check_ref \
--buffer_size 5000 \
--flag_pick \
--vcf &

wait

nohup bgzip -fki --threads 40 ${study_id}${consent_group_tag}.chr${chrom_number}.annotated.vcf &

wait

aws sts assume-role --role-arn ${arn_role_cnc} --role-session-name "get-genomic-source-file" > assume-role-output.txt

export AWS_ACCESS_KEY_ID=`grep AccessKeyId assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g"`
export AWS_SECRET_ACCESS_KEY=`grep SecretAccessKey assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g"`
export AWS_SESSION_TOKEN=`grep SessionToken assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g"`

nohup aws s3 cp ${study_id}${consent_group_tag}.chr${chrom_number}.annotated.vcf.gz s3://${output_s3_bucket}/genomic-etl/processed_vcfs/ &

wait

nohup aws s3 cp ${study_id}${consent_group_tag}.chr${chrom_number}.annotated.vcf.gzi s3://${output_s3_bucket}/genomic-etl/processed_vcfs/ &

wait

nohup aws s3 cp ${study_name}_${study_id}_TOPMed_WGS_freeze.9b.chr${chrom_number}.hg38${consent_group_tag}.vcf.gz s3://${output_s3_bucket}/genomic-etl/original_vcfs/${study_id}${consent_group_tag}.chr${chrom_number}.original.vcf.gz &

wait

nohup aws s3 cp nohup.out s3://${output_s3_bucket}/genomic-etl/logs/${study_id}${consent_group_tag}.chr${chrom_number}.out &

wait

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN