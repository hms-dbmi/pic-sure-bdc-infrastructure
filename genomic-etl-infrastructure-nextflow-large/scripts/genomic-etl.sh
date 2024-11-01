#!/bin/bash

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" --silent http://169.254.169.254/latest/meta-data/instance-id)
sudo /usr/local/bin/aws --region=us-east-1 ec2 create-tags --resources $${INSTANCE_ID} --tags Key=InitComplete,Value=true

export VOLUME_ID=$(/usr/local/bin/aws ec2 describe-volumes --filters Name='tag:label',Values=${study_id}${consent_group_tag}.chr${chrom_number} --query "Volumes[*].VolumeId" --output text)
aws ec2 attach-volume --volume-id $VOLUME_ID --device /dev/sdb --instance-id $INSTANCE_ID --region us-east-1 &
wait
mkdir /annotation_pipeline

while [ ! -d /annotation_pipeline/anno/ ]; do
   echo 'checking mount'
   mount /dev/nvme1n1 /annotation_pipeline
done
echo 'Mount done'

echo 'Init complete, moving to annotation'

export KENT_SRC=/annotation_pipeline/anno/kent-335_base/src
export MACHTYPE=$(uname -m)
export CFLAGS="-fPIC"
export MYSQLINC=$(mysql_config --include | sed -e 's/^-I//g')
export MYSQLLIBS=$(mysql_config --libs)
export PERL5LIB=$PERL5LIB:/annotation_pipeline/anno/cpanm/lib/perl5:/annotation_pipeline/anno/bioperl-1.6.924:/annotation_pipeline/anno/Bio-DB-HTS/lib:/annotation_pipeline/anno/Bio-DB-HTS/blib/arch/auto/Bio/DB/HTS/:/annotation_pipeline/anno/Bio-DB-HTS/blib/arch/auto/Bio/DB/HTS/Faidx:/annotation_pipeline/anno/bioperl-1.6.924:/annotation_pipeline/anno/ensembl/modules:/annotation_pipeline/anno/ensembl-compara/modules:/annotation_pipeline/anno/ensembl-variation/modules:/annotation_pipeline/anno/src/ensembl-funcgen/modules:/annotation_pipeline/anno/lib/perl/5.14.4/:/annotation_pipeline/anno/ensembl-vep:/annotation_pipeline/anno/Bio-DB-HTS/lib:/annotation_pipeline/anno/Bio-DB-HTS/blib/arch/auto/Bio/DB/HTS/:/annotation_pipeline/anno/Bio-DB-HTS/blib/arch/auto/Bio/DB/HTS/Faidx
export HTSLIB_DIR=/annotation_pipeline/anno/htslib/
export PATH=/usr/local/bin:/annotation_pipeline/anno/ensembl-vep:/annotation_pipeline/anno/htslib:/annotation_pipeline/anno/bin:$PATH

. /annotation_pipeline/anno/ensembl-vep/ActiveState.var
echo 'Pipeline starting state is ' $ActiveState

cd /annotation_pipeline/anno/ensembl-vep/
if [ $ActiveState == 'Downloading' ]; then
   echo ${chrom_number} chr${chrom_number} >/annotation_pipeline/anno/ensembl-vep/chrm_rename.txt

   /usr/local/bin/aws sts assume-role --role-arn arn:aws:iam::${input_s3_account}:role/nih-nhlbi-TopMed-EC2Access-S3 --role-session-name "get-genomic-source-file" >/usr/tmp/assume-role-output.txt

   export AWS_ACCESS_KEY_ID=$(grep AccessKeyId /usr/tmp/assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g")
   export AWS_SECRET_ACCESS_KEY=$(grep SecretAccessKey /usr/tmp/assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g")
   export AWS_SESSION_TOKEN=$(grep SessionToken /usr/tmp/assume-role-output.txt | cut -d ':' -f 2 | sed "s/[ ,\"]//g")

   /usr/local/bin/aws s3 cp s3://${input_s3_bucket}/${study_name}_${study_id}_TOPMed_WGS_freeze.${freeze_number}b.chr${chrom_number}.hg38${consent_group_tag}.vcf.gz /annotation_pipeline/anno/ensembl-vep/ &

   wait

   unset AWS_ACCESS_KEY_ID
   unset AWS_SECRET_ACCESS_KEY
   unset AWS_SESSION_TOKEN

   echo 'ActiveState=Filtering' >/annotation_pipeline/anno/ensembl-vep/ActiveState.var
   . /annotation_pipeline/anno/ensembl-vep/ActiveState.var
   echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} download stage
fi

if [ $ActiveState == 'Filtering' ]; then
   /usr/local/bin/bcftools view -Oz --threads 40 -f PASS,. /annotation_pipeline/anno/ensembl-vep/${study_name}_${study_id}_TOPMed_WGS_freeze.${freeze_number}b.chr${chrom_number}.hg38${consent_group_tag}.vcf.gz >/annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.filtered.vcf.gz &
   echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} filter stage

   wait

   echo 'ActiveState=Renaming' >/annotation_pipeline/anno/ensembl-vep/ActiveState.var
   . /annotation_pipeline/anno/ensembl-vep/ActiveState.var
   echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} filter stage
