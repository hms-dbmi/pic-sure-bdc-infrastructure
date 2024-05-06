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

export VOLUME_ID=`/usr/local/bin/aws ec2 describe-volumes --filters Name='tag:label',Values=${study_id}${consent_group_tag}.chr${chrom_number} --query "Volumes[*].VolumeId" --output text`
aws ec2 attach-volume --volume-id $VOLUME_ID --device /dev/sdb --instance-id $INSTANCE_ID --region us-east-1 &
wait
mkdir /annotation_pipeline

while [ ! -d /annotation_pipeline/anno/ ]
do
echo 'checking mount'
mount /dev/nvme1n1 /annotation_pipeline
done
echo 'Mount done'


echo 'Init complete, moving to annotation'


export KENT_SRC=/annotation_pipeline/anno/kent-335_base/src
export MACHTYPE=$(uname -m)
export CFLAGS="-fPIC"
export MYSQLINC=`mysql_config --include | sed -e 's/^-I//g'`
export MYSQLLIBS=`mysql_config --libs`
export PERL5LIB=$PERL5LIB:/annotation_pipeline/anno/cpanm/lib/perl5:/annotation_pipeline/anno/bioperl-1.6.924:/annotation_pipeline/anno/Bio-DB-HTS/lib:/annotation_pipeline/anno/Bio-DB-HTS/blib/arch/auto/Bio/DB/HTS/:/annotation_pipeline/anno/Bio-DB-HTS/blib/arch/auto/Bio/DB/HTS/Faidx:/annotation_pipeline/anno/bioperl-1.6.924:/annotation_pipeline/anno/ensembl/modules:/annotation_pipeline/anno/ensembl-compara/modules:/annotation_pipeline/anno/ensembl-variation/modules:/annotation_pipeline/anno/src/ensembl-funcgen/modules:/annotation_pipeline/anno/lib/perl/5.14.4/:/annotation_pipeline/anno/ensembl-vep:/annotation_pipeline/anno/Bio-DB-HTS/lib:/annotation_pipeline/anno/Bio-DB-HTS/blib/arch/auto/Bio/DB/HTS/:/annotation_pipeline/anno/Bio-DB-HTS/blib/arch/auto/Bio/DB/HTS/Faidx
export HTSLIB_DIR=/annotation_pipeline/anno/htslib/
export PATH=/usr/local/bin:/annotation_pipeline/anno/ensembl-vep:/annotation_pipeline/anno/htslib:/annotation_pipeline/anno/bin:$PATH

. /annotation_pipeline/anno/ActiveState.var
echo 'Pipeline starting state is ' $ActiveState



if (( $ActiveState == 'Downloading' ))
then
echo ${chrom_number} chr${chrom_number}  > /annotation_pipeline/anno/ensembl-vep/chrm_rename.txt

/usr/local/bin/aws sts assume-role --role-arn arn:aws:iam::${input_s3_account}:role/nih-nhlbi-TopMed-EC2Access-S3 --role-session-name "get-genomic-source-file" > /usr/tmp/assume-role-output.txt

export AWS_ACCESS_KEY_ID=`grep AccessKeyId /usr/tmp/assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g"`
export AWS_SECRET_ACCESS_KEY=`grep SecretAccessKey /usr/tmp/assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g"`
export AWS_SESSION_TOKEN=`grep SessionToken /usr/tmp/assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g"`

/usr/local/bin/aws s3 cp s3://${input_s3_bucket}/${study_name}_${study_id}_TOPMed_WGS_freeze.9b.chr${chrom_number}.hg38${consent_group_tag}.vcf.gz /annotation_pipeline/anno/ensembl-vep/ &

wait

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

echo 'ActiveState=Filtering' > /annotation_pipeline/anno/ActiveState.var
. /annotation_pipeline/anno/ActiveState.var
echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} download stage
fi



if (( $ActiveState == 'Filtering' ))
then
/usr/local/bin/bcftools view -Oz --threads 40 -f PASS,. /annotation_pipeline/anno/ensembl-vep/${study_name}_${study_id}_TOPMed_WGS_freeze.9b.chr${chrom_number}.hg38${consent_group_tag}.vcf.gz > /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.filtered.vcf.gz &
echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} filter stage

