resource "aws_iam_instance_profile" "httpd-deployment-s3-profile" {
  name = "httpd-deployment-s3-profile-${var.target_stack}-${local.uniq_name}"
  role = aws_iam_role.httpd-deployment-s3-role.name
}

resource "aws_iam_role_policy" "httpd-deployment-s3-policy" {
  name   = "httpd-deployment-s3-policy-${var.target_stack}-${local.uniq_name}"
  role   = aws_iam_role.httpd-deployment-s3-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/containers/pic-sure-frontend.tar.gz"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/certs/httpd/server.crt"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/certs/httpd/server.chain"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/certs/httpd/server.key"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/certs/httpd/preprod_server.crt"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/certs/httpd/preprod_server.chain"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/certs/httpd/preprod_server.key"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/configs/httpd/httpd-vhosts.conf"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/configs/httpd/picsureui_settings.json"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/configs/httpd/banner_config.json"
    },
    {
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
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/scripts/deploy-httpd.sh"
    },{
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}",
      "Condition": {
        "StringLike": {
          "s3:prefix": [
            "${var.target_stack}/releases/*",
            "${var.target_stack}/configs/*",
            "configs/*",
            "${var.target_stack}/certs/httpd/*",
            "data/*",
            "certs/httpd/*",
            "${var.target_stack}/scripts/*"
          ]
        }
      }
    },{
      "Action": [
        "ec2:CreateTags"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ec2:*:*:instance/*"
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

resource "aws_iam_role" "httpd-deployment-s3-role" {
  name               = "${local.project_no_space}-httpd-deployment-s3-role-${var.target_stack}-${local.uniq_name}"
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

resource "aws_iam_role_policy_attachment" "attach-cloudwatch-server-policy-to-httpd-role" {
  role       = aws_iam_role.httpd-deployment-s3-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy_attachment" "attach-cloudwatch-ssm-policy-to-httpd-role" {
  role       = aws_iam_role.httpd-deployment-s3-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "auth-hpds-deployment-s3-profile" {
  name = "auth-hpds-deployment-s3-profile-${var.target_stack}-${local.uniq_name}"
  role = aws_iam_role.auth-hpds-deployment-s3-role.name
}

resource "aws_iam_role_policy" "auth-hpds-deployment-s3-policy" {
  name   = "auth-hpds-deployment-s3-policy-${var.target_stack}-${local.uniq_name}"
  role   = aws_iam_role.auth-hpds-deployment-s3-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/containers/pic-sure-hpds.tar.gz"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/data/*/javabins_rekeyed*"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/data/*/all/*"
    },{
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::pic-sure-auth-${var.environment_name}-data-export/*"
    },{
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::pic-sure-auth-${var.environment_name}-data-export"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/scripts/deploy-auth-hpds.sh"
    },{
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
            "certs/hpds/*",
            "${var.target_stack}/certs/hpds/*"
          ]
        }
      }
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/configs/hpds/hpds-log4j.properties"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/configs/hpds/hpds-log4j.properties"
    },{
      "Action": [
        "ec2:CreateTags"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ec2:*:*:instance/*"
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

resource "aws_iam_role" "auth-hpds-deployment-s3-role" {
  name               = "${local.project_no_space}-auth-hpds-deployment-s3-role-${var.target_stack}-${local.uniq_name}"
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

resource "aws_iam_role_policy_attachment" "attach-cloudwatch-server-policy-to-auth-hpds-role" {
  role       = aws_iam_role.auth-hpds-deployment-s3-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy_attachment" "attach-cloudwatch-ssm-policy-to-auth-hpds-role" {
  role       = aws_iam_role.auth-hpds-deployment-s3-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "open-hpds-deployment-s3-profile" {
  name = "open-hpds-deployment-s3-profile-${var.target_stack}-${local.uniq_name}"
  role = aws_iam_role.open-hpds-deployment-s3-role.name
}

resource "aws_iam_role_policy" "open-hpds-deployment-s3-policy" {
  name   = "open-hpds-deployment-s3-policy-${var.target_stack}-${local.uniq_name}"
  role   = aws_iam_role.open-hpds-deployment-s3-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/containers/pic-sure-hpds.tar.gz"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/data/*/destigmatized_javabins*"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/configs/hpds/hpds-log4j.properties"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/scripts/deploy-open-hpds.sh"
    },{
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
            "certs/hpds/*",
            "${var.target_stack}/certs/hpds/*"
          ]
        }
      }
    },{
      "Action": [
        "ec2:CreateTags"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ec2:*:*:instance/*"
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

resource "aws_iam_role" "open-hpds-deployment-s3-role" {
  name               = "${local.project_no_space}-open-hpds-deployment-s3-role-${var.target_stack}-${local.uniq_name}"
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

resource "aws_iam_role_policy_attachment" "attach-cloudwatch-server-policy-to-open-hpds-role" {
  role       = aws_iam_role.open-hpds-deployment-s3-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy_attachment" "attach-cloudwatch-ssm-policy-to-open-hpds-role" {
  role       = aws_iam_role.open-hpds-deployment-s3-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


locals {
  project_no_space     = replace(var.env_project, " ", "-")
}

