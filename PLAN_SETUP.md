# PLAN: Gateway Repository Setup

## User Assertions (non-negotiable)

- This is `antonycc/www.diyaccounting.co.uk` — the gateway static site repo
- Gateway AWS account: 283165661847
- S3 + CloudFront static site for `www.diyaccounting.co.uk` and `diyaccounting.co.uk`
- test.yml should run behaviour tests against a local running version of the site started with `npm start`
- Behaviour tests only differ in config between local/CI/prod (env var `GATEWAY_BASE_URL`)
- All compliance reporting combined into `REPORT_ACCESSIBILITY_PENETRATION.md` like submit
- Copy LICENSE (AGPL-3.0) from root repo and apply SPDX copyright/licence headers matching submit
- Corporate landing page linking to subsites (submit, spreadsheets) — secure via static, low cost
- Repository is a bastion of good practice, minimal dependencies, template-ready
- De-duped, documented, and scripted enough to replicate: add account info + domain → live site in 5-25 minutes
- Working branch: `pristine`

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

### Quality Baseline (from submit)

- Java: Spotless + Palantir (100-column width)
- JS/YAML/JSON/TOML: Prettier
- Dependency management: npm-check-updates (`.ncurc.cjs` filters pre-release) + Maven
- Architecture diagrams: cfn-diagram
- Workflow validation: actionlint
- Node >=24.0.0
- AGPL-3.0 licence with SPDX headers on all source files

---

## Work Done (branch `gatewayascdk`, merged to `main` via PR #1)

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
- [x] Behaviour test helpers: `behaviour-tests/helpers/playwrightTestWithout.js`, `behaviour-helpers.js`
- [x] Browser tests: `web/browser-tests/gateway-content.browser.test.js`
- [x] Unit tests: `web/unit-tests/seo-validation.test.js`
- [x] `playwright.config.js`, `vitest.config.js`

### Compliance testing infrastructure

- [x] `.pa11yci.ci.json` and `.pa11yci.prod.json`
- [x] `eslint.security.config.js`, `.retireignore.json`
- [x] `scripts/text-spacing-test.js`, `scripts/generate-compliance-report.js`

### Deployment workflow

- [x] `.github/workflows/deploy.yml` — params + deploy-gateway + test-gateway jobs
- [x] `.github/workflows/test.yml` — build + unit-test + browser-test + behaviour-test jobs

### Licence and copyright

- [x] `LICENSE` (AGPL-3.0) copied from root repo
- [x] SPDX headers on all source files

### Local development and testing

- [x] `npm start` — serves static site locally
- [x] `test:gatewayBehaviour-local` script
- [x] Redirect test auto-skips when running locally

---

## Remaining Work (branch `pristine`)

### Phase 1: Fix copy-paste inconsistencies from submit repo

Nine files still reference `cdk-submit-gateway.out` — a leftover from when this code lived in the submit repo. Should be `cdk-gateway.out`.

| File | Line(s) | Current | Fix to |
|------|---------|---------|--------|
| `cdk-gateway/cdk.json` | 3 | `../cdk-submit-gateway.out` | `../cdk-gateway.out` |
| `package.json` | 63 | `cdk-submit-gateway.out` | `cdk-gateway.out` |
| `.github/workflows/deploy.yml` | 136, 146 | `cdk-submit-gateway.out` | `cdk-gateway.out` |
| `scripts/update-java.sh` | 13 | `cdk-submit-gateway.out` | `cdk-gateway.out` |
| `.gitignore` | 3 | `/cdk-submit-gateway.out/` | `/cdk-gateway.out/` |
| `.prettierignore` | 6 | `cdk-submit-gateway.out/` | `cdk-gateway.out/` |
| `.retireignore.json` | 11 | `cdk-submit-gateway.out/` | `cdk-gateway.out/` |
| `eslint.security.config.js` | 47 | `cdk-submit-gateway.out/` | `cdk-gateway.out/` |

Plus one stale comment:

| `pom.xml` | 277 | `<!-- Source directory matches submit repo layout -->` | Remove or update |

- [ ] Fix all 9 `cdk-submit-gateway.out` → `cdk-gateway.out` references
- [ ] Fix stale submit comment in `pom.xml`
- [ ] Verify `npm run cdk:synth` still works after rename
- [ ] Verify `npm run diagram:gateway` still works after rename

### Phase 2: Smoke test for local dev server

Add a lightweight unit test that starts the local server and verifies pages render. This provides a quick "does it work?" check without the full Playwright suite.

- [ ] Create `web/unit-tests/smoke.test.js` — vitest test that:
  - Starts `http-server` on a random port
  - Fetches `index.html`, asserts 200 and checks for key text (e.g. "DIY Accounting", navigation button text)
  - Fetches `about.html`, asserts 200 and checks for key text (e.g. "DIY Accounting Limited")
  - Fetches a non-existent page, asserts 404
  - Tears down server after tests
- [ ] Ensure it runs as part of `npm run test:unit`

### Phase 3: AWS_RESOURCES.md generation script

Generate `AWS_RESOURCES.md` from live AWS data, like we do for compliance reports and architecture diagrams. Add to `package.json` alongside `diagram:gateway`.

- [ ] Create `scripts/generate-aws-resources.js` that:
  - Calls AWS CLI (CloudFormation describe-stacks, CloudFront list-distributions, IAM list-roles, etc.)
  - Formats output as the current `AWS_RESOURCES.md` structure
  - Uses the `gateway` AWS SSO profile
  - Fails gracefully if not authenticated (prints instructions)
