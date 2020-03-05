resource "aws_iam_role_policy" "jenkins-s3-policy" {
  name = "jenkins-s3-policy"
  role = aws_iam_role.jenkins-s3-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.deployment-s3-bucket}/*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "jenkins-s3-role" {
  name               = "jenkins-s3-role"
  path               = "/system/"
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

resource "aws_iam_instance_profile" "jenkins-s3-profile" {
  name = "jenkins-s3-profile"
  role = aws_iam_role.jenkins-s3-role.name
}

resource "aws_iam_role_policy_attachment" "attach-s3full-to-jenkinss3role" {
  role       = "jenkins-s3-role"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"

}

resource "aws_iam_role_policy_attachment" "attach-FullAdmin-to-jenkinss3role" {
  role       = "jenkins-s3-role"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

}
