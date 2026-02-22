# www.diyaccounting.co.uk

Gateway static site for [DIY Accounting](https://www.diyaccounting.co.uk) — the main marketing and information site.

## Architecture

- **AWS CDK** (Java) deploys an S3 + CloudFront static site with OAC
- **CloudFront Function** handles URL redirects (generated from `redirects.toml`)
- **DNS** is managed separately by the [root.diyaccounting.co.uk](https://github.com/antonycc/root.diyaccounting.co.uk) repository
- **Account**: gateway (`283165661847`) in the DIY Accounting AWS Organization

## Quick Start

```bash
npm install
node scripts/build-gateway-redirects.cjs
./mvnw clean verify
npm run cdk:synth
```

## Project Structure

```
.github/workflows/     GitHub Actions (test + deploy)
cdk-gateway/           CDK app configuration
infra/main/java/       CDK Java stacks (GatewayStack)
scripts/               Build and maintenance scripts
web/www.diyaccounting.co.uk/
  public/              Static site content (S3 document root)
  redirects.toml       URL redirect configuration
```

## Deployment

Deployments run via GitHub Actions:

- **test.yml** — Lint, format check, Maven build, CDK synth (push, PRs, daily)
- **deploy.yml** — CDK deploy to ci or prod (push to main, manual dispatch)

OIDC authentication with `gateway-github-actions-role` and `gateway-deployment-role`.

## Development Tools

| Command | Purpose |
|---------|---------|
| `npm run formatting` | Check Prettier + Spotless formatting |
| `npm run lint:workflows` | Validate GitHub Actions workflows |
| `npm run diagram:gateway` | Generate architecture diagram |
| `npm run update:java` | Update Maven dependencies |
| `npm run update:node` | Update npm dependencies |

## Related Repositories

| Repository | Purpose |
|-----------|---------|
| [root.diyaccounting.co.uk](https://github.com/antonycc/root.diyaccounting.co.uk) | Route53 DNS records |
| [submit.diyaccounting.co.uk](https://github.com/antonycc/submit.diyaccounting.co.uk) | Submit application |

## License

AGPL-3.0-only. Copyright (C) 2025-2026 DIY Accounting Ltd.
