provider "aws" {
  region = var.aws_default_region
}

locals {
  s3_origin_id = var.www-domain-name
}

resource "aws_cloudfront_distribution" "cdn" {

  comment             = "CloudFront presenting origin as s3://${var.www-domain-name}"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  #wait_for_deployment = false
  #create_monitoring_subscription = true
  default_root_object = "home.html"
  http_version        = "http2"
  #realtime_metrics_subscription_status = "Enabled"

  origin {
    domain_name = "${var.www-domain-name}.s3-website.${var.aws_default_region}.amazonaws.com"
    origin_id   = local.s3_origin_id

    #s3_origin_config {
    #  origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    #}
  }

  # Configure logging here if required
  #logging_config {
  #  include_cookies = false
  #  bucket          = "mylogs.s3.amazonaws.com"
  #  prefix          = "myprefix"
  #}

  # If you have domain configured use it here
  #aliases = ["mywebsite.example.com", "s3-static-web-dev.example.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    #forwarded_values {
    #  query_string = false
    #
    #      cookies {
    #        forward = "none"
    #      }
    #    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  #  ordered_cache_behavior {
  #    path_pattern     = "/content/immutable/*"
  #    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
  #    cached_methods   = ["GET", "HEAD", "OPTIONS"]
  #    target_origin_id = local.s3_origin_id

  #forwarded_values {
  #  query_string = false
  #  headers      = ["Origin"]
  #
  #      cookies {
  #        forward = "none"
  #      }
  #    }

  #    min_ttl                = 0
  #    default_ttl            = 86400
  #    max_ttl                = 31536000
  #    compress               = true
  #    viewer_protocol_policy = "redirect-to-https"
  #  }

  # Cache behavior with precedence 1
  #  ordered_cache_behavior {
  #    path_pattern     = "/content/*"
  #    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
  #    cached_methods   = ["GET", "HEAD"]
  #    target_origin_id = local.s3_origin_id
  #
  #    forwarded_values {
  #      query_string = false
  #
  #      cookies {
  #        forward = "none"
  #      }
  #    }
  #
  #    min_ttl                = 0
  #    default_ttl            = 3600
  #    max_ttl                = 86400
  #    compress               = true
  #    viewer_protocol_policy = "redirect-to-https"
  #  }

  #price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      #    restriction_type = "whitelist"
      #    locations        = ["US", "CA", "GB", "DE", "IN", "IR"]
    }
  }

  viewer_certificate = {
    acm_certificate_arn = var.www-certificate
    minimum_protocol_version =  "TLSv1"
    ssl_support_method  = "sni-only"
  }

  tags = {
    Environment = var.environment
  }

}
