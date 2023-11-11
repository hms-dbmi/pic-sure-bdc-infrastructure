
resource "aws_iam_instance_profile" "wildfly-deployment-s3-profile" {
  name = "wildfly-deployment-s3-profile-${var.target_stack}-${local.uniq_name}"
  role = aws_iam_role.wildfly-deployment-s3-role.name
}

resource "aws_iam_role_policy" "wildfly-deployment-s3-policy" {
  name   = "wildfly-deployment-s3-policy-${var.target_stack}-${local.uniq_name}"
  role   = aws_iam_role.wildfly-deployment-s3-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
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
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/configs/jenkins_pipeline_build_${var.stack_githash_long}/resources-registration.sql"
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
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/modules/*"
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
            "data/${var.dataset_s3_object_key}/*"
          ]
        }
      }
    },{
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

resource "aws_iam_role" "wildfly-deployment-s3-role" {
  name               = "${local.project_no_space}-wildfly-deployment-s3-role-${var.target_stack}-${local.uniq_name}"
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

resource "aws_iam_role_policy_attachment" "attach-cloudwatch-server-policy-to-wildfly-role" {
  role       = aws_iam_role.wildfly-deployment-s3-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy_attachment" "attach-cloudwatch-ssm-policy-to-wildfly-role" {
  role       = aws_iam_role.wildfly-deployment-s3-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


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
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/releases/jenkins_pipeline_build_${var.stack_githash_long}/pic-sure-ui.tar.gz"
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
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/configs/jenkins_pipeline_build_${var.stack_githash_long}/httpd-vhosts.conf"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/configs/jenkins_pipeline_build_${var.stack_githash_long}/picsureui_settings.json"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/data/${var.dataset_s3_object_key}/fence_mapping.json"
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
            "certs/httpd/*",
            "data/${var.dataset_s3_object_key}/*"
          ]
        }
      }
    },{
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
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/releases/jenkins_pipeline_build_${var.stack_githash_long}/pic-sure-hpds.tar.gz"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/data/${var.dataset_s3_object_key}/javabins_rekeyed.tar.gz"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/data/${var.genomic_dataset_s3_object_key}/all/*"
    },{
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}",
      "Condition": {
        "StringLike": {
          "s3:prefix": [
            "data/${var.genomic_dataset_s3_object_key}/*",
            "data/${var.dataset_s3_object_key}/*",
            "releases/jenkins_pipeline_build_${var.stack_githash_long}/*"
          ]
        }
      }
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/configs/jenkins_pipeline_build_${var.stack_githash_long}/hpds-log4j.properties"
    },{
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
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/releases/jenkins_pipeline_build_${var.stack_githash_long}/pic-sure-hpds.tar.gz"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/data/${var.destigmatized_dataset_s3_object_key}/destigmatized_javabins_rekeyed.tar.gz"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/configs/jenkins_pipeline_build_${var.stack_githash_long}/hpds-log4j.properties"
    },{
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/*",
      "Condition": {
        "StringLike": {
          "s3:prefix": [
            "data/${var.destigmatized_dataset_s3_object_key}/*",
            "releases/jenkins_pipeline_build_${var.stack_githash_long}/*",
            "configs/jenkins_pipeline_build_${var.stack_githash_long}/*"
          ]
        }
      }
    },{
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


resource "aws_iam_instance_profile" "dictionary-deployment-s3-profile" {
  name = "dictionary-deployment-s3-profile-${var.target_stack}-${local.uniq_name}"
  role = aws_iam_role.dictionary-deployment-s3-role.name
}

resource "aws_iam_role_policy" "dictionary-deployment-s3-policy" {
  name   = "dictionary-deployment-s3-policy-${var.target_stack}-${local.uniq_name}"
  role   = aws_iam_role.dictionary-deployment-s3-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/releases/jenkins_pipeline_build_${var.stack_githash_long}/pic-sure-hpds-dictionary-resource.tar.gz"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/data/${var.dataset_s3_object_key}/fence_mapping.json"
    },{
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/*",
      "Condition": {
        "StringLike": {
          "s3:prefix": [
            "releases/jenkins_pipeline_build_${var.stack_githash_long}/*",
            "data/${var.dataset_s3_object_key}/*"
          ]
        }
      }
    },{
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

resource "aws_iam_role" "dictionary-deployment-s3-role" {
  name               = "${local.project_no_space}-dictionary-deployment-s3-role-${var.target_stack}-${local.uniq_name}"
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

resource "aws_iam_role_policy_attachment" "attach-cloudwatch-server-policy-to-dictionary-role" {
  role       = aws_iam_role.dictionary-deployment-s3-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy_attachment" "attach-cloudwatch-ssm-policy-to-dictionary-role" {
  role       = aws_iam_role.dictionary-deployment-s3-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

locals {
  project_no_space     = replace(var.env_project, " ", "-")
}

