# Architecture decision record archive

**Audience:** Architects, maintainers and security reviewers. **Record status:** Historical originals, not newly invented approvals.

These 38 records were imported from the pinned product repository, preserving original status, date, context, decision and consequences. Some records omit alternatives; none have been manufactured to fill a template. The archive records intent at the decision's date; current implementation is documented in the [architecture](../architecture/overview.md) and [status matrix](../reference/implementation-status.md).

ADR-0034 contains an explicit current correction for its desktop OS-credential-store assertion. Earlier phases and SQLite-era descriptions must be read in context: PostgreSQL is the current control-plane backend. Use [provenance](../reference/provenance.md) for conflicts found during this review.

| Record | Original status | Original date |
| --- | --- | --- |
| [ADR 0001: Split control plane and employee desktop](0001-foundation-architecture.md) | Accepted | 2026-09-20 |
| [ADR 0002: Separate the agent runtime from the control plane](0002-separate-agent-runtime-from-control-plane.md) | Accepted | 2026-09-23 |
| [ADR 0003: Generic AgentRun replaces role-specific run architecture](0003-generic-agent-run.md) | Accepted | 2026-09-23 |
| [ADR 0004: Agent Manifest v2](0004-agent-manifest-v2.md) | Accepted | 2026-09-23 |
| [ADR 0005: Action Gateway for governed external actions](0005-action-gateway.md) | Accepted (implemented in Phase D; see [ADR 0012](0012-action-gateway-execution.md)) | 2026-09-23 |
| [ADR 0006: Agent kernel adapter boundary](0006-agent-kernel-adapter.md) | Accepted (implemented in Phase C: `apps/agent-runtime/src/kernel`, `NativeKernel`) | 2026-09-23 |
| [ADR 0007: Separate execution runtime](0007-separate-execution-runtime.md) | Accepted (implemented in Phase E; see [ADR 0013](0013-execution-grants.md)) | 2026-09-23 |
| [ADR 0008: Thread vs run lifecycle](0008-thread-vs-run-lifecycle.md) | Accepted | 2026-09-23 |
| [ADR 0009: Role packages are declarative expertise](0009-role-packages-are-declarative.md) | Accepted; validated in Phase G by the Frontend Engineer (ADR 0015) | 2026-09-23 |
| [ADR 0010: Immutable catalog of record pinned by digest](0010-catalog-of-record.md) | Accepted | 2026-09-25 |
| [ADR 0011: Runtime transport, workload identity and the in-repository runtime](0011-runtime-transport-and-workload-identity.md) | Accepted | 2026-09-25 |
| [ADR 0012: Action Gateway execution, Policy v2 and connector secrets](0012-action-gateway-execution.md) | Accepted | 2026-09-25 |
| [ADR 0013: Execution runtime authorized by signed grants](0013-execution-grants.md) | Accepted | 2026-09-26 |
| [ADR 0014: QA runs on the generic runtime](0014-qa-on-the-generic-runtime.md) | Accepted | 2026-09-26 |
| [ADR 0015: Frontend Engineer, sandboxed execution and governed pull requests](0015-frontend-engineer-and-sandboxed-execution.md) | Accepted; egress allow-lists added by ADR 0016, dependency installation by ADR 0017 | 2026-09-26 |
| [ADR 0016: Grant host allow-lists enforced by an egress proxy](0016-egress-proxy.md) | Accepted | 2026-09-28 |
| [ADR 0017: Governed dependency installation](0017-dependency-installation.md) | Accepted | 2026-09-28 |
| [ADR 0018: PostgreSQL with row-level security](0018-postgresql-row-level-security.md) | Accepted | 2026-09-28 |
| [ADR 0019: Governance evaluation suites for catalog roles](0019-role-evaluation-suites.md) | Accepted | 2026-09-29 |
| [ADR 0020: Model-quality evaluations](0020-model-quality-evaluations.md) | Accepted | 2026-09-29 |
| [ADR 0021: Organization model spending limits](0021-model-spending-limits.md) | Accepted | 2026-09-29 |
| [ADR 0022: Per-model prices and cost limits](0022-model-prices-and-cost-limits.md) | Accepted | 2026-09-29 |
| [ADR 0023: Model budget alerts](0023-model-budget-alerts.md) | Accepted | 2026-09-29 |
| [ADR 0024: Alert webhooks](0024-alert-webhooks.md) | Accepted | 2026-09-30 |
| [ADR 0025: Scheduled model-quality runs and score history](0025-scheduled-quality-runs.md) | Accepted | 2026-09-30 |
| [ADR 0026: Model quality in the control plane](0026-model-quality-view.md) | Accepted | 2026-09-30 |
| [ADR 0027: Remembering verified tenant domains](0027-tenant-domain-cache.md) | Accepted | 2026-09-30 |
| [ADR 0028: Native timestamp and JSON column types](0028-native-column-types.md) | Accepted | 2026-09-30 |
| [ADR 0029: Loading catalog versions registered by other instances](0029-catalog-version-reload.md) | Accepted | 2026-10-01 |
| [ADR 0030: Catalog bundle compatibility](0030-catalog-bundle-compatibility.md) | Accepted | 2026-10-01 |
| [ADR 0031: Secret broker, credential broker and private repository checkout](0031-secret-and-credential-brokering.md) | Accepted | 2026-10-01 |
| [ADR 0032: Durable checkpoints and run recovery](0032-durable-checkpoints-and-run-recovery.md) | Accepted | 2026-10-01 |
| [ADR 0033: Durable artifact storage](0033-durable-artifact-storage.md) | Accepted | 2026-10-01 |
| [ADR 0034: Organization-managed model credentials through the secret broker](0034-organization-managed-model-credentials.md) | Accepted | 2026-10-01 |
| [ADR 0035: Provider-neutral traces and metrics on the platform's own correlation](0035-observability.md) | Accepted | 2026-10-02 |
| [ADR 0036: Failure drills, and reconciliation of writes with an unknown outcome](0036-failure-drills-and-reconciliation.md) | Accepted | 2026-10-02 |
| [ADR 0037: Direct artifact upload, and richer browser evidence](0037-direct-artifact-upload-and-browser-evidence.md) | Accepted | 2026-10-02 |
| [ADR 0038: A pilot-readiness assessment computed from test results](0038-pilot-readiness-assessment.md) | Accepted | 2026-10-02 |

## New decisions and ADR backlog

[ADR 0039: Operating the controlled pilot](0039-pilot-operations.md) — Accepted, 2026-10-07. Adds reconciliation screens, monitoring definitions, live validation, guarded smoke and deployment evidence gates.

Propose a new numbered decision with Status, Context, Decision, Alternatives Considered and Consequences, identifying approvers and source changes. Mark a proposal Proposed until accepted; do not convert this documentation author's recommendations into historical approval.

Candidate decisions need product-owner review: production topology and restore guarantees; MCP credential/action governance; executable skill loading; desktop key custody/BYOK; distributed execution placement. Investigations and priorities are in the [documentation backlog](../../DOCUMENTATION_BACKLOG.md) and [architecture gaps](../roadmap/architecture-gaps.md).

[Documentation index](../README.md) · [Release documentation](../contributing/release-documentation.md)
