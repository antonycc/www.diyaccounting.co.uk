#!/usr/bin/env bash
# Purpose: Set AWS credentials in the current environment
# Usage:
# $ source ./setenv-live.sh
# shellcheck disable=SC2016

export ENVIRONMENT='live'
export WWW_DOMAIN_NAME='www.live.diyaccounting.co.uk'
export LOGGING_BUCKET='live-diyaccounting-co-uk-logs'
export LOGGING_LEVEL='INFO'
export WEBSITE_ENDPOINT="http://${WWW_DOMAIN_NAME?}.s3-website.eu-west-2.amazonaws.com"
export SPRING_PROFILES_ACTIVE="${ENVIRONMENT?}"
