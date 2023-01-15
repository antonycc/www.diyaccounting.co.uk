include {
  path = find_in_parent_folders()
}
#dependency "www-origin" {
#  config_path = "../www-origin"
#  skip_outputs = true
#}
terraform {
  source = "../../../modules/www-delivery"
}
inputs = {
  environment = "stage"
  logs_aws_s3_bucket_name = "stage-www-diyaccounting-co-uk-logs"
  domain-name = "stage.diyaccounting.co.uk"
  www-domain-name = "www.stage.diyaccounting.co.uk"
  #environment = dependency.www-origin.environment
  #logs_aws_s3_bucket_name = dependency.www-origin.logs_aws_s3_bucket_name
  #domain-name = dependency.www-origin.domain-name
  #www-domain-name = dependency.www-origin.www-domain-name
  www-certificate = "arn:aws:acm:us-east-1:135367859851:certificate/1032b155-22da-4ae0-9f69-e206f825458b"
}
