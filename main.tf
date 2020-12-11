/*
Purpose - 2 S3 Buckets with different Life Cycle Policy
Developer - K.Janarthanan
Date - 10/12/2020
*/

#Get IAMRole details
data "aws_iam_role" "iamrole" {
  name = var.rolename
}

#Getting SuperUSer details
data "aws_iam_user" "superuser" {
  user_name = var.terraformuser
}

#Get IAM user details
data "aws_iam_user" "iamuser" {
  user_name = var.iamuser
}

# First Bucket creation
resource "aws_s3_bucket" "first_bucket" {
  bucket        = var.firstbucket
  force_destroy = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "${var.firstbucket} life cycle rule"
    enabled = true
    prefix  = "bulk-submissions/*"

    tags = {
      "rule" = "${var.firstbucket} life cycle rule"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_policy" "firstbucketpolicy" {
  depends_on = [aws_s3_bucket.first_bucket]
  bucket     = aws_s3_bucket.first_bucket.id

  policy = <<POLICY
{
	"Version": "2012-10-17",
	"Id": "Policy1",
	"Statement": [
		{
			"Sid": "Stmt2",
			"Effect": "Deny",
			"Principal": "*",
			"Action": "s3:*",
			"Resource": "arn:aws:s3:::${var.firstbucket}",
			"Condition": {
				"ArnNotEquals": {
					"aws:PrincipalArn": [
          "${data.aws_iam_role.iamrole.arn}",
          "${data.aws_iam_user.superuser.arn}"
          ]
				  }
		  	}
		  }
	  ]
}
POLICY
}

#Second Bucket creation
resource "aws_s3_bucket" "second_bucket" {
  bucket        = var.secondbucket
  force_destroy = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "${var.secondbucket} life cycle rule"
    enabled = true
    prefix  = "*"

    tags = {
      "rule" = "${var.secondbucket} life cycle rule"
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_policy" "secondbucketpolicy" {
  depends_on = [aws_s3_bucket.second_bucket]
  bucket     = aws_s3_bucket.second_bucket.id

  policy = <<POLICY
{
	"Version": "2012-10-17",
	"Id": "Policy2",
	"Statement": [
		{
			"Sid": "Stmt2",
			"Effect": "Deny",
			"Principal": "*",
			"Action": "s3:*",
			"Resource": "arn:aws:s3:::${var.secondbucket}",
			"Condition": {
				"ArnNotEquals": {
					"aws:PrincipalArn": [
            "${data.aws_iam_role.iamrole.arn}",
            "${data.aws_iam_user.iamuser.arn}",
            "${data.aws_iam_user.superuser.arn}"
          ]
          
				  }
		  	}
		  }
	  ]
}
POLICY
}

#Creation of IAM Policy
resource "aws_iam_policy" "iampolicy" {
  name        = var.policyname
  description = "Only allows this role to access ${var.firstbucket} and ${var.secondbucket}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${var.firstbucket}"
        },
         {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${var.secondbucket}"
        }
    ]
}
EOF
}

#Attaching Policy to IAM role
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = var.rolename
  policy_arn = aws_iam_policy.iampolicy.arn
}