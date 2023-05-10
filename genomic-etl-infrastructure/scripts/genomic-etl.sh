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
				\"metrics_collection_interval\": 100,
				\"totalcpu\": false
			},
			\"disk\": {
				\"measurement\": [
					\"used_percent\"
				],
				\"metrics_collection_interval\": 100,
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
				\"metrics_collection_interval\": 100
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

echo 'Init complete, moving to annotation'


export PERL5LIB='/home/centos/cpanm/lib/perl5:/home/centos/bioperl-1.6.924:/home/centos/Bio-DB-HTS/lib:/home/centos/Bio-DB-HTS/blib/arch/auto/Bio/DB/HTS/:/home/centos/Bio-DB-HTS/blib/arch/auto/Bio/DB/HTS/Faidx:/home/centos/bioperl-1.6.924:/home/centos/ensembl/modules:/home/centos/ensembl-compara/modules:/home/centos/ensembl-variation/modules:/home/centos/src/ensembl-funcgen/modules:/home/centos/lib/perl/5.14.4/:/home/centos/ensembl-vep:/home/centos/Bio-DB-HTS/lib:/home/centos/Bio-DB-HTS/blib/arch/auto/Bio/DB/HTS/:/home/centos/Bio-DB-HTS/blib/arch/auto/Bio/DB/HTS/Faidx:/home/centos/cpanm/lib/perl5'
export HTSLIB_DIR='/home/centos/htslib/'
echo ${chrom_number} chr${chrom_number}  > /home/centos/ensembl-vep/chrm_rename.txt

/usr/local/bin/aws sts assume-role --role-arn arn:aws:iam::600168050588:role/nih-nhlbi-TopMed-EC2Access-S3 --role-session-name "get-genomic-source-file" > /usr/tmp/assume-role-output.txt

export AWS_ACCESS_KEY_ID=`grep AccessKeyId /usr/tmp/assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g"`
export AWS_SECRET_ACCESS_KEY=`grep SecretAccessKey /usr/tmp/assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g"`
export AWS_SESSION_TOKEN=`grep SessionToken /usr/tmp/assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g"`

/usr/local/bin/aws s3 cp s3://${input_s3_bucket}/${study_name}_${study_id}_TOPMed_WGS_freeze.9b.chr${chrom_number}.hg38${consent_group_tag}.vcf.gz /home/centos/ensembl-vep/ &

wait

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} import
/usr/local/bin/bcftools view -Oz --threads 40 -f PASS,. /home/centos/ensembl-vep/${study_name}_${study_id}_TOPMed_WGS_freeze.9b.chr${chrom_number}.hg38${consent_group_tag}.vcf.gz > /home/centos/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.filtered.vcf.gz &
echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} filter stage

wait

echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} filter stage
/usr/local/bin/bcftools annotate --threads 40 --rename-chrs /home/centos/ensembl-vep/chrm_rename.txt /home/centos/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.filtered.vcf.gz | /home/centos/htslib/bgzip > /home/centos/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.renamed.vcf.gz &
echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} rename stage

wait

echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} rename stage
/usr/local/bin/bcftools norm --threads 40 -m -any -f /home/centos/fasta/Homo_sapiens_assembly38.fasta -o /home/centos/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.normalized.vcf.gz /home/centos/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.renamed.vcf.gz &
echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} normalize stage

wait

echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} normalize stage
/home/centos/htslib/bgzip -d /home/centos/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.normalized.vcf.gz &
echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} decompress stage

wait

echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} decompress stage


/home/centos/ensembl-vep/vep \
--cache \
--merged \
--fork 4 \
--dir_cache /root/.vep \
--species homo_sapiens \
--input_file /home/centos/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.normalized.vcf \
--format vcf \
--output_file /home/centos/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.annotated.vcf \
--no_stats \
--force_overwrite \
--assembly GRCh38 \
--af_gnomadg \
--symbol \
--variant_class \
--fasta /home/centos/fasta/Homo_sapiens_assembly38.fasta \
--check_ref \
--buffer_size 5000 \
--flag_pick \
--check_ref \
--offline \
--vcf &
echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} vep stage
wait
echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} vep stage
/home/centos/htslib/bgzip -fki --threads 40 /home/centos/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.annotated.vcf &
echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} compressing stage
wait
echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} compressing stage
/home/centos/htslib/tabix /home/centos/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.annotated.vcf.gz &
echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} tabix stage
wait
echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} tabix stage

/bin/python3 /home/centos/python_script/hpds_annotation/transform_csq.v3.py \
-R /home/centos/fasta/Homo_sapiens_assembly38.fasta \
--vep-gnomad-af gnomADg_AF \
/home/centos/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.annotated.vcf.gz \
/home/centos/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.annotated.hpds.vcf.gz

echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} python stage
wait
echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} python stage

/usr/local/bin/aws sts assume-role --role-arn ${s3_role} --role-session-name "get-genomic-source-file" > /usr/tmp/assume-role-output.txt

export AWS_ACCESS_KEY_ID=`grep AccessKeyId /usr/tmp/assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g"`
export AWS_SECRET_ACCESS_KEY=`grep SecretAccessKey /usr/tmp/assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g"`
export AWS_SESSION_TOKEN=`grep SessionToken /usr/tmp/assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g"`

echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} output stage

/usr/local/bin/aws s3 cp /home/centos/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.annotated.hpds.vcf.gz s3://${output_s3_bucket}/genomic-etl/hpds_vcfs/ &
/usr/local/bin/aws s3 cp /home/centos/ensembl-vep/${study_name}_${study_id}_TOPMed_WGS_freeze.9b.chr${chrom_number}.hg38${consent_group_tag}.vcf.gz s3://${output_s3_bucket}/genomic-etl/original_vcfs/${study_id}${consent_group_tag}.chr${chrom_number}.original.vcf.gz &
wait
echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} output stage
export ANNOTATEDLINECOUNT=`wc -l < /home/centos/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.annotated.vcf`
export NORMLINECOUNT=`wc -l < /home/centos/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.normalized.vcf`
if (($ANNOTATEDLINECOUNT == $NORMLINECOUNT + 3))
then
/usr/local/bin/aws --region=us-east-1 ec2 create-tags --resources $${INSTANCE_ID} --tags Key=AnnotationComplete,Value=true
else
/usr/local/bin/aws --region=us-east-1 ec2 create-tags --resources $${INSTANCE_ID} --tags Key=AnnotationComplete,Value=false
fi

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN