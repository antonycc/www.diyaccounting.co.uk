include {
  path = find_in_parent_folders()
}
terraform {
  source = "../../../modules/www-diyaccounting-co-uk"
}
inputs = {
  environment = "stage"
  logs_aws_s3_bucket_name = "stage-www-diyaccounting-co-uk-logs"
  domain_name = "stage.diyaccounting.co.uk"
  www_domain_name = "www.stage.diyaccounting.co.uk"
  www_certificate = "arn:aws:acm:us-east-1:887764105431:certificate/799f0886-d540-42a5-84a7-6cfcb47e7308"
  zone_id= "Z0315522208PWZSSBI9AL"

}
