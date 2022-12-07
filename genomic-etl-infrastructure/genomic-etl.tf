
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

variable "subnets" {}

data "template_cloudinit_config" "genomic-user-data" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.genomic-user_data.rendered
  }

}

resource "spot_fleet_request" "genomic-etl-ec2"{
  #TODO - permissioning on necessary role
  iam_fleet_role = ""
  target_capacity = 1
  valid_until = timeadd(timestamp(), 20160m)
  allocation_strategy = "lowestPrice"
  fleet_type = "maintain"
  wait_for_fulfillment = "false"
  terminate_instances_with_expiration = "false"

  dynamic "launch_specification" {
    #TODO - update VPC job to add list of available subnets
    for_each = [for s in var.subnets : {
      subnet_id = s[1]
    }]
    content {
      subnet_id = launch_specification.value.subnet_id
      
      dynamic "instance_type" {
        TODO - establish list of instance types to parse through
        for_each = [for i in var.instanceTypes : {
          instance_type = i[1]
        }]
        content {
          instance_type = launch_specification.value.instance_type
          ami = var.ami-id
          associate_public_ip_address = true

          iam_instance_profile = "jenkins-s3-profile"

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
      }
    }
  }
}