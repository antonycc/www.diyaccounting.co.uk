#!/usr/bin/env bash
# Purpose: Set AWS credentials in the current environment
# Usage:
# $ source ./setenv-stage.sh
# shellcheck disable=SC2016

#export ENVIRONMENT='stage'
export WWW_DOMAIN_NAME='www.stage.diyaccounting.co.uk'
#export LOGGING_BUCKET='stage-diyaccounting-co-uk-logs'
#export LOGGING_LEVEL='INFO'
export WEBSITE_ENDPOINT="http://${WWW_DOMAIN_NAME?}.s3-website.eu-west-2.amazonaws.com"
export SPRING_PROFILES_ACTIVE='stage'
