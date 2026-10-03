# Architecture and implementation gaps

**Audience:** Architects, engineering owners, operators. **Implementation status:** Planned.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

This backlog records work that cannot be closed by writing documentation. No missing capability is asserted to exist because a contract field or historical design mentions it. Priorities below are review recommendations, not invented organization commitments.

## Investigated implementation and documentation gaps

| Area | Missing information / capability | Source repository area | Required investigation or implementation | Priority / owner discipline |
| --- | --- | --- | --- | --- |
| MCP client | Client, installation/connection ownership, tool filtering and lifecycle | [packages/contracts/src/manifest-v2.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/manifest-v2.ts) | Implement and test transport/auth/unknown-tool denial before documenting lifecycle endpoints | P1 engineering |
| Skills/context/memory | Executable skill activation, instruction loading, context budgeting/condensation, memory provider | [apps/agent-runtime/src/kernel/native-kernel.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/agent-runtime/src/kernel/native-kernel.ts) | Define supported semantics and prove runtime consumption beyond IDs | P1 engineering |
| Employee BYOK | OS key storage and desktop-local registered runtime | [apps/agent-runtime/src/models/model-gateway.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/agent-runtime/src/models/model-gateway.ts) | Implement device-only key use, bounded workload identity and offline recovery | P1 engineering |
| Generic-run UI | Full start/follow/cancel and evidence controls for all roles | [apps/employee-desktop/src/app/app.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/employee-desktop/src/app/app.ts) | Wire existing APIs; test privacy and state/error displays | P1 engineering |
| Native distribution/SSO | Signed installer/updater and system-browser OAuth callback | [apps/employee-desktop/src-tauri/tauri.conf.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/employee-desktop/src-tauri/tauri.conf.json) | Choose supported platforms, implement deep links and release signing | P1 engineering |
| Provider breadth | Runtime adapters beyond Anthropic; connectors beyond Jira/GitHub actions | [apps/agent-runtime/src/main.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/agent-runtime/src/main.ts) | Implement typed adapters and scoped failure/idempotency tests; clarify questionnaire selections | P2 engineering |
| Catalog publishing | External role repository loading/promotion and per-employee reissue/edit | [apps/control-plane-api/src/catalog/catalog-service.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/catalog/catalog-service.ts) | Design immutable publication/signing and rollout compatibility before runbooks | P2 engineering |
| Granular RBAC | Permission inventory and custom security roles beyond ADMIN/EMPLOYEE | [packages/contracts/src/index.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts) | Specify least-privilege action/API scopes independently of job titles | P2 engineering |
| Cloud/production IaC | Kubernetes/GKE/Helm/Terraform/service stack and backup automation | [package.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/package.json) | Supply deployment manifests, secrets/network assumptions and repeatable restore drill | P1 deployment |
| Key rotation | Multi-key signing/verification, coordinated revocation and trust distribution | [apps/control-plane-api/src/manifest-signing.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/manifest-signing.ts) | Define rollover protocol without breaking existing signed manifests/grants | P1 security |
| Connector SSRF | Control-plane DNS rebinding/egress controls separate from execution proxy | [apps/control-plane-api/src/actions/connector-service.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/connector-service.ts) | Test DNS resolution/redirect/private-address behavior; deploy outbound restrictions | P1 security |
| Contract drift | ApprovalRequest lacks EXPIRED while newer read models include it | [packages/contracts/src/execution.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts) | Reconcile shared approval contracts and test all expiry serialization paths | P2 engineering |
| Historical docs drift | Phase A/C and onboarding claims lag code; old comments conflict with implementation | [docs/architecture-v2.md](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/docs/architecture-v2.md) | Retire or rewrite stale product README/guides; link canonical docs | P1 documentation |
| Deployment capacity | Measured concurrency/quotas/latency, admission control, distributed rate limit | [apps/control-plane-api/src/app.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts) | Run load tests; set service pool/body/upload/tenant limits and edge limiter | P1 deployment |
| Automated OpenAPI | No shipped OpenAPI contract with complete service validator linkage | [apps/control-plane-api/src/app.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts) | Generate from actual route/service schemas and test round trips; do not guess types | P2 documentation tooling |

