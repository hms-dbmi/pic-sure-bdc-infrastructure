
data "template_file" "genomic-user_data" {
  template = file("scripts/genomic-etl.sh")
  vars = {
    output_s3_bucket = var.output_s3_bucket
    input_s3_account = var.input_s3_account
    input_s3_bucket = var.input_s3_bucket
    study_id = var.study_id
    chrom_number = var.chrom_number
    study_name = var.study_name
    study_consent_group = var.study_consent_group
    consent_group_tag = var.consent_group_tag
    deployment_githash = var.deployment_githash
    s3_role =  var.s3_role
    freeze_number = var.freeze_number
  }
}

locals {
  az1 = "${var.az == "us-east-1a" ? (var.genomic-etl-subnet-1a-id) : ""}"
  az2 = "${var.az == "us-east-1b" ? (var.genomic-etl-subnet-1b-id) : ""}"
  az3 = "${var.az == "us-east-1c" ? (var.genomic-etl-subnet-1c-id) : ""}"
  az4 = "${var.az == "us-east-1d" ? (var.genomic-etl-subnet-1d-id) : ""}"
  az5 = "${var.az == "us-east-1f" ? (var.genomic-etl-subnet-1f-id) : ""}"

  subid =  "${coalesce(local.az1,local.az2, local.az3, local.az4, local.az5)}"
     
  instanceList = [
       {
        "type" =  "m6i.4xlarge"
      },
       {
        "type" =  "c6i.4xlarge"
      }, {
        "type" =  "r6i.4xlarge"
      },
      {
        "type" =  "r6i.2xlarge"
      },
      {
        "type" =  "r5n.2xlarge"
      },
      {
        "type" =  "r5.2xlarge"
      },
      {
        "type" =  "c5.4xlarge"
      },
      {
        "type" =  "m5n.4xlarge"
      },
      {
        "type" =  "c5n.4xlarge"
      },
      {
        "type" =  "m5.4xlarge"
      },
      {
        "type" =  "r5.4xlarge"
      }

]
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

resource "aws_ebs_volume" "genomic-etl-volume"{
  availability_zone = var.az
  snapshot_id = "snap-0a0957538f16a171b"
  type="gp3"
  tags = {
    label = "${var.study_id}${var.consent_group_tag}.chr${var.chrom_number}"
  }
} 

resource "aws_spot_fleet_request" "genomic-etl-ec2"{
  iam_fleet_role = "arn:aws:iam::900561893673:role/aws-service-role/spotfleet.amazonaws.com/AWSServiceRoleForEC2SpotFleet"
  target_capacity = 1
  allocation_strategy = "capacityOptimized"
  fleet_type = "maintain"
  wait_for_fulfillment = "false"
  terminate_instances_with_expiration = "false"
  replace_unhealthy_instances = "true"

  dynamic "launch_specification" {
    for_each = [for s in local.instanceList :{
        subnet_id = local.subid
        instance_type = s.type
    }]
    content {
      subnet_id = launch_specification.value.subnet_id
      instance_type = launch_specification.value.instance_type
      ami = var.ami-id
      associate_public_ip_address = true

      iam_instance_profile = "jenkins-s3-profile"

      user_data = data.template_cloudinit_config.genomic-user-data.rendered

      vpc_security_group_ids = [
          "sg-0dba36beb3a630b47"
      ]
      root_block_device {
        delete_on_termination = true
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