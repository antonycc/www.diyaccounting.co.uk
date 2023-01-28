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
aws cloudfront create-invalidation --distribution-id "$(aws cloudfront list-distributions --query 'DistributionList.Items[].Id' --output text)" --paths "/*"

# Testing using cURL (the CDN may not have been purged at this point)
#curl --include --request GET "${WEBSITE_ENDPOINT?}/home.html" | head -30 ;
#curl --head "${WEBSITE_ENDPOINT?}"'/' --verbose  --write-out '%{http_code} : %{url} -> %{url_effective}\n\n'
curl --head "${WEBSITE_ENDPOINT?}"'/' --write-out '%{http_code} : %{url} -> %{url_effective}\n\n'
curl --head "${WEBSITE_ENDPOINT?}"'/home.html' --write-out '%{http_code} : %{url} -> %{url_effective}\n\n'
curl --head "${WEBSITE_ENDPOINT?}"'/content/page' --write-out '%{http_code} : %{url} -> %{url_effective}\n\n'
curl --head "${WEBSITE_ENDPOINT?}"'/content/product-for-period/Self-Employed/2022-04-05-(Apr22)' --write-out '%{http_code} : %{url} -> %{url_effective}\n\n'
curl --head "${WEBSITE_ENDPOINT?}"'/assets/2720341.png' --write-out '%{http_code} : %{url} -> %{url_effective}\n\n'
curl --head "${WEBSITE_ENDPOINT?}"'/zips/GB%20Accounts%20Basic%20Sole%20Trader%202022-04-05%20(Apr22)%20Excel%202007.zip' --write-out '%{http_code} : %{url} -> %{url_effective}\n\n'
#curl --include "${WEBSITE_ENDPOINT?}"'/zips/packages.txt' | head -15
#curl --include "${WEBSITE_ENDPOINT?}"'/content/page' | head -15
#curl --include "${WEBSITE_ENDPOINT?}"'/content/product-for-period/Basic-Sole-Trader/2022-04-05-(Apr22)' | head -15
echo "${WEBSITE_ENDPOINT?}/home.html" ;

# Show invalidation progress
aws cloudfront list-invalidations --distribution-id "$(aws cloudfront list-distributions --query 'DistributionList.Items[].Id' --output text)"

