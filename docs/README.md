# Documentation index

**Audience:** All readers. **Implementation status:** Current source-backed documentation with explicit partial/planned boundaries.

Prerequisites vary by guide. Start with the [introduction](getting-started/introduction.md), [implementation matrix](reference/implementation-status.md) and [repository map](reference/repository-map.md). This index includes every substantive guide and generated reference; it is not a list of promised future capabilities.

| Audience | Recommended sequence |
| --- | --- |
| Developer | Local setup → architecture/request lifecycle → manifest → extension guide → API/schema reference → test strategy |
| Administrator | Customer onboarding → setup/people → assignments → credentials/models → policies/approvals |
| Employee | Workspace → supported role walkthrough → permissions/approval boundaries → artifacts and troubleshooting |
| Architect/security | Repository map → domain model → runtime/execution → authentication/authorization → threat model |
| Operator/release owner | Service configuration → production checklist → observability/recovery → pilot readiness → release policy |

## Getting started

- [Introduction and reader journeys](getting-started/introduction.md)

## Platform concepts

- [Blueprints, installations and assigned agents](concepts/agents-and-catalog.md)
- [Identity, employment and organizational roles](concepts/identity-and-organization.md)

## Architecture

- [Domain ownership and relationships](architecture/domain-model.md)
- [Platform architecture](architecture/overview.md)
- [Request and evidence lifecycle](architecture/request-lifecycle.md)

## Agent manifests

- [Agent Manifest V2: resolution, integrity and interpretation](agents/manifest-v2.md)

## Administrator guides

- [Admin agent assignment transactions](admin/agent-assignments.md)
- [Operator provisioning, invitations and recovery](admin/customer-onboarding.md)
- [Organization, people and job administration](admin/organization-and-people.md)
- [Policy precedence and human approvals](admin/policies-and-approvals.md)
- [Organization administrator setup journey](admin/setup.md)

## Employee guides

- [Employee workspace and onboarding](employee/workspace.md)

## Developer guides

- [Application development, schema changes and debugging](developer/applications-and-database.md)
- [Catalog validation, versioning and evaluations](developer/catalog.md)
- [Adding roles, tools and providers](developer/extending-the-platform.md)
- [Developer setup and verification](developer/local-development.md)

## Agent runtime

- [Durable checkpoints, leases and retry safety](runtime/checkpoints-and-recovery.md)
- [Context construction and model invocation](runtime/context-and-models.md)
- [Threads, runs, steps and event transitions](runtime/lifecycle.md)
- [Signed runtime protocol](runtime/protocol.md)

## Execution runtime

- [Execution grants, workspace ownership and local state](execution/grants-and-workspaces.md)
- [Workspace operations and sandbox guarantees](execution/operations-and-sandbox.md)

## Integrations

- [Connector capabilities, tools and MCP boundaries](integrations/connectors-and-mcp.md)

## Security

- [Authentication, sessions and browser origins](security/authentication.md)
- [Authorization and tenant isolation](security/authorization.md)
- [Secrets, model keys and repository credential leases](security/secrets-and-credentials.md)
- [Threat model and control coverage](security/threat-model.md)

## API and contracts

- [agents and conversations API](api/agents-and-conversations.md)
- [authentication API](api/authentication.md)
- [catalog API](api/catalog.md)
- [Wire and domain contract reference](api/contracts.md)
- [execution server API](api/execution-server.md)
- [execution API](api/execution.md)
- [governance and connections API](api/governance-and-connections.md)
- [models and alerts API](api/models-and-alerts.md)
- [organization API](api/organization.md)
- [API conventions and navigation](api/README.md)
- [Request and protocol validation schemas](api/request-schemas.md)
- [runtime API](api/runtime.md)

## Database model

- [Database migrations, RLS and data ownership](data-model/README.md)
- [PostgreSQL schema and constraints](data-model/schema.md)

## Deployment

- [Desktop shell build and distribution boundary](deployment/desktop.md)
- [Controlled pilot and production checklist](deployment/production-checklist.md)
- [Running the agent and execution processes](deployment/runtime-processes.md)

## Operations

- [Pilot operations and host validation](operations/pilot-operations.md)
- [Controlled pilot smoke test](operations/pilot-smoke.md)
- [Pilot operator runbook](operations/pilot-runbook.md)

- [Artifacts, evidence storage and retention](operations/artifacts.md)
- [Failure handling and write reconciliation](operations/failure-handling.md)
- [Model spending, prices, alerts and quality history](operations/model-spending.md)
- [Observability and alert signals](operations/observability.md)
- [Troubleshooting by symptom](operations/troubleshooting.md)

## Testing and readiness

- [Evidence-derived pilot readiness](qa/pilot-readiness.md)
- [Testing, governance evaluations and quality gates](qa/test-strategy.md)

## Role use cases

- [Backend Engineer: end-to-end use case](use-cases/backend-engineer.md)
- [Code Reviewer: end-to-end use case](use-cases/code-reviewer.md)
- [Frontend Engineer: end-to-end use case](use-cases/frontend-engineer.md)
- [QA Engineer: end-to-end use case](use-cases/qa-engineer.md)
- [Supported role walkthroughs](use-cases/README.md)
- [Test Automation Engineer: end-to-end use case](use-cases/test-automation-engineer.md)

## Reference

- [Configuration, defaults and feature flags](reference/configuration.md)
- [Environment variable source inventory](reference/environment-inventory.md)
- [Glossary and naming distinctions](reference/glossary.md)
- [Implementation status by subsystem](reference/implementation-status.md)
- [Source provenance and verification limits](reference/provenance.md)
- [Repository and component map](reference/repository-map.md)
- [Test evidence inventory](reference/tests.md)

## Gaps and roadmap

- [Architecture and implementation gaps](roadmap/architecture-gaps.md)

## Documentation maintenance

- [Release documentation and drift policy](contributing/release-documentation.md)

## Historical decisions

[ADR index: all 39 decisions](adr/README.md). Read current correction notes before treating an earlier decision as evidence of implementation.

## Repository resources

[Validated examples](../examples/README.md) · [Contributor commands](../CONTRIBUTING.md) · [Documentation backlog](../DOCUMENTATION_BACKLOG.md) · [Foundation audit report](../IMPLEMENTATION_REPORT.md)
