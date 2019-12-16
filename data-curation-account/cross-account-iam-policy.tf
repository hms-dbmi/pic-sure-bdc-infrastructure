resource "aws_iam_instance_profile" "curated-datasets-s3-profile" {
  name = "curated-datasets-s3-profile"
  role = aws_iam_role.curated-datasets-s3-role.name
}

resource "aws_iam_role_policy" "curated-datasets-s3-policy" {
  name = "curated-datasets-s3-policy"
  role = aws_iam_role.curated-datasets-s3-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "${var.curated-transfer-s3-arn-path}"
    }
  ]
}
EOF
}

resource "aws_iam_role" "curated-datasets-s3-role" {
  name               = "curated-datasets-s3-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.client-aws-account-role-arn}",
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}