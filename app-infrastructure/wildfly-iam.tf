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
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/containers/application/dictionary-api.tar.gz"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/containers/application/dictionary-weights.tar.gz"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/releases/jenkins_pipeline_build_${var.stack_githash_long}/pic-sure-wildfly.tar.gz"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/configs/jenkins_pipeline_build_${var.stack_githash_long}/visualization-resource.properties"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/data/${var.dataset_s3_object_key}/fence_mapping.json"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/configs/jenkins_pipeline_build_${var.stack_githash_long}/standalone.xml"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/configs/jenkins_pipeline_build_${var.stack_githash_long}/aggregate-resource.properties"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/configs/jenkins_pipeline_build_${var.stack_githash_long}/aggregate-resource.properties"
    },{
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}",
      "Condition": {
        "StringLike": {
          "s3:prefix": [
            "releases/jenkins_pipeline_build_${var.stack_githash_long}/*",
            "configs/jenkins_pipeline_build_${var.stack_githash_long}*",
            "modules/*",
            "data/${var.dataset_s3_object_key}/*",
            "containers/application/*"
          ]
        }
      }
    },{
      "Action": [
        "ec2:CreateTags"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ec2:*:*:instance/*"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/releases/psama/psama.tar.gz"
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
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/configs/dictionary/weights.csv"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/configs/jenkins_pipeline_build_${var.stack_githash_long}/deploy-psama.sh"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/configs/jenkins_pipeline_build_${var.stack_githash_long}/deploy-dictionary.sh"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/configs/jenkins_pipeline_build_${var.stack_githash_long}/deploy-wildfly.sh"
    }
  ]
}
EOF
}
