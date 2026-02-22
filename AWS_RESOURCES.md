# AWS Resources — Gateway Account (283165661847)

Catalogued from AWS CLI on 2026-02-21.

## Managed by This Repo (per environment)

Resources below exist for both `ci` and `prod` environments. Replace `{env}` with `ci` or `prod`.

| Resource             | Name / ID                                             | Purpose                                  |
| -------------------- | ----------------------------------------------------- | ---------------------------------------- |
| CloudFormation       | `{env}-gateway-GatewayStack`                          | S3 + CloudFront + OAC static site        |
| S3 bucket            | `{env}-gateway-gatewaystack-{env}gatewayoriginbucket-*` | Static site content origin             |
| CloudFront dist (ci) | `E6YTNLAL2VBNN` / `de9dto3k3vhcf.cloudfront.net`     | `ci-gateway.diyaccounting.co.uk`         |
| CloudFront dist (prod) | `E3U3O7ZH7B8234` / `dnloza7zl3wfi.cloudfront.net`  | `www.diyaccounting.co.uk`, `diyaccounting.co.uk` |
| CloudFront Function  | `{env}-gateway-redirects`                             | URL redirect engine (from redirects.toml) |
| CloudWatch log group | `distribution-{env}-gateway-logs`                     | CloudFront access logs                   |
| Lambda (CDK custom)  | `{env}-gateway-GatewayStack-CustomCDKBucketDeployment*` | CDK BucketDeployment handler           |
| Lambda (CDK custom)  | `{env}-gateway-GatewayStack-CustomS3AutoDeleteObjects*` | CDK auto-delete handler                |
| Lambda (CDK custom)  | `{env}-gateway-GatewayStack-AWS679f53fac002430cb0da5b7*` | CDK AwsCustomResource handler          |
| IAM roles (3 per env) | `{env}-gateway-GatewayStack-*`                       | CDK custom resource execution roles      |

## Account-Level Resources

| Resource          | ARN / Name                                                | Purpose                            |
| ----------------- | --------------------------------------------------------- | ---------------------------------- |
| CloudFormation    | `CDKToolkit`                                              | CDK bootstrap stack                |
| IAM role          | `gateway-github-actions-role`                             | OIDC auth for GitHub Actions       |
| IAM role          | `gateway-deployment-role`                                 | CDK deploy role                    |
| IAM OIDC provider | `token.actions.githubusercontent.com`                     | GitHub Actions OIDC                |
| ACM certificate   | `arn:aws:acm:us-east-1:283165661847:certificate/18008e08-0475-4ba0-8516-834fd5f447d9` | TLS for CloudFront (ci + prod) |
| S3 bucket         | `cdk-hnb659fds-assets-283165661847-us-east-1`             | CDK asset staging (us-east-1)      |
| S3 bucket         | `cdk-hnb659fds-assets-283165661847-eu-west-2`             | CDK asset staging (eu-west-2)      |
| ECR repository    | `cdk-hnb659fds-container-assets-283165661847-us-east-1`   | CDK container asset staging        |
| SSM parameter     | `/cdk-bootstrap/hnb659fds/version`                        | CDK bootstrap version              |
| IAM roles (10)    | `cdk-hnb659fds-*-283165661847-{us-east-1,eu-west-2}`     | CDK bootstrap roles (deploy, lookup, file-publishing, cfn-exec, image-publishing) |

## AWS Service-Linked Roles (auto-created, do not delete)

| Role                                | Service           |
| ----------------------------------- | ----------------- |
| `AWSServiceRoleForCloudFrontLogger` | CloudFront Logger |
| `AWSServiceRoleForOrganizations`    | Organizations     |
| `AWSServiceRoleForResourceExplorer` | Resource Explorer |
| `AWSServiceRoleForSSO`              | IAM Identity Center |
| `AWSServiceRoleForSupport`          | AWS Support       |
| `AWSServiceRoleForTrustedAdvisor`   | Trusted Advisor   |

## Intentional Non-CDK Resources

| Resource               | Purpose                                                   |
| ---------------------- | --------------------------------------------------------- |
| IAM role               | `OrganizationAccountAccessRole` — cross-account admin access |
| SSO reserved roles (2) | `AWSReservedSSO_AdministratorAccess_*`, `AWSReservedSSO_ReadOnlyAccess_*` |
