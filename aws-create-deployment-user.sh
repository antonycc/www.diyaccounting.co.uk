#!/usr/bin/env bash
# Purpose: Create a user for the deployment and local execution lambdas
# Usage: ./scripts/aws-create-deployment-user.sh [--script]
# Note: Requires privileges in the current environment to create an IAM user
# Note: A plain text file is generated containing the key, the current format is excluded from Git using .gitignore
# shellcheck disable=SC2016
deployment_user_name='diyaccounting-co-uk-www-deployment'
aws iam create-user \
  --user-name "${deployment_user_name?}"

access_key_json=$(aws iam create-access-key \
  --user-name "${deployment_user_name?}")
deployment_user_aws_access_key_id=$(echo "${access_key_json?}" | jq '.AccessKey.AccessKeyId' --raw-output)
deployment_user_aws_secret_access_key=$(echo "${access_key_json?}" | jq '.AccessKey.SecretAccessKey' --raw-output)
deployment_user_keys=$({
  echo "export AWS_ACCESS_KEY_ID='${deployment_user_aws_access_key_id?}'"
  echo "export AWS_SECRET_ACCESS_KEY='${deployment_user_aws_secret_access_key?}'"
  echo "aws sts get-caller-identity"
})

pids=()
aws iam attach-user-policy \
  --user-name "${deployment_user_name?}" \
  --policy-arn "$(aws iam list-policies \
  --query 'Policies[?PolicyName==`CloudWatchLogsFullAccess`].{ARN:Arn}' --output text)" &
pids+=($!)
aws iam attach-user-policy \
  --user-name "${deployment_user_name?}" \
  --policy-arn "$(aws iam list-policies \
  --query 'Policies[?PolicyName==`AmazonS3FullAccess`].{ARN:Arn}' --output text)" &
pids+=($!)
aws iam attach-user-policy \
  --user-name "${deployment_user_name?}" \
  --policy-arn "$(aws iam list-policies \
  --query 'Policies[?PolicyName==`AmazonDynamoDBFullAccess`].{ARN:Arn}' --output text)" &
pids+=($!)
for pid in ${pids[*]}; do
    wait "${pid?}"
done

if [ "$1" == '--script' ];
then
  echo "${deployment_user_keys?}" > "aws-${deployment_user_name?}-keys.sh"
  source ./aws-${deployment_user_name?}-keys.sh
  echo "(Re-)apply to current shell: source ./aws-${deployment_user_name?}-keys.sh"
else
  echo "${access_key_json?}"
fi
