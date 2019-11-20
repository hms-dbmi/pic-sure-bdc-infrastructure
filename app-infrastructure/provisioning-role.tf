/*
variable "s3bucket" {
  type        = string
  description = "The s3 Bucket with app-layer deployment artifacts for this deployment."
}

resource "aws_iam_role" "app-provisioning-policy" {
  name = format("wildfly-provisioning-role-%v", var.s3bucket)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": [
        format("arn:aws:s3:::%v", var.s3bucket)
        format("arn:aws:s3:::%v/*", var.s3bucket)
      ]
    }
  ]
}
EOF

  tags = {
      tag-key = "tag-value"
  }
}

data "aws_iam_policy_document" "wildfly-provisioning-policy" {
  statement {
    sid = "1"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${}",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "",
        "home/",
        "home/&{aws:username}/",
      ]
    }
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}/home/&{aws:username}",
      "arn:aws:s3:::${var.s3_bucket_name}/home/&{aws:username}/*",
    ]
  }
}

resource "aws_iam_policy" "wildfly-provisioning-policy" {
  name   = "example_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.example.json
}
*/