fi

if [ $ActiveState == 'Renaming' ]; then
   /usr/local/bin/bcftools annotate --threads 40 --rename-chrs /annotation_pipeline/anno/ensembl-vep/chrm_rename.txt /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.filtered.vcf.gz | /annotation_pipeline/anno/htslib/bgzip >/annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.renamed.vcf.gz &
   echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} rename stage

   wait

   echo 'ActiveState=Normalizing' >/annotation_pipeline/anno/ensembl-vep/ActiveState.var
   . /annotation_pipeline/anno/ensembl-vep/ActiveState.var
   echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} rename stage
fi

if [ $ActiveState == 'Normalizing' ]; then
   /usr/local/bin/bcftools norm --threads 40 -m -any -f /annotation_pipeline/anno/fasta/Homo_sapiens_assembly38.fasta -o /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.normalized.vcf.gz /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.renamed.vcf.gz &
   echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} normalize stage

   wait

   bgzip -d /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.normalized.vcf.gz &

   wait

   bgzip -f /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.normalized.vcf &

   wait

   tabix /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.normalized.vcf.gz &

   wait

   echo 'ActiveState=Annotating' >/annotation_pipeline/anno/ensembl-vep/ActiveState.var
   . /annotation_pipeline/anno/ensembl-vep/ActiveState.var
   echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} normalize stage
fi

yum install -y java-11-openjdk &
wait
update-alternatives --set java /usr/lib/jvm/java-11-openjdk*/bin/java

if [ $ActiveState == 'Annotating' ]; then
   echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} vep stage
   nextflow run -resume /annotation_pipeline/anno/ensembl-vep/nextflow/workflows/run_vep.nf \
      --vcf /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.normalized.vcf.gz \
      --skip_check 1 \
      --vep_config /annotation_pipeline/anno/ensembl-vep/nextflow/vep_config/vep.ini \
      --bin_size 75000

   echo 'ActiveState=Scripting' >/annotation_pipeline/anno/ensembl-vep/ActiveState.var
   . /annotation_pipeline/anno/ensembl-vep/ActiveState.var
   echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} vep stage
fi

if [ $ActiveState == 'Scripting' ]; then
   python3 /annotation_pipeline/anno/ensembl-vep/hpds_annotation/transform_csq.v3.py \
      -R /annotation_pipeline/anno/ensembl-vep/fasta/Homo_sapiens_assembly38.fasta \
      --vep-gnomad-af gnomADg_AF \
      --mode cds_only \
      /annotation_pipeline/anno/ensembl-vep/outdir/${study_id}${consent_group_tag}.chr${chrom_number}.normalized_VEP.vcf.gz \
      /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.annotated_remove_modifiers.hpds.vcf.gz &
   echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} python stage
   wait

   echo 'ActiveState=Uploading' >/annotation_pipeline/anno/ensembl-vep/ActiveState.var
   . /annotation_pipeline/anno/ensembl-vep/ActiveState.var
   echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} python stage
fi

if [ $ActiveState == 'Uploading' ]; then
   echo $(date +%T) started ${study_id}${consent_group_tag}.chr${chrom_number} output stage
   aws s3 cp /annotation_pipeline/anno/ensembl-vep/${study_id}${consent_group_tag}.chr${chrom_number}.annotated_remove_modifiers.hpds.vcf.gz s3://${output_s3_bucket}/genomic-etl/hpds_vcfs/modifiers_removed/${freeze_number}/ &
   aws s3 cp /annotation_pipeline/anno/ensembl-vep/outdir/${study_id}${consent_group_tag}.chr${chrom_number}.normalized_VEP.vcf.gz s3://${output_s3_bucket}/genomic-etl/vep_vcf_output/${freeze_number}/ &
   aws s3 cp /annotation_pipeline/anno/ensembl-vep/${study_name}_${study_id}_TOPMed_WGS_freeze.${freeze_number}b.chr${chrom_number}.hg38${consent_group_tag}.vcf.gz s3://${output_s3_bucket}/genomic-etl/original_vcfs/${freeze_number}/${study_id}${consent_group_tag}.chr${chrom_number}.original.vcf.gz &

   wait

   echo 'ActiveState=Done' >/annotation_pipeline/anno/ensembl-vep/ActiveState.var
   . /annotation_pipeline/anno/ensembl-vep/ActiveState.var
   echo $(date +%T) finished ${study_id}${consent_group_tag}.chr${chrom_number} upload stage
fi

if [ $ActiveState == 'Done' ]; then
   aws --region=us-east-1 ec2 create-tags --resources $${INSTANCE_ID} --tags Key=AnnotationComplete,Value=true
fi
