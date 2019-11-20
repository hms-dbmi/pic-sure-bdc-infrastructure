
resource "aws_iam_role_policy" "wildfly-deployment-s3-policy" {
  name = "wildfly-deployment-s3-policy-${var.stack_githash}"
  role = aws_iam_role.wildfly-deployment-s3-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::avillach-datastage-pic-sure-jenkins-dev-builds-3/*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "wildfly-deployment-s3-role" {
  name               = "wildfly-deployment-s3-role-${var.stack_githash}"
  path               = "/deployment/"
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

resource "aws_iam_instance_profile" "wildfly-deployment-s3-profile" {
  name = "wildfly-deployment-s3-profile"
  role = aws_iam_role.wildfly-deployment-s3-role.name
}

resource "aws_iam_role_policy" "httpd-deployment-s3-policy" {
  name = "httpd-deployment-s3-policy"
  role = aws_iam_role.httpd-deployment-s3-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::avillach-datastage-pic-sure-jenkins-dev-builds-3/*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "httpd-deployment-s3-role" {
  name               = "httpd-deployment-s3-role"
  path               = "/deployment/"
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

resource "aws_iam_instance_profile" "httpd-deployment-s3-profile" {
  name = "httpd-deployment-s3-profile"
  role = aws_iam_role.httpd-deployment-s3-role.name
}

resource "aws_iam_role_policy" "hpds-deployment-s3-policy" {
  name = "hpds-deployment-s3-policy"
  role = aws_iam_role.hpds-deployment-s3-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::avillach-datastage-pic-sure-jenkins-dev-builds-3/*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "hpds-deployment-s3-role" {
  name               = "hpds-deployment-s3-role"
  path               = "/deployment/"
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

resource "aws_iam_instance_profile" "hpds-deployment-s3-profile" {
  name = "hpds-deployment-s3-profile"
  role = aws_iam_role.hpds-deployment-s3-role.name
}

