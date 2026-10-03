# Documentation foundation: implementation and completeness report

Verified on 2026-10-03 against **employee-agent-platform@9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4**. This documentation foundation is submitted on **docs/platform-documentation-foundation** for review. It changes documentation/tooling only. The initially empty private docs repository received a minimal README bootstrap on main to provide a PR base; the substantive foundation is on this review branch.

## Repositories inspected

| Repository | Evidence and responsibility |
| --- | --- |
| [employee-agent-platform](https://github.com/Agents-Foundry/employee-agent-platform) | Current fetched/pinned source: five applications, shared packages, routes/contracts, migrations, catalog, policy, tests, scripts/workflows, sandbox Dockerfile, Tauri config, existing guides and 38 ADRs |
| [employee-agent-website](https://github.com/Agents-Foundry/employee-agent-website) | 4cc111021cf60b5a4b676a26659fbc51431a5ef3; static build/package/site-config, README and GitHub Pages workflow; marketing surface without product authorization authority |
| [employee-agent-platform-docs](https://github.com/Agents-Foundry/employee-agent-platform-docs) | Initial empty/private state, default branch and permissions; current foundation/navigation/checks |

The organization's inventory contained these three active repositories. Runtime roles and services are directories in the product monorepo, not independent repositories. The user's older primary checkout and website work were preserved. [Provenance](docs/reference/provenance.md) distinguishes manual behavior review from hashing/indexing 391 source files.

## Documentation created and completeness audit

| Requirement / audience | Concrete deliverables | Coverage result |
| --- | --- | --- |
| New readers and repository responsibilities | Root README, audience paths, complete index, introduction, repository map and glossary | Covered |
| Architecture and request flow | Component/dependency views, request sequence, domain ER and ownership/entity matrix | Covered against implementation |
| Manifest | V2 resolution/schema/integrity/versioning/compatibility and complete signed examples | Covered; declarative fields distinguished from engines |
| Agent runtime | Run/step/event states, context/model loop, tool filtering, approval pause/resume, cancellation, checkpoints and recovery | Covered; no streaming/memory engine claimed |
| Execution | Grants, exact operations, SQLite state, workspace scope, Git/commands/browser, sandbox/egress and failure boundaries | Covered; host checkout and storage scaling limits explicit |
| Policy and approvals | Most-restrictive precedence, default outcomes/TTL, scope, no self-approval, payload binding, expiry and reconciliation | Covered |
| Tools/skills/connectors/MCP | Actual differences, provider surfaces and extension boundaries | Covered; missing MCP/Skill Runtime tracked |
| Security / enterprise IT | Authentication, tenant/RLS/platform scope, secrets/leases/model keys, artifacts, injection/SSRF and STRIDE | Covered as source-derived assessment; no certification claimed |
| Administrators and organization owners | Customer provisioning, activation, people/job/unit setup, installations/assignments, models, credentials and approvals | Covered; API-only/manual-delivery surfaces identified |
| Employees / support | Sign-in, agent verification, conversations, task/approval/evidence behavior and UI limits | Covered |
| Developers | Actual local/build/test commands, application/database development, role/tool/provider extension, parser/contract references | Covered; unsupported extension SDKs not invented |
| API | 127 actual registrations, grouped handlers, input schemas and wire types | All registrations covered; no fabricated OpenAPI |
| Database | 15 migrations, 60 product tables/632 fields, keys/checks/indexes/SQL, RLS and migration procedures | Covered by static reconstruction; ledger and execution SQLite separately explained |
| Deployment/operators | Actual process/env/desktop setup, health, telemetry, spending, artifacts, failure recovery and production checklist | Covered for shipped components; absent cloud stack/restore automation tracked |
| QA / implementation partners | Unit/integration/governance/quality/readiness distinctions, 69-file test inventory and five engineering use cases | Covered; live dependencies not qualified by mocks |
| Decisions and maintenance | 38 historical ADRs with correction notes, contributor/release policy, CI, architecture and evidence backlogs | Covered without manufactured decisions |

There are 112 Markdown documents and 10 architecture, dependency, sequence, state, ER and threat diagrams. The API includes 186 extracted validator expressions and 212 exported wire/domain contract declarations. These are literal source references, not proof of every possible future subsystem.

## Actual architecture discovered

The Control Plane API uses Express and PostgreSQL with tenant RLS plus an explicitly privileged platform connection. It owns identity/organization/catalog/manifest, runs/events/actions/approvals, credentials, artifacts and spending. Angular admin and employee applications use browser sessions; the employee application has a limited Tauri shell.

The separate Node agent runtime claims signed commands, verifies V2 manifests and runs a bounded native model/tool loop. Anthropic is the live adapter; scripted execution is opt-in test support. Tools request centrally governed actions or signed grants. The execution process maintains local SQLite grant/workspace state and executes constrained host operations or Docker-sandboxed repository code. Jira/GitHub connector writes run through the control plane; repository credential leases are execution-only.

Five engineering role identities resolve to seven immutable blueprint versions. V2 issuance and generic/QA runtime routes have separate default-off flags. Approval and grants authorize an exact payload; they do not turn catalog declarations into unrestricted execution.

## Significant implementation gaps and recommended engineering actions

| Gap | Engineering recommendation |
| --- | --- |
| MCP, executable skill loading, memory and context condensation absent | Define runtime semantics and tenant credential/action boundaries; implement before advertising configuration endpoints |
| Employee BYOK and desktop-local runtime absent; installer/native SSO incomplete | Implement device key custody, runtime identity, callback/distribution and supported-OS tests |
| Generic-run, artifact-download and reconciliation screens incomplete | Build against existing APIs with ownership/state/error tests |
| Anthropic/Jira/GitHub are narrower than questionnaire/design choices | Add adapters and qualification, or align supported selection options |
| Cloud IaC, backup/restore automation and dashboards absent | Choose a topology and ownership; provide manifests, restore drills and operator alerts |
| Host-bound execution/large buffered artifacts and in-memory admission controls | Measure capacity and multi-node placement; enforce limits and tenant-aware admission |
| Provider-write ambiguity and key-custody risks | Preserve reconciliation; design rotation, restart-safe provider revocation and outbound protection |
| Approval contract drift | Align legacy ApprovalRequest with EXPIRED read models and add serialization coverage |

The detailed [architecture backlog](docs/roadmap/architecture-gaps.md) also reproduces all 14 product-recorded pilot limitations. Priorities are recommendations, not invented accepted decisions.

## Documentation/evidence gaps and separate maintenance actions

Current executable subsystems are documented. Production topology, live Vault/S3/collector qualification, measured capacity, restore RPO/RTO, incident ownership and complete live multi-role reliability cannot be documented as proven without operator evidence. Packaged desktop, MCP/BYOK/cloud guides await implementation rather than empty placeholder pages.

Documentation maintainers should update stale product README/architecture guides to link this canonical repository, add product-side documentation-impact review, establish live schema introspection/OpenAPI tooling, assign review owners and perform renderer/external-link checks. [DOCUMENTATION_BACKLOG](DOCUMENTATION_BACKLOG.md) records missing information, owning repository, investigation and priority separately from engineering work.

## Inconsistencies discovered and handled

- Earlier product guides lag PostgreSQL, generic runtime, multi-organization accounts, artifacts, leases, spending and telemetry. Current guides follow source; historical context remains visible.
- An older assignment guide described only QA and no live model integration. It now explains five catalog roles, current organization-managed execution and partial UI coverage.
- ADR-0034 claims existing OS model-key storage; a correction identifies the current unimplemented desktop integration without rewriting the accepted decision.
- ADR-0025's local trend command lacks a workspace selector. The preserved record now includes the actual current command.
- The migration runner comment says one transaction per migration, while code wraps the pending batch in one transaction. Current documentation explains actual behavior.
- Legacy ApprovalRequest omits EXPIRED; newer summaries include it. This is a product follow-up, not silently repaired by docs.

No known unresolved current-behavior contradiction remains in authored guidance after this audit. Historical assertions and product contract/comment issues above remain explicitly annotated. This statement is a scoped source review, not a guarantee of absence of all latent product defects.

## Validation

| Check | Result |
| --- | --- |
| Markdown structural rules and duplicate headings | Passed across 112 files |
| Internal links and anchors | Zero broken targets in 1879 checked links |
| Pinned source references | Zero missing targets; 1235 checked references |
| Mermaid syntax | 10 diagrams parsed successfully |
| JSON | 13 files parsed successfully |
| API coverage | All 127 extracted registrations have reference sections |
| Source drift | 391 normalized source hashes match the pin |
| Catalog/manifest/action fixtures | 7 resolved bundles, 7 examples, real schema/digest/signature checks passed |
| Negative examples | 3 checks reject tampered signature, unknown manifest field and caller-supplied tenant |
| Documented npm commands | 73 references checked against actual root/workspace scripts |
| Empty or unwritten placeholder pages | Zero identified |
| Undocumented major implemented subsystems | Zero identified by the audience/component completeness review |

Commands executed here: `npm run schema:generate`, reference and role generators, `npm run check`, `npm run check:source`. This docs task did not rerun the product's full Docker/PostgreSQL/integration/live-provider suites. The pinned product commit's [existing GitHub CI run](https://github.com/Agents-Foundry/employee-agent-platform/actions/runs/37117939475) reports success; that external result is distinct from checks executed in this task.

Checks are offline for local/source targets; third-party URL availability, rendered diagram appearance and live deployments are not asserted. The schema dictionary does not replace PostgreSQL introspection. Documentation CI repeats structural checks and retrieves the exact product pin for fixture/hash validation. It does not automatically establish coverage of a later main commit.

## Final file tree

The tree contains documentation, generated references/fixtures and their maintenance tooling. Ignored source snapshots, dependencies, validation scratch output and private local credentials are excluded.

```text
employee-agent-platform-docs/
├── .github/
│   └── workflows/
│       └── documentation.yml
├── docs/
│   ├── admin/
│   │   ├── agent-assignments.md
│   │   ├── customer-onboarding.md
│   │   ├── organization-and-people.md
│   │   ├── policies-and-approvals.md
│   │   └── setup.md
│   ├── adr/
│   │   ├── 0001-foundation-architecture.md
│   │   ├── 0002-separate-agent-runtime-from-control-plane.md
│   │   ├── 0003-generic-agent-run.md
│   │   ├── 0004-agent-manifest-v2.md
│   │   ├── 0005-action-gateway.md
│   │   ├── 0006-agent-kernel-adapter.md
│   │   ├── 0007-separate-execution-runtime.md
│   │   ├── 0008-thread-vs-run-lifecycle.md
│   │   ├── 0009-role-packages-are-declarative.md
│   │   ├── 0010-catalog-of-record.md
│   │   ├── 0011-runtime-transport-and-workload-identity.md
│   │   ├── 0012-action-gateway-execution.md
│   │   ├── 0013-execution-grants.md
│   │   ├── 0014-qa-on-the-generic-runtime.md
│   │   ├── 0015-frontend-engineer-and-sandboxed-execution.md
│   │   ├── 0016-egress-proxy.md
│   │   ├── 0017-dependency-installation.md
│   │   ├── 0018-postgresql-row-level-security.md
│   │   ├── 0019-role-evaluation-suites.md
│   │   ├── 0020-model-quality-evaluations.md
│   │   ├── 0021-model-spending-limits.md
│   │   ├── 0022-model-prices-and-cost-limits.md
│   │   ├── 0023-model-budget-alerts.md
│   │   ├── 0024-alert-webhooks.md
│   │   ├── 0025-scheduled-quality-runs.md
│   │   ├── 0026-model-quality-view.md
│   │   ├── 0027-tenant-domain-cache.md
│   │   ├── 0028-native-column-types.md
│   │   ├── 0029-catalog-version-reload.md
│   │   ├── 0030-catalog-bundle-compatibility.md
│   │   ├── 0031-secret-and-credential-brokering.md
│   │   ├── 0032-durable-checkpoints-and-run-recovery.md
│   │   ├── 0033-durable-artifact-storage.md
│   │   ├── 0034-organization-managed-model-credentials.md
│   │   ├── 0035-observability.md
│   │   ├── 0036-failure-drills-and-reconciliation.md
│   │   ├── 0037-direct-artifact-upload-and-browser-evidence.md
│   │   ├── 0038-pilot-readiness-assessment.md
│   │   └── README.md
│   ├── agents/
│   │   └── manifest-v2.md
│   ├── api/
│   │   ├── agents-and-conversations.md
│   │   ├── authentication.md
│   │   ├── catalog.md
│   │   ├── contracts.md
│   │   ├── execution-server.md
│   │   ├── execution.md
│   │   ├── governance-and-connections.md
│   │   ├── models-and-alerts.md
│   │   ├── organization.md
│   │   ├── README.md
│   │   ├── request-schemas.md
│   │   └── runtime.md
│   ├── architecture/
│   │   ├── domain-model.md
│   │   ├── overview.md
│   │   └── request-lifecycle.md
│   ├── concepts/
│   │   ├── agents-and-catalog.md
│   │   └── identity-and-organization.md
│   ├── contributing/
│   │   └── release-documentation.md
│   ├── data-model/
│   │   ├── README.md
│   │   └── schema.md
│   ├── deployment/
│   │   ├── desktop.md
│   │   ├── production-checklist.md
│   │   └── runtime-processes.md
│   ├── developer/
│   │   ├── applications-and-database.md
│   │   ├── catalog.md
│   │   ├── extending-the-platform.md
│   │   └── local-development.md
│   ├── employee/
│   │   └── workspace.md
│   ├── execution/
│   │   ├── grants-and-workspaces.md
│   │   └── operations-and-sandbox.md
│   ├── getting-started/
│   │   └── introduction.md
│   ├── integrations/
│   │   └── connectors-and-mcp.md
│   ├── operations/
│   │   ├── artifacts.md
│   │   ├── failure-handling.md
│   │   ├── model-spending.md
│   │   ├── observability.md
│   │   └── troubleshooting.md
│   ├── qa/
│   │   ├── pilot-readiness.md
│   │   └── test-strategy.md
│   ├── reference/
│   │   ├── configuration.md
│   │   ├── environment-inventory.md
│   │   ├── glossary.md
│   │   ├── implementation-status.md
│   │   ├── provenance.md
│   │   ├── repository-map.md
│   │   └── tests.md
│   ├── roadmap/
│   │   └── architecture-gaps.md
│   ├── runtime/
│   │   ├── checkpoints-and-recovery.md
│   │   ├── context-and-models.md
│   │   ├── lifecycle.md
│   │   └── protocol.md
│   ├── security/
│   │   ├── authentication.md
│   │   ├── authorization.md
│   │   ├── secrets-and-credentials.md
│   │   └── threat-model.md
│   ├── use-cases/
│   │   ├── backend-engineer.md
│   │   ├── code-reviewer.md
│   │   ├── frontend-engineer.md
│   │   ├── qa-engineer.md
│   │   ├── README.md
│   │   └── test-automation-engineer.md
│   └── README.md
├── examples/
│   ├── api/
│   │   └── start-run.json
│   ├── manifest-v2/
│   │   ├── qa-agent.payload.json
│   │   ├── qa-agent.signed.json
│   │   └── verification-key.json
│   ├── runtime/
│   │   ├── action-request.json
│   │   ├── run-started.json
│   │   └── run-submit.json
│   └── README.md
├── reference-data/
│   ├── postgresql-migrations.sql
│   ├── routes.json
│   └── schema.json
├── scripts/
│   ├── generate-examples.mjs
│   ├── generate-reference.mjs
│   ├── generate-schema.mjs
│   ├── generate-use-cases.mjs
│   ├── validate-docs.mjs
│   └── validate-source.mjs
├── .gitattributes
├── .gitignore
├── CONTRIBUTING.md
├── DOCUMENTATION_BACKLOG.md
├── IMPLEMENTATION_REPORT.md
├── package-lock.json
├── package.json
├── README.md
└── source-inventory.json
```
