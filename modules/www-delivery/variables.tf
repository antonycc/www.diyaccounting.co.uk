
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
variable "domain-name"   {
  type = string
  default = "development.diyaccounting.co.uk"
  description = "The hostname of the website without the www pre-fix"
}
variable "www-domain-name"   {
  type = string
  default = "www.development.diyaccounting.co.uk"
  description = "The hostname of the website"
}
variable "www-certificate"   {
  type = string
  default = "arn:aws:acm:eu-west-2:00development00:certificate/development-0000-0000-0000-0000"
  description = "The certificate matching the hostname of the website"
}
