# Testing, governance evaluations and quality gates

**Audience:** QA engineers, developers, operators. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

The platform separates unit/integration safety checks, scripted governance evaluations, real sandbox operational checks and funded live model-quality runs. One kind of proof does not replace the others.

| Gate | Command / source | Proves | Environment limits |
| --- | --- | --- | --- |
| Web UI | `npm run test:web` | Angular admin/employee/auth behavior | Not a live browser SSO tenant |
| API | `npm run test:api` | PostgreSQL migrations, RLS, identity, catalog, approvals, credentials, evidence, spending | Disposable PostgreSQL or TEST_DATABASE_ADMIN_URL |
| Agent runtime | `npm run test:runtime` | Manifest verification, tool filtering, kernel, metering, checkpoints and recovery | Scripted providers and mocked clients in unit cases |
| Execution runtime | `npm run test:execution` | Single-use grants, confinement, cancellation, process limits, private checkout and egress | Docker-dependent operational cases may skip |
| Role governance | `npm run test:evals` | Every role version's allowed/denied tools/actions and approval outcomes through shared runtimes | Models scripted; commands/browser results simulated |
| Model quality | `npm run eval:quality` | Unscripted model on simulated task world, deterministic gates and grader rubric | Explicit provider keys, model/judge IDs and token budget; real spend |
| Pilot evidence | `npm run readiness` | Named proofs actually ran/passed at this commit; remaining limits | Missing/skipped proof is not a pass; accepted limits yield AMBER |

CI runs Node 24, `npm ci` and `npm run check` with a PostgreSQL 16 service and uploads the computed readiness report. Quality workflow is scheduled Monday 06:00 UTC and manual, gated on repository variables/secret. Quality is not an every-commit gate because it spends model tokens.

## Lifecycle test checklist

Provision an active tenant/user/employee, install a pinned bundle, issue/verify its v2 manifest, create a thread/run, claim under the correct workload identity, invoke a model under budget, authorize tools, pause for approval, reject/expire or approve/resume, execute once in a confined workspace, register verified evidence and complete/cancel. Add wrong-tenant/owner, malformed input, invalid signature, unknown policy/action/tool, stale lease/checkpoint, unavailable stores and unknown-write cases.

Use `qa-generic-runtime.spec.ts`, `frontend-engineer.spec.ts`, `private-checkout-e2e.spec.ts`, `run-recovery-e2e.spec.ts` and both failure-drill suites for the cross-process paths. The source [test inventory](../reference/tests.md) records exact files. Do not claim a manual Jira/Vault/S3/collector test passed because a mock scenario passed.

## Quality reports and drift

Quality runs write JSON/Markdown reports with per-task gates and weighted rubric scores. History compares each model/grader/role-version/task series with prior runs and fails regressions. Import the verified history via `npm run db:import-quality -- /absolute/path/to/quality-history.jsonl` for the admin model-quality view. Keep examples and docs pinned to the source revision that defines the test expectation.

## Source provenance

Reviewed against platform commit `d2bc8d7fa3fc185cc4f487bdaa1f11611844763f`. These references support the behavior described; types alone are not evidence that a capability executes.

- [package.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/package.json)
- [.github/workflows/ci.yml](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/.github/workflows/ci.yml)
- [.github/workflows/quality.yml](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/.github/workflows/quality.yml)
- [apps/control-plane-api/test/evaluations/runner.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/test/evaluations/runner.ts)
- [apps/control-plane-api/test/evaluations/quality.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/test/evaluations/quality.ts)
- [pilot-readiness/assessment.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/pilot-readiness/assessment.json)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
