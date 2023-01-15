provider "aws" {
  region = var.aws_default_region
}

module "cdn" {
  #source = "../.."
  source = "terraform-aws-modules/cloudfront/aws"

  aliases = [var.www-domain-name, var.domain-name]

  comment             = "CloudFront presenting origin as s3://${var.www-domain-name}"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  #wait_for_deployment = false
  #create_monitoring_subscription = true
  default_root_object = "home.html"
  http_version        = "http2"
  realtime_metrics_subscription_status = "Enabled"

  #logging_config = {
  #  bucket = var.logs_aws_s3_bucket_name
  #  target_prefix = "www-delivery-cdn/"
  #}

  origin = {
    www = {
      domain_name = "${var.www-domain-name}.s3-website.${var.aws_default_region}.amazonaws.com"
#    s3_origin_config = {
#      origin_access_identity = "s3_bucket_one"
#    }
    }

    #    www = {
#      domain_name          = var.www-domain_name
#      custom_origin_config = {
#        http_port              = 80
#        https_port             = 443
#        origin_protocol_policy = "match-viewer"
#        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
#      }
#    }
  }

  default_cache_behavior = {
    target_origin_id           = var.www-domain-name
    viewer_protocol_policy     = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
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
