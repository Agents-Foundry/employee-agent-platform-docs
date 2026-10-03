# Controlled pilot and production checklist

**Audience:** Operators, security owners. **Implementation status:** Partially Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

The platform ships a controlled-pilot evidence assessment, not a complete turnkey production stack. The checklist below is operator work derived from implemented boundaries and recorded limitations. It does not assert that a production rollout has passed these checks.

| Check | Evidence to retain |
| --- | --- |
| Build, tests and readiness from the deployed SHA | CI logs and `.readiness/pilot-readiness-report.json`; review every AMBER limitation |
| Non-demo authentication and TLS | Real admin/employee sign-in, forbidden origin and wrong-tenant negative checks |
| Separate owner/platform/tenant database credentials | Role attributes, forced RLS checks, exact schema migration checksums |
| Private API/runtime transport | API binds loopback; reverse proxy and network access match registered host/origin policy |
| Workload and signing-key persistence | Explicit tenant/profile registrations, pinned public keys, protected private-key files and backup |
| Production secret broker | Live Vault connector/model lookup; credential denial when Vault is unavailable |
| Organization-managed model credentials | A real model call and refusal for employee BYOK; token and cost limits exercised |
| Container execution and egress | Dedicated pilot execution hosts; denied metadata/unapproved-host requests; resource/time limits |
| Durable artifacts | Live upload, direct upload, retrieval, corruption refusal, retention pass and private bucket |
| Database and content encryption | Encryption at rest supplied by services; checkpoint content not app-encrypted |
| Telemetry | One complete run trace in real collector and token-authenticated scraping |
| Operator alerts and reconciliation | Failure, expired lease, secret/store failures, budget denial and unknown-write alerts; manual resolution drill |
| Model quality | Explicitly funded quality workflow for selected model, saved scores and trend review |
| Backup and restore | Restore database, signing key, artifact bytes and execution-state dependencies in an isolated environment |
| Capacity and ownership | Concurrent 128 MiB downloads sized, tenant host ownership, incident and retention owners named |

## Scaling and recovery

Multiple agent runtimes use the central lease mechanism and durable checkpoints. This does not establish unlimited horizontal scaling for every service. The API has in-memory rate limiting/caches and privileged cross-tenant database work; load testing, shared reverse-proxy limits, pool sizing and admission control remain deployment investigations. Execution state/workspaces are host-bound.

## Deployment artifacts not present

No Kubernetes/GKE manifests, Helm chart, Terraform stack, production Docker Compose stack, shipped dashboard/alert rules, backup automation or desktop distribution workflow was found. Keep these in the [architecture backlog](../roadmap/architecture-gaps.md), with concrete engineering owners, before claiming supported cloud deployment procedures.

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [pilot-readiness/assessment.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/pilot-readiness/assessment.json)
- [packages/readiness/src/assess.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/readiness/src/assess.ts)
- [apps/control-plane-api/src/server.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/server.ts)
- [apps/control-plane-api/src/db/bootstrap.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/bootstrap.ts)
- [apps/execution-runtime/src/main.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/execution-runtime/src/main.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
