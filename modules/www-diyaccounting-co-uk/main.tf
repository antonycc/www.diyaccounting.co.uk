// Purpose: Use Terraform to deploy infrastructure for a static site
// Usage:
// $ terragrunt plan
// $ terragrunt apply -auto-approve
// $ terragrunt destroy -auto-approve
// See:
//   https://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html
//   https://medium.com/runatlantis/hosting-our-static-site-over-ssl-with-s3-acm-cloudfront-and-terraform-513b799aec0f
//   https://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html
//   https://blog.gruntwork.io/how-to-manage-multiple-environments-with-terraform-using-terragrunt-2c3e32fc60a8
//   https://towardsaws.com/provision-a-static-website-on-aws-s3-and-cloudfront-using-terraform-d8004a8f629a
//   https://gist.github.com/danihodovic/a51eb0d9d4b29649c2d094f4251827dd
//
// Manual Steps to create certificates for CloudFront SSL termination:
// * Use the AWS Certificate Manager to create an SSL cert for:
//      www.diyaccounting.co.uk and diyaccounting.co.uk
//      www.stage.diyaccounting.co.uk and stage.diyaccounting.co.uk
// * Add the certificate URL to the terragrunt.hcl for the respective environments

provider "aws" {
  region = var.aws_default_region
}

// Logging bucket
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

// Origin bucket
resource "aws_s3_bucket" "www-origin" {
  provider = aws
  bucket = var.www_domain_name
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

// Content delivery
locals {
  s3_origin_id = var.www_domain_name
}
resource "aws_cloudfront_distribution" "cdn" {

  comment             = "s3://${var.www_domain_name}"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  default_root_object = "home.html"
  http_version        = "http2"

  aliases = [var.www_domain_name, var.domain_name]

  origin {
    domain_name = aws_s3_bucket.www-origin.bucket_regional_domain_name
    // "www.stage.diyaccounting.co.uk"
    //var.www-domain_name
    //domain_name = "${var.www-domain_name}.s3-website.${var.aws_default_region}.amazonaws.com"
    origin_id   = local.s3_origin_id
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.www_certificate
    minimum_protocol_version =  "TLSv1"
    ssl_support_method  = "sni-only"
  }

  tags = {
    Environment = var.environment
  }
}

// Domain name configuration
resource "aws_route53_record" "domain_name" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name = aws_cloudfront_distribution.cdn.domain_name
    zone_id = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "www_domain_name" {
  zone_id = var.zone_id
  name    = var.www_domain_name
  type    = "A"
  alias {
    name = aws_cloudfront_distribution.cdn.domain_name
    zone_id = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
