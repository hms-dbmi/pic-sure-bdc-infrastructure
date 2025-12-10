data "aws_region" "current" {}

resource "aws_iam_instance_profile" "wildfly-deployment-profile" {
  name = "wildfly-deployment-profile-${var.target_stack}-${local.uniq_name}"
  role = aws_iam_role.wildfly-deployment-role.name
}

resource "aws_iam_role" "wildfly-deployment-role" {
  name               = "${local.project_no_space}-wildfly-deployment-role-${var.target_stack}-${local.uniq_name}"
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

resource "aws_iam_role_policy" "wildfly-deployment-sm-policy" {
  name   = "wildfly-deployment-sm-policy-${var.target_stack}-${local.uniq_name}"
  role   = aws_iam_role.wildfly-deployment-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:secretsmanager:${data.aws_region.current.name}:${var.app_acct_id}:secret:${var.app_user_secret_name}-*",
        "arn:aws:secretsmanager:${data.aws_region.current.name}:${var.app_acct_id}:secret:${var.app_psql_user_secret_name}-*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach-cloudwatch-server-policy-to-sm-role" {
  role       = aws_iam_role.wildfly-deployment-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "attach-cloudwatch-ssm-policy-to-sm-role" {
  role       = aws_iam_role.wildfly-deployment-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "wildfly-deployment-s3-policy" {
  name   = "wildfly-deployment-s3-policy-${var.target_stack}-${local.uniq_name}"
  role   = aws_iam_role.wildfly-deployment-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/containers/dictionary-api.tar.gz"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/containers/pic-sure-wildfly.tar.gz"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/containers/psama.tar.gz"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/data/*/fence_mapping.json"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/configs/wildfly/standalone.xml"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/configs/wildfly/aggregate-resource.properties"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/configs/wildfly/visualization-resource.properties"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/configs/psama/psama.env"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/configs/picsure-dictionary/picsure-dictionary.env"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/scripts/deploy-psama.sh"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/scripts/deploy-dictionary.sh"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/scripts/restart-dictionary-container.sh"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/scripts/deploy-wildfly.sh"
    },
    {
      "Action": [
        "ec2:CreateTags"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ec2:*:*:instance/*"
    },
    {
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}",
      "Condition": {
        "StringLike": {
          "s3:prefix": [
            "${var.target_stack}/configs/*",
            "configs/*",
            "data/*",
            "${var.target_stack}/containers/*",
            "${var.target_stack}/scripts/*",
            "certs/wildfly/*",
            "${var.target_stack}/certs/wildfly/*"
          ]
        }
      }
    },
    {
        "Sid": "SharedParameterAccess",
        "Effect": "Allow",
        "Action": [
            "ssm:GetParameter",
            "kms:Decrypt"
        ],
        "Resource": [
            "arn:aws:ssm:us-east-1:752463128620:parameter/org/srce/*",
            "arn:aws:kms:us-east-1:752463128620:key/3379fd31-06ba-45fc-bbb1-903665775ef8"
        ]
    }
  ]
}
EOF
}