wait

echo 'ActiveState=Renaming' > /annotation_pipeline/anno/ActiveState.var
. /annotation_pipeline/anno/ActiveState.var
echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} filter stage
fi



if (( $ActiveState == 'Renaming' ))
then
/usr/local/bin/bcftools annotate --threads 40 --rename-chrs /annotation_pipeline/anno/ensembl-vep/chrm_rename.txt /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.filtered.vcf.gz | /annotation_pipeline/anno/htslib/bgzip > /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.renamed.vcf.gz &
echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} rename stage

wait

echo 'ActiveState=Normalizing' > /annotation_pipeline/anno/ActiveState.var
. /annotation_pipeline/anno/ActiveState.var
echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} rename stage
fi



if (( $ActiveState == 'Normalizing' ))
then
/usr/local/bin/bcftools norm --threads 40 -m -any -f /annotation_pipeline/anno/fasta/Homo_sapiens_assembly38.fasta -o /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.normalized.vcf.gz /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.renamed.vcf.gz &
echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} normalize stage

wait

/usr/local/bin/bgzip -d /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.normalized.vcf.gz &

wait

/usr/local/bin/bgzip /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.normalized.vcf > /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.normalized.vcf.gz &

wait

tabix /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.normalized.vcf.gz &

wait

echo 'ActiveState=Annotating' > /annotation_pipeline/anno/ActiveState.var
. /annotation_pipeline/anno/ActiveState.var
echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} normalize stage
fi


if (( $ActiveState == 'Annotating' ))
then
nextflow run -bg -resume nextflow/workflows/run_vep.nf \
--vcf /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.normalized.vcf.gz \
--skip_check 1 \
--vep_config /annotation_pipeline/anno/ensembl-vep/nextflow/vep_config/vep.ini \
--bin_size 25000 &
echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} vep stage
wait

echo 'ActiveState=Scripting' > /annotation_pipeline/anno/ActiveState.var
. /annotation_pipeline/anno/ActiveState.var
echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} vep stage
fi

if (( $ActiveState == 'Scripting' ))
then
python3 /annotation_pipeline/anno/ensembl-vep/hpds_annotation/transform_csq.v3.py \
-R /annotation_pipeline/anno/ensembl-vep/fasta/Homo_sapiens_assembly38.fasta \
--vep-gnomad-af gnomADg_AF \
--cds \
/annotation_pipeline/anno/ensembl-vep/outdir/${study_id}${consent_group_tag}.chr${chrom_number}.normalized_VEP.vcf.gz \
/annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.annotated_remove_modifiers.hpds.vcf.gz &
echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} python stage
wait


echo 'ActiveState=Uploading' > /annotation_pipeline/anno/ActiveState.var
. /annotation_pipeline/anno/ActiveState.var
echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} python stage
fi

if (( $ActiveState == 'Uploading' ))
then
echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} output stage
/usr/local/bin/aws s3 cp /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.annotated_remove_modifiers.hpds.vcf.gz s3://${output_s3_bucket}/genomic-etl/hpds_vcfs/modifiers_removed/ &
/usr/local/bin/aws s3 cp /annotation_pipeline/anno/ensembl-vep/outdir/${study_id}${consent_group_tag}.chr${chrom_number}.normalized_VEP.vcf.gz s3://${output_s3_bucket}/genomic-etl/vep_vcf_output/ &
/usr/local/bin/aws s3 cp /annotation_pipeline/anno/ensembl-vep/${study_name}_${study_id}_TOPMed_WGS_freeze.9b.chr${chrom_number}.hg38${consent_group_tag}.vcf.gz s3://${output_s3_bucket}/genomic-etl/original_vcfs/${study_id}${consent_group_tag}.chr${chrom_number}.original.vcf.gz &

wait


echo 'ActiveState=Done' > /annotation_pipeline/anno/ActiveState.var
. /annotation_pipeline/anno/ActiveState.var
echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} upload stage
fi

if (( $ActiveState == 'Done' ))
then
/usr/local/bin/aws --region=us-east-1 ec2 create-tags --resources $${INSTANCE_ID} --tags Key=AnnotationComplete,Value=true
fi