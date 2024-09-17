
data "template_file" "genomic-user_data" {
  template = file("scripts/genomic-etl.sh")
  vars = {
    output_s3_bucket = var.output_s3_bucket
    study_id = var.study_id
    chrom_number = var.chrom_number
    study_name = var.study_name
    s3_role =  var.s3_role
  }
}

locals {
  subid = (var.genomic-etl-subnet-1b-id)
    az = "us-east-1b"
    instanceList = [
       {
    "subnetId" = (local.subid)
    "type" =  "r5.4xlarge"
  },
      {
    "subnetId" = (local.subid)
    "type" =  "r5a.4xlarge"
  },
    {
    "subnetId" = (local.subid)
    "type" =  "r5n.4xlarge"
  },
   {
    "subnetId" = (local.subid)
    "type" =  "r5b.4xlarge"
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
  availability_zone = local.az
  snapshot_id = "snap-0a0957538f16a171b"
  type="gp3"
  tags = {
    label = "${var.study_id}.chr${var.chrom_number}"
  }
} 

resource "aws_spot_fleet_request" "genomic-etl-ec2"{
  iam_fleet_role = "arn:aws:iam::900561893673:role/aws-service-role/spotfleet.amazonaws.com/AWSServiceRoleForEC2SpotFleet"
  target_capacity = 1
  allocation_strategy = "capacityOptimized"
  fleet_type = "maintain"
  wait_for_fulfillment = "false"
  terminate_instances_with_expiration = "false"

  dynamic "launch_specification" {
    for_each = [for s in local.instanceList :{
        subnet_id = s.subnetId
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
        encrypted             = true
        volume_size           = 1000
      }

      tags = {
        Owner       = "Avillach_Lab"
        Environment = "development"
        Name        = "Genomic ETL Annotation Pipeline - ${var.study_id} Chromosome ${var.chrom_number}"
        automaticPatches = "1"
      }
      }
    }
  }