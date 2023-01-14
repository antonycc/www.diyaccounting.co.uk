# Purpose: Create a static version of the site.
# This is in a location mounted by a docker container which is then used to create the static site image.
# Usage: ./create-mirror-from-cluster.sh
# Examples:
# (With 'aa-fake-expects-404')
# $ ./create-mirror-from-cluster.sh
# $ head -3 ./mirror.log
# http://localhost:8080/aa-fake-expects-404:
# 2022-12-25 00:48:43 ERROR 404: (no description).
# 2022-12-25 00:48:43 URL:http://localhost:8080/content/articles/AccountingAndBasisPeriodsSelfEmployedBusinessArticle [55276] -> "./mirror/content/articles/AccountingAndBasisPeriodsSelfEmployedBusinessArticle" [1]

urls=('content/page-with-articles' 'sitemap.xml')
protocol='http'
site='localhost:8080'
contentIndex='http://localhost:8090/content/index.txt'
catalogueIndex='http://localhost:8100/zips/catalogue.csv'
outputDir='./mirror'
logFile='./mirror.log'

rm -rf "${outputDir}/content"
rm -rf "${logFile}"

# Iterate over content.
url='content/page'
requestUrl="${protocol?}://${site?}/${url?}"
mkdir -p $(dirname "${outputDir?}/${url?}")
wget \
  --no-cache \
  --no-check-certificate \
  --ignore-length \
  --output-document="${outputDir?}/${url?}" \
  --header='Accept:application/json' \
  "${requestUrl?}"
contentItems=$(curl --silent "${contentIndex?}")
productContentItems=$(echo "${contentItems?}" | grep 'Product\.md')
while read contentItem; do
  if [[ ${contentItem?} == *Article.md ]]; then
    urls+=( "content/articles/${contentItem/\.md/}" )
  elif [[ ${contentItem?} == *Feature.md ]]; then
    urls+=( "content/features/${contentItem/\.md/}" )
    while read productContentItem; do
      # Only add feature product pairings that are in the product's featureNames list.
      cat mirror/content/page \
        | jq --raw-output '.products | .[] | select(.name=="'"${productContentItem/\.md/}"'") | .featureNames | .[]' \
        | grep -i "${contentItem/\.md/}" \
        && urls+=( "content/feature-for-product/${contentItem/\.md/}/${productContentItem/\.md/}" )
    done <<< "${productContentItems}"
  elif [[ ${contentItem?} == *Product.md ]]; then
    urls+=( "content/products/${contentItem/\.md/}" )
    urls+=( "content/products/${contentItem/Product\.md/}" )
  fi
done <<< "${contentItems?}"

# Iterate over products and periods extending the urls array.
catalogueItems=$(curl --silent "${catalogueIndex?}" | tail -n +2 | grep -i -v 'Employee Expenses\|Invoice Generator\|SE Extra')
while read catalogueLine; do
  package="${catalogueLine/,*/}"
  packageLongName="${package/20*/}" # TODO: This 20* is to match the start of a 2022-04-05 (Apr22) date format, improve.
  productCatalogueName=$(echo "${packageLongName?}" | sed s/'GB Accounts'//g | sed s/'Accounts'//g | sed s/'Product'//g| xargs | sed s/' '/'-'/g)
  periodCatalogueName=$(echo "${package/$packageLongName/}"| xargs | sed s/' '/'-'/g)
  productName=$(echo "${productCatalogueName?}" | sed s/'-'//g)
  urls+=( "content/products/${productCatalogueName?}" )
  urls+=( "content/product-for-period/${productCatalogueName?}/${periodCatalogueName?}" )
  #urls+=( "content/product-for-period/${productName}/${periodCatalogueName}" )
  # From get: http://localhost:8080/gb-web/content/product-for-period/Basic-Sole-Trader/2022-04-05-(Apr22)
  # from prd: http://localhost:8080/gb-web/content/product-for-period/Basic-Sole-Trader/2022-04-05-(Apr22)
done <<< "${catalogueItems?}"

# Dedupe urls.
sorted_unique_urls=($(echo "${urls[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
echo "urls:"
printf '%s\n' "${sorted_unique_urls[@]}"

# Iterate over the urls array to create a static version of the site.
mkdir -p "${outputDir?}/content"
for url in ${sorted_unique_urls[@]?}; do
  requestUrl="${protocol?}://${site?}/${url?}"
  mkdir -p $(dirname "${outputDir?}/${url?}") \
    && wget \
      --no-cache \
      --no-check-certificate \
      --ignore-length \
      --force-directories \
      --output-document="${outputDir?}/${url?}" \
      --no-verbose \
      --header='Accept:application/json' \
      "${requestUrl?}" \
      2>&1 \
      | tee -a "${logFile?}" \
    && cat "${outputDir?}/${url?}" \
      | sed -e 's/http:\/\/localhost:8080\/assets\//\/assets\//g' \
      | sed -e 's/http:\/\/localhost:8080\/zips\//\/zips\//g' \
      > "${outputDir?}/${url?}.tmp" \
    && mv "${outputDir?}/${url?}.tmp" "${outputDir?}/${url?}"
  # TODO Use cURL to make an HTTP request to the site and save the response to a file.
  # curl \
  #   --silent \
  #   --insecure \
  #   --location \
  #   --output "${outputDir?}/${url?}" \
  #   --header 'Accept:application/json' \
  #   "${requestUrl?}" \
  #   2>&1 | tee -a "${logFile?}"
done
find "${outputDir?}" -type f -exec ls -alh "{}" \;

# Exit with a non-zero exit code if the logFile is not error free.
grep 'ERROR' "${logFile?}" \
  && echo 'ERRORS found in mirror HTTP request log:' \
  && grep --before-context=1 'ERROR' "${logFile?}" \
  && exit 1

# Create a docker image from the static content.
# Run with: docker run -p 9080:80 -d --name diy-accounting-web-stage diy-accounting-web-stage:latest
# Browse: http://localhost:9080/
currentDir=$(pwd)
cd "${outputDir?}"
rm -rf './workspace/META-INF' './workspace/WEB-INF' './workspace/view' './workspace/assets' './workspace/org'
mv ./workspace/* .
rm -r './workspace'
cd "${currentDir?}"
find "${outputDir?}" -type f -exec ls -alh "{}" \;
