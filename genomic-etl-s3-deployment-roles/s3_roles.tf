variable "deployment_githash" {
  type = string
}
variable "deployment_githash_long" {
  type = string
}
variable "consent_group_tag"{
  type = string
}


resource "aws_iam_instance_profile" "genomic-etl-deployment-s3-profile" {
  name = aws_iam_role.genomic-etl-deployment-s3-role.name
  role = aws_iam_role.genomic-etl-deployment-s3-role.name
}

resource "aws_iam_role_policy" "genomic-etl-deployment-s3-policy" {
  name = "genomic-etl-deployment-s3-profile-${var.deployment_githash}-{var.study_id}${var.consent_group_tag}-${var.chrom_number}"
  role = aws_iam_role.genomic-etl-deployment-s3-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:CreateTags"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ec2:*:*:instance/*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "genomic-etl-deployment-s3-role" {
  name               = "genomic-etl-deployment-s3-profile-${var.deployment_githash}$-{var.study_id}${var.consent_group_tag}-${var.chrom_number} "
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach-cloudwatch-server-policy-to-genomic-etl-role" {
  role       = aws_iam_role.genomic-etl-deployment-s3-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "attach-cloudwatch-ssm-policy-to-genomic-etl-role" {
  role       = aws_iam_role.genomic-etl-deployment-s3-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
