// Purpose: Terraform declarations of variables used by main.tf

variable "tf_provider" {
  type = string
  default = "aws"
  description = "Read from environment: TF_VAR_tf_provider"
}
variable "aws_default_region"   {
  type = string
  default = "eu-west-2"
  description = "Read from environment: TF_VAR_aws_default_region"
}
variable "environment"   {
  type = string
  default = "development"
  description = "stage or live"
}
variable "logs_aws_s3_bucket_name"   {
  type = string
  default = "development-diyaccounting-co-uk-logs"
  description = "The name of the S3 bucket to store logs"
}
variable "www-domain-name"   {
  type = string
  default = "www.development.diyaccounting.co.uk"
  description = "The hostname of the website"
}
#variable "aws_endpoint" {
#  default = ""
#  description = "Read from environment: TF_VAR_aws_endpoint"
#}

#locals {
#  access_key                  = var.tf_provider == ""
#  secret_key                  = var.tf_provider == ""
#  s3_force_path_style         = var.tf_provider == false
#  skip_credentials_validation = var.tf_provider == false
#  skip_metadata_api_check     = var.tf_provider == false
#  skip_requesting_account_id  = var.tf_provider == false
#  dynamodb_endpoint           = var.tf_provider == var.aws_endpoint
#  iam_endpoint                = var.tf_provider == var.aws_endpoint
#  lambda_endpoint             = var.tf_provider == var.aws_endpoint
#  s3_endpoint                 = var.tf_provider == var.aws_endpoint
#}
