Present
=======

The browser based application for https://diyaccounting.co.uk/

TODO
====

Open Source project
-------------------
```
Static site launch:
[x] Replace .do in website content with .html amd remove FriendlyUrlController::@RequestMapping(value = "/*.do")
[x] Remove the hash generation from the download url
[x] Crawl: Page, Page with articles, sitemap, 
[x] Crawl: All [articles, features, products]
[x] Crawl: All features&products
[x] Crawl: All [content products&periods,  downloads products&periods]
[x] Fix articles page (possibly by adding a specific resource of page-with-articles)
[x] FIX: Not found http://localhost:9080/content/products/Basic%20Sole%20Trader
[x] Create single archive of static API responses + catalogue + content + src/main/webapp 
[x] FIX: http://localhost:9080/articles.html (page is blank)
[x] FIX: Server error selecting period on http://localhost:9080/get.html
[x] FIX: No accounting periods for: Basic Sole Trader download from roduct page
[x] FIX: Not found for: Basic Sole Trader download from product page with year
[x] Provision static site in s3 buckets for stage and live
[x] Deploy www.diyaccounting.co.uk as fully functional static site
[x] FIX: CRM images such as: http://www.stage.diyaccounting.co.uk.s3-website.eu-west-2.amazonaws.com/product.html?product=CompanyAccountsProduct
[x] Deploy www.diyaccounting.co.uk as fully functional static site
[x] Change run with docker to use the the published images
[x] Replace gb-ct references with either test resources in gb-web-local or the published image (when running docker)
[x] Consolidate product and download urls
[x] Generate mirrors using published diyaccounting-web Docker images
[x] Deploy CDN using terraform and assign *.diy certificate
[x] Add S3 bucket for backend and reference wiuth Terragrunt
[x] Add terraform module to apply update route 53 config with live. and stage. entries
[x] Move to GitHub private repository and rename project to www.diy....
[x] Implement GitHub actions to build the mirror
[ ] Secure Origins
[ ] Fix privilages and deploy using the specific deployment user 
[ ] Use GitHub actions to run a terraform deployment
[ ] Use GitHub actions to run a manual live content update
[ ] Use GitHub actions to run a manual live deployment and content update
[ ] (MDCMS repository) Update content for open source
Stabilisation and onboarding:
[ ] Use GitHub actions to run a terraform destroy (in a separate workflow at the end of the day)
[ ] Review me and ensure all examples work and update output
[ ] Use GitHub actions to run a link checker.
[ ] Enable CloudWatch
[ ] Ship all logs to cloudwatch
[ ] Set availability alarms
[ ] Create usage reports
[ ] Repopsitory flow diagram
[ ] Architecture diagram
[ ] Contributor guidelines
```

Development environment set-up
==============================

Decrypt credentials (including settings.xml)
--------------------------------------------
Encryption of the deployment user's credentials
```bash
$ ./open-ssl-pk-enc.sh list-recipients
[recipients/] antony@mbp.new (PEM is available locally in /Users/antony/.ssh)   <--- At least one available recipient is required
$ ./decrypt.sh
$ # TODO: Add permissions for the deployment user then reinstate: source ./aws-diyaccounting-co-uk-www-deployment-keys.sh
$ source ./aws-887764105431-keys.sh
{
    "UserId": "AIDA45MW5HDL4DA4MENAW",
    "Account": "887764105431",
    "Arn": "arn:aws:iam::887764105431:user/diyaccounting-co-uk-www-deployment"
}
$
```

Deploy infrastructure for stage
-------------------------------
Deploy the site's s3 buckets for stage:
```bash
$ # TODO: Add permissions for the deployment user then reinstate: source ./aws-diyaccounting-co-uk-www-deployment-keys.sh
$ source ./aws-887764105431-keys.sh
$ cd environments/stage/www-diyaccounting-co-uk
$ terragrunt init
$ terragrunt plan
$ terragrunt apply -auto-approve
```


Build static site for staging
-----------------------------
Either source script `./setenv-stage.sh` and run script `./build.sh` or the following commands:
```bash
$ source ./setenv-stage.sh
$ mkdir -p './mirror'
$ docker compose --file ./docker-compose-mount-content.yml build --no-cache --pull ;
$ docker compose --file ./docker-compose-mount-content.yml up --force-recreate --detach --wait ;
$ docker compose build --no-cache --pull ;
$ docker compose up --force-recreate --detach --wait ;
$ ./create-mirror-from-cluster.sh
$
```