- [ ] Add `package.json` scripts:
  - `resources:gateway` — generates `AWS_RESOURCES.md`
- [ ] Add `AWS_RESOURCES.md` to `.gitignore` (it's generated, like the compliance report)
- [ ] Remove the current static `AWS_RESOURCES.md` from tracking

### Phase 4: Template tooling

#### 4a. `scripts/template-clean.sh`

Runs first when using this repo as a template. Replaces DIY Accounting-specific content with RFC 2606 placeholders (`site.example`).

- [ ] Create `scripts/template-clean.sh` that:
  - Replaces `diyaccounting.co.uk` → `site.example` in web content, CDK context, workflows
  - Replaces `DIY Accounting` → `Example Company` in HTML, about page, JSON-LD
  - Replaces `@antonycc` → `@owner` in package.json, tags
  - Replaces company-specific details (directors, address, company number, GA4 ID) with placeholders
  - Replaces redirect rules in `redirects.toml` with generic examples (e.g. `/old-page.html` → `/`)
  - Clears `security.txt` contact/expiry to placeholders
  - Outputs a summary of what was replaced

#### 4b. `scripts/template-init.sh`

Runs after `template-clean.sh`. Interactive script that takes real values and applies them.

- [ ] Create `scripts/template-init.sh` that prompts for and applies:
  - Domain name (e.g. `spreadsheets.example.com`) → replaces `site.example`
  - Company name → replaces `Example Company`
  - GitHub owner/scope → replaces `@owner`
  - AWS account ID → replaces placeholder account ID
  - Java package name (e.g. `com.example.spreadsheets`) → renames directories and updates all imports
  - CDK app prefix (e.g. `spreadsheets`) → replaces `gateway` in stack names, resource prefixes
  - Renames `cdk-gateway/` → `cdk-{prefix}/`
  - Renames `GatewayStack.java` → `{Prefix}Stack.java`, etc.
  - Updates `pom.xml` groupId/artifactId
  - Updates `package.json` name/description
  - Updates workflow variable names (`GATEWAY_*` → `{PREFIX}_*`)
  - Outputs a checklist of manual steps remaining (CDK bootstrap, OIDC setup, GitHub variables)

#### 4c. `TEMPLATE.md`

- [ ] Create `TEMPLATE.md` with:
  - Purpose: "This repository is a GitHub template for CDK static sites on AWS"
  - Prerequisites: AWS account (bootstrapped), ACM certificate, GitHub repo with OIDC
  - Step 1: Create repo from template (GitHub UI)
  - Step 2: Run `scripts/template-clean.sh` (strips DIY-specific content)
  - Step 3: Run `scripts/template-init.sh` (applies your values)
  - Step 4: Set GitHub repository variables and environments
  - Step 5: Push to main → deploy.yml creates the site
  - Step 6: Copy CloudFrontDomainName output to DNS
  - Estimated time: 5-25 minutes depending on CDK bootstrap and DNS propagation
  - Appendix: Bootstrap a new AWS account (CDK bootstrap, OIDC provider, IAM roles, ACM cert)

### Phase 5: CLAUDE.md and documentation updates

- [ ] Update CLAUDE.md to reflect:
  - Testing infrastructure (unit, browser, behaviour tests)
  - Behaviour test configuration (`GATEWAY_BASE_URL` env var)
  - Compliance report generation (`npm run compliance:ci-report-md`)
  - AWS resource generation (`npm run resources:gateway`)
  - Template usage (reference TEMPLATE.md)
  - Smoke test in unit test suite
- [ ] Update README.md:
  - Add Testing section (unit, browser, behaviour, compliance)
  - Add "Template Repository" note linking to TEMPLATE.md
  - Add `npm run resources:gateway` to Development Tools table

### Phase 6: GitHub repository setup verification

- [ ] Verify repository variables are configured: `GATEWAY_ACTIONS_ROLE_ARN`, `GATEWAY_DEPLOY_ROLE_ARN`, `GATEWAY_CERTIFICATE_ARN`
- [ ] Verify `ci` and `prod` environments exist with scoped variables
- [ ] Verify branch protection on `main`
- [ ] Enable "Template repository" in GitHub Settings
- [ ] Verify compliance report end-to-end: `npm run compliance:ci-report-md`

---

## Verification Criteria

1. `npm run cdk:synth` — CDK synthesis succeeds (output in `cdk-gateway.out/`, not `cdk-submit-gateway.out/`)
2. `npm test` — all unit tests pass (including new smoke test)
3. `npm run test:browser` — all browser tests pass
4. `npm start` — serves static site locally on port 3000
5. `GATEWAY_BASE_URL=http://localhost:3000 npm run test:gatewayBehaviour-local` — behaviour tests pass
6. `npm run formatting` — no formatting issues
7. `npm run diagram:gateway` — generates architecture diagram
8. `npm run resources:gateway` — generates AWS_RESOURCES.md (when authenticated)
9. `npm run compliance:ci-report-md` — generates compliance report
10. All source files have SPDX copyright headers
11. `scripts/template-clean.sh` runs without errors and produces valid placeholder site
12. `scripts/template-init.sh` runs without errors and produces valid customised site
13. GitHub Actions workflows pass (test.yml, deploy.yml)
14. No remaining references to `cdk-submit-gateway` anywhere in the repo
15. TEMPLATE.md documents the full template workflow
