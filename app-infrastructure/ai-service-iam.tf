variable "ai_service_bedrock_model_id" {
  description = "Bedrock foundation model pic-sure-ai-service may invoke; keep in step with BEDROCK_MODEL_ID in the rendered ai-service.env"
  type        = string
  default     = "openai.gpt-oss-120b-1:0"
}

resource "aws_iam_instance_profile" "ai-service-deployment-profile" {
  name = "ai-service-deployment-profile-${var.target_stack}-${local.uniq_name}"
  role = aws_iam_role.ai-service-deployment-role.name
}

resource "aws_iam_role" "ai-service-deployment-role" {
  name               = "${local.project_no_space}-ai-service-deployment-role-${var.target_stack}-${local.uniq_name}"
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

resource "aws_iam_role_policy" "ai-service-deployment-s3-policy" {
  name   = "ai-service-deployment-s3-policy-${var.target_stack}-${local.uniq_name}"
  role   = aws_iam_role.ai-service-deployment-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/containers/pic-sure-ai-service.tar.gz"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/configs/ai-service/${var.target_stack}/ai-service.env"
    },{
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}/${var.target_stack}/scripts/deploy-ai-service.sh"
    },{
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.stack_s3_bucket}",
      "Condition": {
        "StringLike": {
          "s3:prefix": [
            "${var.target_stack}/containers/*",
            "${var.target_stack}/scripts/*",
            "configs/ai-service/*"
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

# pic-sure-ai-service calls Bedrock with this role (default AWS SDK credential chain).
resource "aws_iam_role_policy" "ai-service-deployment-bedrock-policy" {
  name   = "ai-service-deployment-bedrock-policy-${var.target_stack}-${local.uniq_name}"
  role   = aws_iam_role.ai-service-deployment-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:bedrock:*::foundation-model/${var.ai_service_bedrock_model_id}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach-cloudwatch-server-policy-to-ai-service-role" {
  role       = aws_iam_role.ai-service-deployment-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "attach-cloudwatch-ssm-policy-to-ai-service-role" {
  role       = aws_iam_role.ai-service-deployment-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
