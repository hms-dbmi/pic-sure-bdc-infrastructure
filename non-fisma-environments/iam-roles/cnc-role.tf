resource "aws_iam_role" "hms-dbmi-cnc-role" {
  name               = "hms-dbmi-cnc-role"
  path               = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:sts::${var.aws-account-id}:assumed-role/jenkins-s3-role/${var.jenkins-instance-id}"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "hms-dbmi-cnc-role-profile" {
  name = "hms-dbmi-cnc-role"
  role = aws_iam_role.hms-dbmi-cnc-role.name
}

resource "aws_iam_role_policy_attachment" "attach-s3full-to-hms-dbmi-cnc-role" {
  role       = "hms-dbmi-cnc-role"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"

}

resource "aws_iam_role_policy_attachment" "attach-FullAdmin-to-hms-dbmi-cnc-role" {
  role       = "hms-dbmi-cnc-role"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

}
