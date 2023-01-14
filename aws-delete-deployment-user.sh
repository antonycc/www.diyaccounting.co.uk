#!/usr/bin/env bash
# Purpose: Delete a user for the deployment and local execution of lambdas
# Usage: ./scripts/aws-delete-deployment-user.sh
# Note: Requires privileges in the current environment to delete an IAM user
deployment_user_name='diyaccounting-co-uk-www-deployment'
pids=()
aws iam list-attached-user-policies \
  --user-name "${deployment_user_name?}" \
  --query 'AttachedPolicies[].PolicyArn' \
  --output json \
  | jq --raw-output '.[]' \
  | while read -r policy-arn ; do \
      aws iam detach-user-policy --user-name "${deployment_user_name?}" --policy-arn "${policy-arn?}" ; \
    done &
pids+=($!)
aws iam list-access-keys \
  --user-name "${deployment_user_name?}" \
  --query 'AccessKeyMetadata[].AccessKeyId' \
  --output json \
  | jq --raw-output '.[]' \
  | while read -r access-key-id ; do \
      aws iam delete-access-key --user-name "${deployment_user_name?}" --access-key-id "${access-key-id?}" ; \
    done &
pids+=($!)
for pid in ${pids[*]}; do
    wait "${pid?}"
done
aws iam delete-user --user-name "${deployment_user_name?}"
