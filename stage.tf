// Purpose: Stage components for the application

resource "aws_s3_bucket" "stage-logs" {
  provider = aws
  bucket = "stage-diyaccounting-co-uk-logs"
  force_destroy = true
  tags = {
    Environment = "stage"
  }
}
resource "aws_s3_bucket_acl" "stage-logs-s3-acl" {
  bucket = aws_s3_bucket.stage-logs.bucket
  acl    = "log-delivery-write"
}
resource "aws_s3_bucket_policy" "stage-logs-s3-policy" {
  bucket = aws_s3_bucket.stage-logs.bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "logs-s3-policy"
    Statement = [
      {
        "Action": "s3:GetBucketAcl",
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::stage-diyaccounting-co-uk-logs",
        "Principal": { "Service": "s3.${var.aws_default_region}.amazonaws.com" }
      },
      {
        "Action": "s3:PutObject" ,
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::stage-diyaccounting-co-uk-logs/*",
        "Condition": { "StringEquals": { "s3:x-amz-acl": "bucket-owner-full-control" } },
        "Principal": { "Service": "s3.${var.aws_default_region}.amazonaws.com" }
      }
    ]
  })
}

resource "aws_s3_bucket" "stage-www" {
  provider = aws
  bucket = "www.stage.diyaccounting.co.uk"
  force_destroy = true
  tags = {
    Environment = "stage"
  }
}
resource "aws_s3_bucket_website_configuration" "stage-www-s3-configuration" {
  bucket = aws_s3_bucket.stage-www.bucket
  index_document {
    suffix = "home.html"
  }
  error_document {
    key = "notfound.html"
  }
}
resource "aws_s3_bucket_logging" "stage-www-s3-logging" {
  bucket = aws_s3_bucket.stage-www.bucket
  target_bucket = aws_s3_bucket.stage-logs.bucket
  target_prefix = "s3-diyaccounting.co.uk/"
}
resource "aws_s3_bucket_policy" "stage-www-s3-policy" {
  bucket = aws_s3_bucket.stage-www.bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "www-s3-policy"
    Statement = [
      {
        "Sid":"AddPerm",
        "Effect":"Allow",
        "Principal": "*",
        "Action":["s3:GetObject"],
        "Resource":["arn:aws:s3:::www.stage.diyaccounting.co.uk/*"]
      }
    ]
  })
}
