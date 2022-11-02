
data "template_file" "genomic-user_data" {
  template = file("scripts/genomic-etl.sh")
  vars = {
    output_s3_bucket = var.output_s3_bucket
    input_s3_bucket = var.input_s3_bucket
    study_id = var.study_id
    chrom_number = var.chrom_number
    study_name = var.study_name
    study_consent_group = var.study_consent_group
    consent_group_tag = var.consent_group_tag
    deployment_githash = var.deployment_githash
    s3_role =  var.s3_role
    
  }
}

data "template_cloudinit_config" "genomic-user-data" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.genomic-user_data.rendered
  }

}

resource "aws_instance" "genomic-etl-ec2" {
 
  ami           = var.ami-id
  instance_type = "m5.12xlarge"

  associate_public_ip_address = true

  subnet_id = var.genomic-etl-subnet-us-east-id

  iam_instance_profile = "genomic-etl-deployment-s3-profile-${var.deployment_githash}-${var.study_id}${var.consent_group_tag}-${var.chrom_number}"

  user_data = data.template_cloudinit_config.genomic-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.traffic-to-ssm.id,
    aws_security_group.outbound-to-public-internet.id
  ]
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 1000
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "Genomic ETL Annotation Pipeline - ${var.study_id}${var.consent_group_tag} Chromosome ${var.chrom_number}"
    automaticPatches = "1"
  }

}