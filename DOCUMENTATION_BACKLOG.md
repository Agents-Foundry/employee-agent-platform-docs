# Documentation and evidence backlog

This backlog tracks missing information or operational evidence. It is separate from [engineering architecture gaps](docs/roadmap/architecture-gaps.md). No empty cloud/MCP/BYOK runbook is presented as current functionality.

| Area | Missing information | Repository | Suggested investigation | Priority |
| --- | --- | --- | --- | --- |
| Production topology | Chosen ingress/TLS/DNS/network policies, scaling placement and ownership | employee-agent-platform | Select a supported operator topology; test service routing, origins and workload keys; then document exact manifests | P0 |
| Backup / restore | Tested PostgreSQL, artifact and execution-state RPO/RTO and recovery sequencing | employee-agent-platform | Perform isolated restore drill, verify cross-store ownership and grant replay, record dates/results | P0 |
| Live dependencies | Qualification evidence for real Vault, S3-compatible storage and OTLP collector | employee-agent-platform | Run sandbox pilot integration drills with redacted evidence; record provider/version/configuration | P0 |
| Security ownership | Review owners, incident contacts, key rotation cadence and escalation SLA | employee-agent-platform / docs | Assign maintainers; publish operational responsibility rather than inventing contacts | P0 |
| Runtime qualification | Complete live-provider multi-role reliability/cost results | employee-agent-platform | Run bounded quality/live suites after approvals and pricing configuration; distinguish determinism from production success | P1 |
| API contract tooling | Complete query/response/service-error machine schema and OpenAPI generation | employee-agent-platform / docs | Add source annotations or shared schemas with authorization tests; current route/type reference remains source linked | P1 |
| Source drift | Automatic product PR documentation-impact signal | employee-agent-platform / docs | Add product-side checklist/path checks; pinned docs CI already exists | P1 |
| Schema verification | Live PostgreSQL introspection diff and execution SQLite migration versioning | employee-agent-platform / docs | Compare migrated disposable database constraints/policies to static dictionary in product CI | P1 |
| Screenshot UX guides | Stable generic-run/credential/download screens | employee-agent-platform | Implement/test UI flows before writing screen-specific instructions | P1 |
| Desktop distribution | Signed installers, updater, native authentication callback and support matrix | employee-agent-platform | Establish release pipeline and supported OS prerequisites, then document installation | P1 |
| Missing capabilities | MCP, executable skills, BYOK, memory, cloud IaC | employee-agent-platform | Implement and approve contracts/trust boundaries before creating configuration guides | P2 |
| ADR maintenance | Author-approved correction/supersession of ADR-0034 key-storage claim | employee-agent-platform / docs | Preserve history and propose a new ADR; current code correction is already annotated | P1 |
| Third-party links / diagrams | Periodic external URL and renderer visual review | employee-agent-platform-docs | Add scheduled authenticated-safe link checks and render review; current checks are offline syntax/path checks | P2 |

The current guides cover all major implemented subsystems. These evidence gaps constrain claims of production readiness and supported deployment behavior. Suggested investigations are recommendations, not approved historical architecture decisions.
