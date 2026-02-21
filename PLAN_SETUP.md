# PLAN: Gateway Repository Setup

## User Assertions (non-negotiable)

- This is `antonycc/www.diyaccounting.co.uk` — the gateway static site repo
- Gateway AWS account: 283165661847
- S3 + CloudFront static site for `www.diyaccounting.co.uk` and `diyaccounting.co.uk`
- test.yml should run behaviour tests against a local running version of the site started with `npm start`
- Behaviour tests only differ in config between local/CI/prod (env var `GATEWAY_BASE_URL`)
- All compliance reporting combined into `REPORT_ACCESSIBILITY_PENETRATION.md` like submit
- Copy LICENSE (AGPL-3.0) from root repo and apply SPDX copyright/licence headers matching submit

## Context (from submit PLAN_ACCOUNT_SEPARATION.md)

### Account Structure

| Account        | ID           | Repository                          | Purpose                |
|----------------|--------------|-------------------------------------|------------------------|
| Management     | 887764105431 | `antonycc/root.diyaccounting.co.uk` | Route53, holding page  |
| **gateway**    | 283165661847 | `antonycc/www.diyaccounting.co.uk`  | **This repo**          |
| spreadsheets   | 064390746177 | `antonycc/diy-accounting` (future)  | Spreadsheets site      |
| submit-ci      | 367191799875 | `antonycc/submit.diyaccounting.co.uk` | Submit CI            |
| submit-prod    | 972912397388 | `antonycc/submit.diyaccounting.co.uk` | Submit prod          |
| submit-backup  | 914216784828 | —                                   | Cross-account backup   |

### Repository Separation Status

- 2.1 COMPLETE: Root → `antonycc/root.diyaccounting.co.uk`
- **2.2 IN PROGRESS: Gateway → `antonycc/www.diyaccounting.co.uk`** ← this plan
- 2.3 Pending: Spreadsheets → `antonycc/diy-accounting`
- 2.4: Submit repo cleanup

### GitHub Setup Required

GitHub repository `antonycc/www.diyaccounting.co.uk` needs:

1. **Repository variables** (Settings > Variables):
   - `GATEWAY_ACTIONS_ROLE_ARN` — OIDC auth role for gateway account
   - `GATEWAY_DEPLOY_ROLE_ARN` — CDK deploy role for gateway account
   - `GATEWAY_CERTIFICATE_ARN` — ACM certificate ARN for CloudFront

2. **Environments** (Settings > Environments):
   - `ci` — with above variables scoped to CI
   - `prod` — with above variables scoped to prod

3. **Branch protection** on `main`:
   - Require PR reviews
   - Require status checks (test workflow)

### Quality Baseline (from submit)

- Java: Spotless + Palantir (100-column width)
- JS/YAML/JSON/TOML: Prettier
- Dependency management: npm-check-updates (`.ncurc.cjs` filters pre-release) + Maven
- Architecture diagrams: cfn-diagram
- Workflow validation: actionlint
- Node >=24.0.0
- AGPL-3.0 licence with SPDX headers on all source files

---

## Work Done (branch `gatewayascdk`)

### Cleanup — removed submit-specific leftovers

- [x] Deleted `scripts/build-sitemaps.cjs` — spreadsheets-specific, referenced non-existent paths
- [x] Deleted `.github/actions/get-names/action.yml` — submit-specific with DIY_SUBMIT_* variables
- [x] Fixed `scripts/update-java.sh` — wrong CDK output dir (`cdk-submit-root.out` → `cdk-submit-gateway.out`)
- [x] Fixed `GatewayStack.java` tags — referenced `submit.diyaccounting.co.uk` → `www.diyaccounting.co.uk`
- [x] Rewrote `.prettierignore` — removed submit-specific entries
- [x] Added `"type": "module"` to `package.json` for ES module support

### Brought over from root repo

- [x] `.ncurc.cjs` — filters alpha/beta/rc/dev/canary/experimental/pre from npm-check-updates
- [x] `.editorconfig` — UTF-8, LF, trim trailing whitespace, Java 140-col width

### Brought over from submit repo

- [x] Behaviour tests: `behaviour-tests/gateway.behaviour.test.js`
  - Adapted from submit (replaced `fs-extra` with `node:fs`, removed submit-specific dependencies)
  - Tests: landing page, about page, robots.txt, sitemap.xml, security.txt, redirects, meta tags, JSON-LD
- [x] Behaviour test helpers: `behaviour-tests/helpers/playwrightTestWithout.js`, `behaviour-helpers.js`
  - Minimal versions without submit-specific imports (pino, DynamoDB, ngrok)
- [x] Browser tests: `web/browser-tests/gateway-content.browser.test.js`
  - Tests: meta tags, navigation buttons, JSON-LD, footer links, company summary, about page, lang attr
