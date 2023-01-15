// Purpose: Use Terraform to deploy static site from this project
// Usage:
// $ terraform plan
// $ terraform apply -auto-approve
// $ terraform destroy -auto-approve
// See:
//   https://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html
//   https://medium.com/runatlantis/hosting-our-static-site-over-ssl-with-s3-acm-cloudfront-and-terraform-513b799aec0f
//   https://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html
//   https://blog.gruntwork.io/how-to-manage-multiple-environments-with-terraform-using-terragrunt-2c3e32fc60a8
//
// Manual Steps to create a public website with CloudFront providing SSL termination:
// * Create a distribution in CloudFront for www.diyaccounting.co.uk and diyaccounting.co.uk
// * Use the AWS Certificate Manager to create an SSL cert for www.diyaccounting.co.uk and diyaccounting.co.uk
// * Create an A name for diyaccounting.co.uk and a CNAME for www.diyaccounting.co.uk mapping both to cloudfront

provider "aws" {
  region                      = var.aws_default_region
  #access_key                  = local.access_key
  #secret_key                  = local.secret_key
  //s3_force_path_style         = local.s3_force_path_style
  #s3_use_path_style         = local.s3_force_path_style
  #skip_credentials_validation = local.skip_credentials_validation
  #skip_metadata_api_check     = local.skip_metadata_api_check
  #skip_requesting_account_id  = local.skip_requesting_account_id
  #endpoints {
  #  dynamodb = local.dynamodb_endpoint
  #  iam      = local.iam_endpoint
  #  lambda   = local.lambda_endpoint
  #  s3       = local.s3_endpoint
  #}
}

resource "aws_s3_bucket" "logs" {
  provider = aws
  bucket = var.logs_aws_s3_bucket_name
  force_destroy = true
  tags = {
    Environment = var.environment
  }
}
resource "aws_s3_bucket_acl" "logs-s3-acl" {
  bucket = aws_s3_bucket.logs.bucket
  acl    = "log-delivery-write"
}
resource "aws_s3_bucket_policy" "logs-s3-policy" {
  bucket = aws_s3_bucket.logs.bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "logs-s3-policy"
    Statement = [
      {
        "Action": "s3:GetBucketAcl",
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.logs.bucket}",
        "Principal": { "Service": "s3.${var.aws_default_region}.amazonaws.com" }
      },
      {
        "Action": "s3:PutObject" ,
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.logs.bucket}/*",
        "Condition": { "StringEquals": { "s3:x-amz-acl": "bucket-owner-full-control" } },
        "Principal": { "Service": "s3.${var.aws_default_region}.amazonaws.com" }
      }
    ]
  })
}

resource "aws_s3_bucket" "www-origin" {
  provider = aws
  bucket = var.www-domain-name
  force_destroy = true
  tags = {
    Environment = var.environment
  }
}
resource "aws_s3_bucket_website_configuration" "www-origin-s3-configuration" {
  bucket = aws_s3_bucket.www-origin.bucket
  index_document {
    suffix = "home.html"
  }
  error_document {
    key = "notfound.html"
  }
}
resource "aws_s3_bucket_logging" "www-origin-s3-logging" {
  bucket = aws_s3_bucket.www-origin.bucket
  target_bucket = aws_s3_bucket.logs.bucket
  target_prefix = "www-origin-s3/"
}
resource "aws_s3_bucket_policy" "www-origin-s3-policy" {
  bucket = aws_s3_bucket.www-origin.bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "www-s3-policy"
    Statement = [
      {
        "Sid":"AddPerm",
        "Effect":"Allow",
        "Principal": "*",
        "Action":["s3:GetObject"],
        "Resource":["arn:aws:s3:::${aws_s3_bucket.www-origin.bucket}/*"]
      }
    ]
  })
}
