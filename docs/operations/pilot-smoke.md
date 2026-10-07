# Controlled pilot smoke test

**Audience:** Operators and release owners. **Implementation status:** Implemented, opt-in live integration.

**Prerequisites:** A deployed stack, organization-managed real model credentials, configured sandbox/egress and dedicated disposable Jira/project repository resources. This test creates external drafts and consumes model tokens; it is separate from ordinary documentation and code checks.

## Protected workflow

Run **Actions → Pilot smoke → Run workflow** on the platform's default branch. The workflow uses the protected `pilot` environment and is manual only. Configure required reviewers in that GitHub environment before use; the workflow's environment declaration alone does not create a review policy. The optional `release` input identifies the deployed commit, defaulting to the workflow commit.

The repaired workflow assigns credential-file paths in a step through `GITHUB_ENV`; `runner.temp` is not valid in job-level environment expressions.

## Required configuration

| Setting | Purpose |
| --- | --- |
| `PILOT_SMOKE_RESOURCES_DISPOSABLE=true` | Explicit declaration that targets are disposable |
| `PILOT_BASE_URL`, `PILOT_SMOKE_ORIGIN` | API and allowed browser origin; non-local API requires HTTPS |
| `PILOT_SMOKE_ORGANIZATION_ID`, `PILOT_SMOKE_AGENT_ID` | Dedicated organization and assigned QA agent |
| `PILOT_SMOKE_STORY_KEY`, `PILOT_SMOKE_TARGET_URL` | Story and browser test target |
| `PILOT_SMOKE_JIRA_PROJECT`, `PILOT_SMOKE_REPOSITORY` | Disposable project and optional owner/name repository |
| `PILOT_SMOKE_EMPLOYEE_CREDENTIALS`, `PILOT_SMOKE_ADMIN_CREDENTIALS` | Environment secrets containing email/password JSON for separate test accounts |

The workflow sets `PILOT_SMOKE=true`, `PILOT_ENVIRONMENT=pilot` and `PILOT_RELEASE_COMMIT`. Local invocation additionally needs credential JSON file paths in `PILOT_SMOKE_EMPLOYEE_CREDENTIALS_PATH` and `PILOT_SMOKE_ADMIN_CREDENTIALS_PATH`; keep them outside Git. `PILOT_SMOKE_TIMEOUT_MS` defaults to 30 minutes.

## What is proved

`npm run pilot:smoke` drives a QA task through employee API sessions and a separate approving administrator. It rejects pull-request-related events, refuses connections reaching beyond the disposable targets and approves only scoped writes. It checks governed action evidence through `GET /api/execution/v1/runs/:id/actions`, including checkout, dependencies, tests, browser evidence and approved drafts. Safe summaries do not expose action parameters or credentials.

The report records `sandbox-live`, `private-scm-live`, `real-model-live`, `object-store-live` and `vault-live` as passed, failed or not-run from observed evidence. Declared configuration does not count as a passed proof.

## Reports and release gate

Download the `pilot-smoke-report` workflow artifact, or use `.readiness/operational/pilot-smoke.json`. Combine it with both host validation reports for the deployed commit. Readiness accepts live proof evidence only for the exact assessed commit and within seven days. Run `npm run readiness`; both `codeProofsPassed` and `operationalProofsPassed` must pass for `readyForControlledPilot`. No live smoke test was executed as part of this documentation refresh.

## Source provenance

- [Smoke implementation](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/operations/src/smoke.ts)
- [Workflow](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/.github/workflows/pilot-smoke.yml)
- [Smoke entry point](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/test/pilot-smoke.smoke.ts)
- [Readiness assessment](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/readiness/src/assess.ts)

## Related documentation

[Pilot operations](pilot-operations.md) · [Operator runbook](pilot-runbook.md) · [Readiness](../qa/pilot-readiness.md)
