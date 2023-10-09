#!/usr/bin/env bash
# Purpose: Build the static site to s3
# Usage: deploy.sh [--clean]
# Examples:
# $ source ./setenv-stage.sh ;
# $ ./deploy.sh
# $ ./deploy.sh --clean
clean="${1:-false}" ;

# Clean-up of deployed objects
if [[ "$clean" = "--clean" ]]; then
  aws s3 rm --recursive "s3://${WWW_DOMAIN_NAME?}/"
fi

# Deploy to s3
# To deploy just the BST packages add: --exclude '*.zip' --include '*Basic*.zip'
aws s3 sync './mirror' "s3://${WWW_DOMAIN_NAME?}/" --exclude '*content*' --delete --acl public-read ;
aws s3 sync './mirror' "s3://${WWW_DOMAIN_NAME?}/" --exclude '*' --include '*content*'  --content-type 'application/javascript' --delete --acl public-read ;
aws s3 ls --summarize --human-readable "s3://${WWW_DOMAIN_NAME?}/" ;

# Invalidate cached files on the CDN
aws cloudfront create-invalidation --distribution-id "$(aws cloudfront list-distributions --query 'DistributionList.Items[0].Id' --output text)" --paths "/*"
aws cloudfront create-invalidation --distribution-id "$(aws cloudfront list-distributions --query 'DistributionList.Items[1].Id' --output text)" --paths "/*"

# Show invalidation progress
aws cloudfront list-invalidations --distribution-id "$(aws cloudfront list-distributions --query 'DistributionList.Items[0].Id' --output text)"
aws cloudfront list-invalidations --distribution-id "$(aws cloudfront list-distributions --query 'DistributionList.Items[1].Id' --output text)"

