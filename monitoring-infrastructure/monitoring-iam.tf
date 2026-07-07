resource "aws_iam_role" "monitoring-ec2-role" {
  name               = "monitoring-ec2-role-${local.uniq_name}"
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

resource "aws_iam_role_policy_attachment" "attach-cloudwatch-server-policy-to-monitoring-role" {
  role       = aws_iam_role.monitoring-ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "attach-ssm-managed-policy-to-monitoring-role" {
  role       = aws_iam_role.monitoring-ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "monitoring-inline-policy" {
  name   = "monitoring-inline-policy-${local.uniq_name}"
  role   = aws_iam_role.monitoring-ec2-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Ec2DescribeForServiceDiscovery",
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "MonitoringDeployObjectAccess",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/*"
    },
    {
      "Sid": "MonitoringDeployBucketList",
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "monitoring" {
  name = "monitoring-profile-${local.uniq_name}"
  role = aws_iam_role.monitoring-ec2-role.name
}