Deploy static site for staging
==============================
```bash
$ # TODO: Add permissions for the deployment user then reinstate: source ./aws-diyaccounting-co-uk-www-deployment-keys.sh
$ source ./aws-887764105431-keys.sh
$ source ./setenv-stage.sh
$ echo "${WEBSITE_ENDPOINT?}"
http://www.stage.diyaccounting.co.uk.s3-website.eu-west-2.amazonaws.com
$ aws s3 sync './mirror' "s3://${WWW_DOMAIN_NAME?}/" --exclude '*content*' --delete --acl public-read ;
$ aws s3 sync './mirror' "s3://${WWW_DOMAIN_NAME?}/" --exclude '*' --include '*content*'  --content-type 'application/javascript' --delete --acl public-read ;
$ echo "s3://${WWW_DOMAIN_NAME?}/ was updated by:" > updated-by.txt
$ aws sts get-caller-identity >> updated-by.txt
$ echo "on $(date)" >> updated-by.txt
$ aws s3 cp './updated-by.txt' "s3://${WWW_DOMAIN_NAME?}/" --content-type 'text/plain' --acl public-read ;
$ aws s3 ls --summarize --human-readable "s3://${WWW_DOMAIN_NAME?}"
...
2023-01-01 02:31:54    4.1 KiB static-404.html
2023-01-01 02:31:54    4.1 KiB static-500.html
2023-01-01 02:31:54    4.5 KiB support.html
2023-01-01 02:31:54    4.9 KiB whatsnew.html

Total Objects: 31
Total Size: 163.9 KiB
$ curl --include --request GET "${WEBSITE_ENDPOINT?}/home.html" | head -30
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
Dload  Upload   Total   Spent    Left  Speed
100  9627  100  9627    0     0   332k      0 --:--:-- --:--:-- --:--:--  447k
HTTP/1.1 200
Content-Type: application/xml; charset=utf-8
Content-Length: 9627
Server: Werkzeug/2.1.2 Python/3.10.8
Date: Sun, 01 Jan 2023 01:36:51 GMT
x-amz-version-id: null
content-md5: 3rryV2DN7T+21/kWdQ6/Yg==
ETag: "debaf25760cded3fb6d7f916750ebf62"
last-modified: Sun, 01 Jan 2023 01:31:54 GMT
x-amzn-requestid: F9l1CYF01KyZ0jmTOanoDWuUb5z9e0U3N8ImNCoRKgjIozK4gqzC
Connection: close
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: HEAD,GET,PUT,POST,DELETE,OPTIONS,PATCH
Access-Control-Allow-Headers: authorization,cache-control,content-length,content-md5,content-type,etag,location,x-amz-acl,x-amz-content-sha256,x-amz-date,x-amz-request-id,x-amz-security-token,x-amz-tagging,x-amz-target,x-amz-user-agent,x-amz-version-id,x-amzn-requestid,amz-sdk-invocation-id,amz-sdk-request
Access-Control-Expose-Headers: etag,x-amz-version-id
x-amz-request-id: F9206C16520D3190
x-amz-id-2: MzRISOwyjmnupF9206C16520D31907/JypPGXLh0OVFGcJaaO3KW/hRAqKOpIEEp
accept-ranges: bytes
content-language: en-US
date: Sun, 01 Jan 2023 01:36:51 GMT
server: hypercorn-h11

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" itemscope="" itemtype="http://schema.org/Organization">
<head>
   <title>DIY Accounting Software, Small Business, Payslip Software, Tax Return, Limited Company UK</title>

   <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

$ curl --include https://www.stage.diyaccounting.co.uk/updated-by.txt
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 230
Connection: keep-alive
Date: Sun, 15 Jan 2023 17:01:52 GMT
Last-Modified: Sun, 15 Jan 2023 17:00:46 GMT
ETag: "af8ecc4110b0aecdb92c8ec1161501fc"
Accept-Ranges: bytes
Server: AmazonS3
X-Cache: Miss from cloudfront
Via: 1.1 6750d77433312fa1bf305e9ae7af80ae.cloudfront.net (CloudFront)
X-Amz-Cf-Pop: AMS1-P1
X-Amz-Cf-Id: 4n_1eDFf1MKFz-ys-XlngXFPmow-HfVUMOxy1z1ZqhJ6_SE1CerRPg==

s3://www.stage.diyaccounting.co.uk/
updated by:
{
    "UserId": "AIDAJPGEBR6GRO3SLB6H4",
    "Account": "887764105431",
    "Arn": "arn:aws:iam::887764105431:user/builder@aws.diyaccounting.co.uk"
}
on Sun Jan 15 18:00:36 CET 2023
$
```

