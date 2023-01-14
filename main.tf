// Purpose: Use Terraform to deploy static site from this project
// Usage:
// $ terraform plan
// $ terraform apply -auto-approve
// $ terraform destroy -auto-approve
// See:
//   https://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html
//   https://medium.com/runatlantis/hosting-our-static-site-over-ssl-with-s3-acm-cloudfront-and-terraform-513b799aec0f
//   https://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html
//
// Manual Steps to create a public website with CloudFront providing SSL termination:
// * Create a distribution in CloudFront for www.diyaccounting.co.uk and diyaccounting.co.uk
// * Use the AWS Certificate Manager to create an SSL cert for www.diyaccounting.co.uk and diyaccounting.co.uk
// * Create an A name for diyaccounting.co.uk and a CNAME for www.diyaccounting.co.uk mapping both to cloudfront

provider "aws" {
  region                      = var.aws_default_region
  access_key                  = local.access_key
  secret_key                  = local.secret_key
  //s3_force_path_style         = local.s3_force_path_style
  s3_use_path_style         = local.s3_force_path_style
  skip_credentials_validation = local.skip_credentials_validation
  skip_metadata_api_check     = local.skip_metadata_api_check
  skip_requesting_account_id  = local.skip_requesting_account_id
  endpoints {
    dynamodb = local.dynamodb_endpoint
    iam      = local.iam_endpoint
    lambda   = local.lambda_endpoint
    s3       = local.s3_endpoint
  }
}
