include {
  path = find_in_parent_folders()
}
terraform {
  source = "../../../modules/www-diyaccounting-co-uk"
}
inputs = {
  environment = "live"
  logs_aws_s3_bucket_name = "live-www-diyaccounting-co-uk-logs"
  domain_name = "diyaccounting.co.uk"
  www_domain_name = "www.diyaccounting.co.uk"
  www_certificate = "arn:aws:acm:us-east-1:887764105431:certificate/ffb088f1-2c9b-470c-bef3-fb02a1687cbd"
  zone_id= "Z0315522208PWZSSBI9AL"
}