Deploy infrastructure for live
-------------------------------
Deploy the site's s3 buckets for live:
```bash
$ # TODO: Add permissions for the deployment user then reinstate: source ./aws-diyaccounting-co-uk-www-deployment-keys.sh
$ source ./aws-887764105431-keys.sh
$ cd environments/live/www-diyaccounting-co-uk
$ terragrunt init
$ terragrunt plan
$ terragrunt apply -auto-approve
```

Build static site for live
--------------------------
Either source script `./setenv-live.sh` and run script `./build.sh` or the following commands:
```bash
$ source ./setenv-live.sh
$ mkdir -p './mirror'
$ docker compose --file ./docker-compose-mount-content.yml build --no-cache --pull ;
$ docker compose --file ./docker-compose-mount-content.yml up --force-recreate --detach --wait ;
$ docker compose build --no-cache --pull ;
$ docker compose up --force-recreate --detach --wait ;
$ ./create-mirror-from-cluster.sh
$
```

Deploy to AWS live site
-----------------------
Deploy the site to: [http://www.live.diyaccounting.co.uk.s3-website.eu-west-2.amazonaws.com] either by sourcing scripts 
`./aws-887764105431-keys.sh` and `./setenv-live.sh` then running script `./deploy.sh` or by entering the following commands:
```bash
$ # TODO: Add permissions for the deployment user then reinstate: source ./aws-diyaccounting-co-uk-www-deployment-keys.sh
$ source ./aws-887764105431-keys.sh
$ source ./setenv-live.sh
$ echo "${WEBSITE_ENDPOINT?}"
http://www.live.diyaccounting.co.uk.s3-website.eu-west-2.amazonaws.com
$ aws s3 sync './mirror' "s3://${WWW_DOMAIN_NAME?}/" --exclude '*content*' --delete --acl public-read ;
$ aws s3 sync './mirror' "s3://${WWW_DOMAIN_NAME?}/" --exclude '*' --include '*content*'  --content-type 'application/javascript' --delete --acl public-read ;
$ cd ../platforms
$ . ./aws-541134664601.sh
$ # Assuming: aws s3 mb s3://www.diyaccounting.co.uk-polycode
$ aws s3 sync './mirror' "s3://www.diyaccounting.co.uk-polycode/" --exclude '*content*' --delete --acl public-read ;
$ aws s3 sync './mirror' "s3://www.diyaccounting.co.uk-polycode/" --exclude '*' --include '*content*'  --content-type 'application/javascript' --delete --acl public-read ;

$ curl --include --request GET "${WEBSITE_ENDPOINT?}/home.html" | head -30
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  9627  100  9627    0     0   332k      0 --:--:-- --:--:-- --:--:--  447k
HTTP/1.1 200 
Content-Type: application/xml; charset=utf-8
Content-Length: 9627
Server: Werkzeug/2.1.2 Python/3.10.8
Date: Sun, 01 Jan 2023 01:36:51 GMT
x-amz-version-id: null
content-md5: 3rryV2DN7T+21/kWdQ6/Yg==
ETag: "debaf25760cded3fb6d7f916750ebf62"
last-modified: Sun, 01 Jan 2023 01:31:54 GMT
x-amzn-requestid: F9l1CYF01KyZ0jmTOanoDWuUb5z9e0U3N8ImNCoRKgjIozK4gqzC
Connection: close
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: HEAD,GET,PUT,POST,DELETE,OPTIONS,PATCH
Access-Control-Allow-Headers: authorization,cache-control,content-length,content-md5,content-type,etag,location,x-amz-acl,x-amz-content-sha256,x-amz-date,x-amz-request-id,x-amz-security-token,x-amz-tagging,x-amz-target,x-amz-user-agent,x-amz-version-id,x-amzn-requestid,amz-sdk-invocation-id,amz-sdk-request
Access-Control-Expose-Headers: etag,x-amz-version-id
x-amz-request-id: F9206C16520D3190
x-amz-id-2: MzRISOwyjmnupF9206C16520D31907/JypPGXLh0OVFGcJaaO3KW/hRAqKOpIEEp
accept-ranges: bytes
content-language: en-US
date: Sun, 01 Jan 2023 01:36:51 GMT
server: hypercorn-h11

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" itemscope="" itemtype="http://schema.org/Organization">
<head>
   <title>DIY Accounting Software, Small Business, Payslip Software, Tax Return, Limited Company UK</title>

   <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
$
```
To push the latest content immediately to the live site (www.diyaccounting.co.uk) the CloudFront distribution must be invalidated using pattern `/*`.

Create deployment user
----------------------
Read the aws-887764105431-keys.sh then run aws-create-deployment-user.sh to create the deployment user.
Example:
```bash
$ source ./aws-887764105431-keys.sh
$ aws sts get-caller-identity
{
    "UserId": "AIDAJPGEBR6GRO3SLB6H4",
    "Account": "887764105431",
    "Arn": "arn:aws:iam::887764105431:user/builder@aws.diyaccounting.co.uk"
}
$ ./aws-create-deployment-user.sh --script
{
    "User": {
        "Path": "/",
        "UserName": "diyaccounting-co-uk-www-deployment",
        "UserId": "AIDA45MW5HDL4DA4MENAW",
        "Arn": "arn:aws:iam::887764105431:user/diyaccounting-co-uk-www-deployment",
        "CreateDate": "2022-12-31T20:47:52+00:00"
    }
}

# TODO: Add permissions for the deployment user then reinstate: source ./aws-diyaccounting-co-uk-www-deployment-keys.sh
(Re-)apply to current shell: source ./aws-887764105431-keys.sh

~/projects/present % aws iam list-groups-for-user --user-name "builder@aws.diyaccounting.co.uk"
{
    "Groups": [
        {
            "Path": "/",
            "GroupName": "builders",
            "GroupId": "AGPAJAFHGX3E3MWMIYCAW",
            "Arn": "arn:aws:iam::887764105431:group/builders",
            "CreateDate": "2015-12-28T11:58:08+00:00"
        }
    ]
}
$ ls -l aws-diyaccounting-co-uk-www-deployment-keys.sh
-rw-r--r--  1 antony  staff  120 Dec 31 21:47 aws-diyaccounting-co-uk-www-deployment-keys.sh
$ source ./aws-diyaccounting-co-uk-www-deployment-keys.sh
$ aws sts get-caller-identity
{
    "UserId": "AIDA45MW5HDL4DA4MENAW",
    "Account": "887764105431",
    "Arn": "arn:aws:iam::887764105431:user/diyaccounting-co-uk-www-deployment"
}
$
```

Encrypt generated credentials
-----------------------------
Encryption of the deployment user's credentials
```bash
$ ./open-ssl-pk-enc.sh list-recipients
[recipients/] antony@mbp.new (PEM is available locally in /Users/antony/.ssh)   <--- At least one available recipient is required
$ ./encrypt.sh
$
```

Add certificate to recipients list
----------------------------------
Add and generate (optional) a certificate for the recipients list:
```bash
$ ./open-ssl-pk-enc.sh list-recipients | grep 'available' || echo "At least one locally available recipient is required."
At least one locally available recipient is required.
~/projects/present % ./open-ssl-pk-enc.sh list-available-keypairs
[/Users/antony/.ssh/] /Users/antony/.ssh/antony@mbp.new.pem?} (.pem format, installed to recipients)
[/Users/antony/.ssh/] /Users/antony/.ssh/my-new-keypair.pem (.pem format)
[/Users/antony/.ssh/] /Users/antony/.ssh/id_old_rsa (RSA format)
$ ./open-ssl-pk-enc.sh  
Usage:
  ./open-ssl-pk-enc.sh generate-keypair <keypair name>
  ./open-ssl-pk-enc.sh list-available-keypairs
  ./open-ssl-pk-enc.sh list-recipients
  ./open-ssl-pk-enc.sh add-recipient <.pem filename>
  ./open-ssl-pk-enc.sh remove-recipient <.pem filename>
  ./open-ssl-pk-enc.sh encrypt
  ./open-ssl-pk-enc.sh decrypt
  ./open-ssl-pk-enc.sh decrypt-to-env
$ ./open-ssl-pk-enc.sh generate-keypair my-new-keypair
Generating RSA private key, 2048 bit long modulus
..........................................................................+++++
..............................................+++++
e is 65537 (0x10001)
Enter pass phrase for my-new-keypair.pem:
Verifying - Enter pass phrase for my-new-keypair.pem:
-rw-------  1 antony  staff  1751 Jan  1 01:21 /Users/antony/.ssh/my-new-keypair.pem
~/projects/present % ./open-ssl-pk-enc.sh list-available-keypairs
[/Users/antony/.ssh/] /Users/antony/.ssh/antony@mbp.new.pem?} (.pem format, installed to recipients)
[/Users/antony/.ssh/] /Users/antony/.ssh/my-new-keypair.pem (.pem format)
[/Users/antony/.ssh/] /Users/antony/.ssh/id_old_rsa (RSA format)
$ ./open-ssl-pk-enc.sh add-recipient /Users/antony/.ssh/my-new-keypair.pem
Found .pem "/Users/antony/.ssh/my-new-keypair.pem" extracting the public key and adding to "recipients"
Enter pass phrase for /Users/antony/.ssh/my-new-keypair.pem:
writing RSA key
[recipients/] antony@mbp.new (PEM is available locally in /Users/antony/.ssh)
[recipients/] my-new-keypair (PEM is available locally in /Users/antony/.ssh)
$ ./open-ssl-pk-enc.sh list-recipients                                    
[recipients/] antony@mbp.new (PEM is available locally in /Users/antony/.ssh)
[recipients/] my-new-keypair (PEM is available locally in /Users/antony/.ssh)
$
```

Copy static website between S3 buckets
======================================
```bash
$ # TODO: Add permissions for the deployment user then reinstate: source ./aws-diyaccounting-co-uk-www-deployment-keys.sh
$ source ./aws-887764105431-keys.sh
$ source ./setenv-live.sh
$ echo "${WEBSITE_ENDPOINT?}"
http://www.live.diyaccounting.co.uk.s3-website.eu-west-2.amazonaws.com
$ aws s3 ls --summarize --human-readable "s3://${WWW_DOMAIN_NAME?}"
...
2023-01-01 02:31:54    4.1 KiB static-404.html
2023-01-01 02:31:54    4.1 KiB static-500.html
2023-01-01 02:31:54    4.5 KiB support.html
2023-01-01 02:31:54    4.9 KiB whatsnew.html

Total Objects: 31
Total Size: 163.9 KiB
$ # TODO: Remove this when we don't need the polycode hosted domain
$ mkdir -p ./target/www.live.diyaccounting.co.uk
$ aws s3 sync s3://www.live.diyaccounting.co.uk ./target/www.live.diyaccounting.co.uk --delete
$ du -h ./target/www.live.diyaccounting.co.uk
597M    ./target/www.live.diyaccounting.co.uk/zips
638M    ./target/www.live.diyaccounting.co.uk

```

Repository SSH access and validation
====================================

Generate an SSH key using ssh-keygen, add it to BitBucket and the private key to SSH config
```bash
$ cat ~/.ssh/config
host polycode-bitbucket.org
HostName bitbucket.org
IdentityFile ~/.ssh/polycode-mbp-2019-03-02
IdentitiesOnly yes
User git
$
```

Switch workspace to use SSH URL:
```bash
$ git remote set-url origin git@polycode-bitbucket.org:diyaccounting/present.git
$ git remote set-url - -push origin git@polycode-bitbucket.org:diyaccounting/present.git
```

Validate BitBucket access:
```bash
$ ssh -T git@polycode-bitbucket.org
```

Debug git access:
```bash
$ GIT_SSH_COMMAND="ssh -v" git ls-remote | grep 'debug'
```
