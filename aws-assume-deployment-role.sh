#!/usr/bin/env bash
# Purpose: Assume a role for the deployment
# Usage: ./aws-assume-deployment-role.sh
# Note: Requires privileges in the current environment to create an IAM user
# shellcheck disable=SC2016
role_to_assume='arn:aws:iam::887764105431:role/static-site-deploy'
aws iam assume-role \
  --role-name "${role_to_assume?}"
