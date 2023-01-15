include {
  path = find_in_parent_folders()
}
terraform {
  source = "../../../modules/www-origin"
}
inputs = {
  environment = "stage"
  logs_aws_s3_bucket_name = "stage-www-diyaccounting-co-uk-logs"
  www-domain-name = "www.stage.diyaccounting.co.uk"
}