## Product-recorded pilot limitations

These entries come directly from the current assessment file. A passing unit test does not remove the beforePilot step. The docs do not claim the live checks have been performed.

| Limitation | Severity | Current boundary | Required before-pilot action |
| --- | --- | --- | --- |
| object-store-not-live | ACCEPTED | The S3-compatible adapter is proven against the AWS signing example and a simulated bucket that checks signatures, not against a live S3, GCS or MinIO service. | Run an upload, direct upload, retrieval and retention pass against the pilot bucket. |
| vault-not-live | ACCEPTED | The Vault provider is proven against a simulated KV v2 API, not against a live Vault. | Resolve one connector secret and one model key through the pilot Vault. |
| employee-byok-unavailable | ACCEPTED | Employee-held model keys are refused (fail closed). The desktop-local runtime that would use them is designed, not built. | Pilot with organization-managed model credentials only. |
| checkout-on-host | ACCEPTED | git.checkout runs on the execution runtime's host behind the egress proxy, not inside the sandbox container. It executes no repository code. | Run execution runtimes on hosts dedicated to the pilot organization. |
| recovery-latency | ACCEPTED | A run abandoned by its runtime is picked up after its lease expires: up to ten minutes. | Tell pilot users; alert on af_runtime_leases{state="expired"}. |
| checkpoints-not-encrypted | ACCEPTED | Checkpoint bodies hold conversation content and are not encrypted by the application; they rely on database encryption at rest and row-level security. | Confirm encryption at rest on the pilot database. |
| artifact-retrieval-buffered | ACCEPTED | An artifact is read fully into memory to verify its hash before it is served or accepted: up to 128 MiB per request. | Size the control plane's memory for concurrent trace downloads. |
| artifact-download-api-only | ACCEPTED | Artifact download, model credentials and source-control connections have APIs but no screens in the web or desktop applications. | Give pilot administrators the API runbook. |
| reconciliation-api-only | ACCEPTED | Writes with an unknown outcome are reconciled by an administrator through the API; there is no screen and no notification beyond the metric and audit event. | Alert on af_action_reconciliations_total{event="required"} and document the runbook. |
| telemetry-not-live | ACCEPTED | The OTLP exporter and the Prometheus endpoints are proven in tests, not against a live collector or scraper. | Point the pilot deployment at its collector and confirm one run's trace arrives whole. |
| no-dashboards | ACCEPTED | No dashboards or alert rules are shipped; the metrics catalog is the input for them. | Create alerts for run failures, lease expiry, budget denials, store and secret failures, and reconciliations. |
| model-quality-not-in-ci | ACCEPTED | Live model-quality evaluation spends real tokens, so it runs weekly or by hand, not on every commit. Governance evaluations run on every commit. | Run the model-quality workflow for the pilot's model and review the scores. |
| no-mcp-client | INFORMATIONAL | There is no MCP client: tools are the runtime's own implementations of catalog tool definitions. | None for the engineering roles shipped. |
| skills-are-guidance | INFORMATIONAL | There is no Skill Runtime: skills are catalog data that shape the prompt and name the tools; they do not execute. | None for the engineering roles shipped. |

## Scope and supersession

Older Phase A gap analysis is a historical baseline at an earlier SHA. Runtime separation, Policy v2, PostgreSQL RLS, Vault adapter, durable checkpoints/artifacts, private checkout, telemetry and reconciliation now exist. They must not remain marked absent in current docs. Remaining operational qualification is distinct from absent implementation.

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [pilot-readiness/assessment.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/pilot-readiness/assessment.json)
- [docs/architecture-v2-gap-analysis.md](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/docs/architecture-v2-gap-analysis.md)
- [apps/agent-runtime/src/kernel/native-kernel.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/agent-runtime/src/kernel/native-kernel.ts)
- [apps/control-plane-api/src/actions/connector-service.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/connector-service.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
