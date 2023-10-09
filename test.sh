#!/usr/bin/env bash
# Purpose: Test the static site
# Usage: test.sh

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