- [x] Unit tests: `web/unit-tests/seo-validation.test.js`
  - Tests: sitemap.xml structure/URLs/duplicates, robots.txt directives, meta tags, JSON-LD
- [x] `playwright.config.js` — two projects: `gatewayBehaviour` and `browser-tests`
- [x] `vitest.config.js` — unit test configuration

### Compliance testing infrastructure

- [x] `.pa11yci.ci.json` and `.pa11yci.prod.json` — pa11y configs for gateway pages
- [x] `eslint.security.config.js` — ESLint security scanning config
- [x] `.retireignore.json` — retire.js ignore paths
- [x] `scripts/text-spacing-test.js` — WCAG 1.4.12 text spacing test
- [x] `scripts/generate-compliance-report.js` — generates `REPORT_ACCESSIBILITY_PENETRATION.md`

### Deployment workflow

- [x] `.github/workflows/deploy.yml` — merged deploy + test-gateway jobs
  - `params` job: resolves environment from branch/input, handles skipDeploy
  - `deploy-gateway` job: CDK deploy with OIDC auth and role chaining
  - `test-gateway` job: Playwright smoke tests in official container

### package.json scripts added

- [x] `test`, `test:unit`, `test:browser` — vitest and playwright test runners
- [x] `test:gatewayBehaviour`, `test:gatewayBehaviour-ci`, `test:gatewayBehaviour-prod`
- [x] `accessibility:*` — pa11y, axe, lighthouse, text-spacing for CI and prod
- [x] `penetration:*` — eslint security, npm audit, retire.js
- [x] `compliance:*` — combined accessibility + penetration
- [x] `seo:structured-data-ci`, `seo:structured-data-prod`
- [x] `linting`, `lint:workflows`
- [x] `diagram:gateway`

### Test results (all passing)

- [x] 13 unit tests passed (SEO validation)
- [x] 10 browser tests passed (gateway content)

---

## Remaining Work

### Licence and copyright

- [x] Copy `LICENSE` (AGPL-3.0) from root repo
- [x] Apply SPDX copyright headers (`SPDX-License-Identifier: AGPL-3.0-only` / `Copyright (C) 2025-2026 DIY Accounting Ltd`) to all source files matching submit's pattern
- [x] Apply SPDX headers to root repo (`../root.diyaccounting.co.uk`) — `.ncurc.cjs`, `scripts/clean-drawio.cjs`

### Local development and testing

- [x] Add `npm start` script — `npx serve web/www.diyaccounting.co.uk/public -l 3000`
- [x] Add `test:gatewayBehaviour-local` script — sets `GATEWAY_BASE_URL=http://localhost:3000`
- [x] Update `test.yml` with four jobs:
  - `build` — formatting, Maven verify, CDK synth
  - `unit-test` — vitest unit tests
  - `browser-test` — Playwright browser tests with artifact upload
  - `behaviour-test` — starts local server, waits for ready, runs behaviour tests in Playwright container
- [x] Redirect test auto-skips when running locally (CloudFront Functions not available)
- [x] Added `serve` and `wait-on` devDependencies

### GitHub repository setup

- [ ] Create GitHub repository `antonycc/www.diyaccounting.co.uk` (if not done)
- [ ] Configure repository variables: `GATEWAY_ACTIONS_ROLE_ARN`, `GATEWAY_DEPLOY_ROLE_ARN`, `GATEWAY_CERTIFICATE_ARN`
- [ ] Create `ci` and `prod` environments with scoped variables
- [ ] Set up branch protection on `main`
- [ ] Push `gatewayascdk` branch and open PR

### Compliance reporting

- [x] Updated `generate-compliance-report.js` to match submit's full report format (detailed sections per test type, violation tables, report files table)
- [ ] Verify `npm run compliance:ci-report-md` produces `REPORT_ACCESSIBILITY_PENETRATION.md` end-to-end

### CLAUDE.md updates

- [ ] Update CLAUDE.md to reflect new testing infrastructure and scripts
- [ ] Document behaviour test configuration (GATEWAY_BASE_URL env var)
- [ ] Document compliance report generation

---

## Verification Criteria

1. `npm test` — all unit tests pass
2. `npm run test:browser` — all browser tests pass
3. `npm start` — serves static site locally
4. `GATEWAY_BASE_URL=http://localhost:<port> npm run test:gatewayBehaviour` — behaviour tests pass against local site
5. `npm run formatting` — no formatting issues
6. `npm run cdk:synth` — CDK synthesis succeeds
7. `npm run compliance:ci-report-md` — generates compliance report
8. All source files have SPDX copyright headers
9. GitHub Actions workflows pass (test.yml, deploy.yml)
