resource "aws_iam_role" "wildfly-deployment-sm-role" {
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "wildfly-deployment-sm-policy" {
  name   = "wildfly-deployment-sm-policy-${var.target_stack}-${local.uniq_name}"
  role   = aws_iam_role.wildfly-deployment-sm-role.id
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": [
            "secretsmanager:GetSecretValue"
        ],
        "Effect": "Allow",
        "Resource": "arn:aws:secretsmanager:${var.aws_region}:${var.app_acct_id}:secret:${var.app_user_secret_name}"
        }
    ]
}
EOF
}