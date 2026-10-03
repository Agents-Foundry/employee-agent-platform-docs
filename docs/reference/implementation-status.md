# Implementation status by subsystem

**Audience:** All readers. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

Status is based on implementation and tests at the inspected commit, not on marketing copy. **Implemented** means working code exists, not a universal production guarantee. **Partially Implemented** means the specified support has a material missing surface/integration. **Planned** has no executable path. **Experimental** is opt-in development/test support. **Deprecated** requires an explicit deprecation decision; none is invented for still-supported V1/legacy QA.

| Subsystem | Status | Actual boundary / evidence | Documentation |
| --- | --- | --- | --- |
| Organization, people, job architecture and multiple memberships | Implemented | Password-mode administration; manual delivery | [Admin journey](../admin/setup.md) |
| Google/password sessions and browser ownership | Implemented | One Google domain, no native OAuth callback or built-in MFA | [Authentication](../security/authentication.md) |
| PostgreSQL isolation and migrations | Implemented | Tenant RLS plus separate privileged platform path | [Data model](../data-model/README.md) |
| Catalog/version/installation/agent assignment | Implemented | Five engineering role identities; seven blueprint versions; edits API-only for installations | [Catalog](../developer/catalog.md) |
| Manifest V2 | Implemented | Issuance default-off; runtime requires V2; legacy V1 still supported | [Manifest](../agents/manifest-v2.md) |
| Generic agent host/kernel/tools | Implemented | Default-off API; bounded non-streaming native loop | [Lifecycle](../runtime/lifecycle.md) |
| Model gateway | Partially Implemented | Anthropic plus opt-in scripted provider; no broad routing/provider set | [Model context](../runtime/context-and-models.md) |
| Action policy and approvals | Implemented | Fail closed, tighten-only, payload-bound expiry, no self-approval | [Policy](../admin/policies-and-approvals.md) |
| Execution runtime | Implemented | Constrained host operations plus Docker repository-code sandbox; local SQLite state | [Sandbox](../execution/operations-and-sandbox.md) |
| Jira/GitHub control-plane actions | Implemented | Jira read/create and approved draft GitHub PR only | [Integrations](../integrations/connectors-and-mcp.md) |
| Repository credentials | Implemented | GitHub/Bitbucket checkout, execution-only leases; GitHub-App revocation has restart limit | [Secrets](../security/secrets-and-credentials.md) |
| Vault and S3-compatible adapters | Partially Implemented | Adapter/tests implemented; live pilot services not qualified by repository tests | [Artifacts](../operations/artifacts.md) |
| Recovery/checkpoints | Implemented | Up to ten-minute detection; bodies not app-encrypted | [Recovery](../runtime/checkpoints-and-recovery.md) |
| Spending/prices/alerts/webhooks/model quality | Implemented | Explicit budgets/pricing, bounded quality runs; outbound webhooks opt-in | [Spending](../operations/model-spending.md) |
| Observability | Partially Implemented | OTLP and metrics implemented; no shipped dashboards/alert rules/live collector proof | [Operations](../operations/observability.md) |
| Generic-run/evidence/reconciliation management UI | Partially Implemented | Supported APIs with missing screens; employee UX is QA-focused | [Employee](../employee/workspace.md) |
| Tauri shell | Partially Implemented | Native wrapper, bundle disabled, no local kernel or OS model-key integration | [Desktop](../deployment/desktop.md) |
| Employee BYOK execution | Planned | Refused by current server; device-local design only | [Secrets](../security/secrets-and-credentials.md) |
| MCP, executable Skill Runtime, memory, context condensation and model streaming | Planned | Declarative fields do not execute these systems | [Gaps](../roadmap/architecture-gaps.md) |
| Public signup, purchase/seat automation and invitation email | Planned | Operator customer creation and manual links exist | [Onboarding](../admin/customer-onboarding.md) |
| External role-package publishing and cloud IaC | Planned | Monorepo catalog; no shipped K8s/GKE/Helm/Terraform stack | [Gaps](../roadmap/architecture-gaps.md) |
| Scripted model and local isolation exceptions | Experimental | Explicit development flags only | [Configuration](configuration.md) |

No measured onboarding-time claim, investor-readiness declaration, compliance certification or complete production-hosting promise is derived from the code. Consult evidence-derived pilot readiness for the actual test status at a deployment commit.

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/control-plane-api/src/database.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/database.ts)
- [packages/catalog/src/index.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/catalog/src/index.ts)
- [apps/agent-runtime/src/main.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/agent-runtime/src/main.ts)
- [apps/execution-runtime/src/main.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/execution-runtime/src/main.ts)
- [pilot-readiness/assessment.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/pilot-readiness/assessment.json)

## Related documentation

[Documentation index](../README.md) · [Implementation status](implementation-status.md)
