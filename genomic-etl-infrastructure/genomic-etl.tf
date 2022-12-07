
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

locals {
    subnetList = [
  {
    "subnetId" = (var.genomic-etl-subnet-1a-id)
    "typeList" = ["r5.2xlarge", "c5.2xlarge", "c5.4xlarge", "m5.2xlarge", "m5.4xlarge"]
  },
    {
    "subnetId" = (var.genomic-etl-subnet-1b-id)
    "typeList" = ["r5.2xlarge", "c5.2xlarge", "c5.4xlarge", "m5.2xlarge"]
  },
    {
    "subnetId" = (var.genomic-etl-subnet-1c-id)
    "typeList" = ["r5.2xlarge", "c5.2xlarge", "c5.4xlarge", "m5.2xlarge", "m5.4xlarge"]
  },
    {
    "subnetId" = (var.genomic-etl-subnet-1d-id)
    "typeList" = ["r5.2xlarge", "c5.2xlarge", "m5.2xlarge", "m5.4xlarge"]
  },
  {
    "subnetId" = (var.genomic-etl-subnet-1f-id)
    "typeList" = ["r5.2xlarge", "c5.2xlarge", "c5.4xlarge", "m5.2xlarge", "m5.4xlarge"]
  }]
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

resource "spot_fleet_request" "genomic-etl-ec2"{
  iam_fleet_role = "arn:aws:iam::900561893673:role/aws-service-role/spotfleet.amazonaws.com/AWSServiceRoleForEC2SpotFleet"
  target_capacity = 1
  valid_until = timeadd(timestamp(), "20160m")
  allocation_strategy = "lowestPrice"
  fleet_type = "maintain"
  wait_for_fulfillment = "false"
  terminate_instances_with_expiration = "false"

  dynamic "launch_specification" {
    for_each = [for s in local.subnetList :{
        subnet_id = s.value["subnetId"]
        typeList = s.value["typeList"]
    }]
    content {
      subnet_id = launch_specification.value.subnet_id
      ami = var.ami-id
      associate_public_ip_address = true

      iam_instance_profile = "jenkins-s3-profile"

      user_data = data.template_cloudinit_config.genomic-user-data.rendered

      vpc_security_group_ids = [
          "sg-0dba36beb3a630b47"
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
    
      dynamic "instance_type" {
        for_each = [for i in launch_specification.value["typeList"] : {
          instance_type = i
        }]
        content {
          instance_type = instance_type.value
        }
      }
    }
  }
}