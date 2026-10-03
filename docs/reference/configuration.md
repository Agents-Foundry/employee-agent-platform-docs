# Configuration, defaults and feature flags

**Audience:** Operators, developers. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

Settings are process-specific. npm workspace scripts load the root .env but run from the workspace directory; relative paths resolve there. An inherited environment value can override the env file. Use absolute deployed paths and do not copy local development passwords into production.

| Process / setting | Default or requirement | Effect |
| --- | --- | --- |
| API PORT | 4100; listener 127.0.0.1 | Reverse proxy needed for external access |
| AUTH_MODE | google | Explicit password/demo alternatives; demo forbidden in production |
| DATABASE_URL / DATABASE_PLATFORM_URL | Required | Tenant and privileged platform PostgreSQL roles |
| DATABASE_MIGRATION_URL | Optional | Apply schema at startup; otherwise separately migrate |
| DATABASE_ADMIN_URL | Bootstrap tool only | Superuser used for local/operator database initialization |
| MANIFEST_SIGNING_KEY_PATH | .data/agents-foundry.db.signing-key.pem in API working dir | Persistent Ed25519 manifest/grant signer |
| AGENT_MANIFEST_V2_ISSUANCE_ENABLED | false | New manifests V2, existing signatures unchanged |
| GENERIC_AGENT_RUNTIME_ENABLED | false | Start generic runs via API |
| QA_GENERIC_RUNTIME_ENABLED | false | Eligible QA tasks use generic workflow instead of legacy plan |
| AGENT_RUNTIME_IDENTITIES_PATH | unset | No registered workload means no runtime authentication |
| SECRET_PROVIDER | development | vault uses KV v2 instead of plaintext development file |
| CONNECTOR_SECRETS_PATH | unset | Organization-scoped development references resolve from file |
| VAULT_ADDR / VAULT_TOKEN_PATH | Required for vault | HTTPS store and fresh token file; KV mount/prefix/namespace optional configuration |
| ARTIFACT_STORE | local | s3 selects S3-compatible adapter; configure endpoint/region/bucket/credentials file |
| ARTIFACTS_REQUIRE_MANAGED | false | Refuse evidence bytes held only on runtime-local storage |
| Agent CONTROL_PLANE_URL / AGENT_RUNTIME_ID / AGENT_RUNTIME_PRIVATE_KEY_PATH / MANIFEST_VERIFICATION_KEY | Required | Signed claims/requests and pinned verification |
| AGENT_RUNTIME_POLL_MS | 2000, bounds 100–60000 | Polling interval |
| AGENT_RUNTIME_CONCURRENCY | 4, bounds 1–64 | Concurrent runs per agent process |
| AGENT_RUNTIME_HEARTBEAT_MS | 30000, bounds 1000–300000 | Liveness renewal |
| AGENT_RUNTIME_CHECKPOINT_STORE / AGENT_RUNTIME_ARTIFACT_STORE | control-plane | local is development-only with reduced recovery/retrieval |
| AGENT_RUNTIME_ENV_MODEL_KEYS | false | Development environment credential fallback |
| AGENT_RUNTIME_ENABLE_SCRIPTED_MODEL | false | Deterministic non-live model |
| EXECUTION_RUNTIME_URL | unset on agent | Workspace-backed tools absent until configured |
| Execution EXECUTION_RUNTIME_HOST / EXECUTION_RUNTIME_PORT | 127.0.0.1 / 4500 | Private execution HTTP endpoint |
| EXECUTION_PROVIDER | local | container needed for sandboxed repository code |
| EXECUTION_SANDBOX_IMAGE | Required for container | Pre-existing image; provider uses --pull never |
| EXECUTION_GRANT_VERIFICATION_KEY | Required | Pinned signer SPKI |
| EXECUTION_CONTROL_PLANE_URL / EXECUTION_RUNTIME_ID / EXECUTION_RUNTIME_KEY_PATH | All or none | Execution identity for checkout leases and durable evidence |
| EXECUTION_EGRESS_PROXY | On unless false | Private sandbox network with allow-list proxy |
| EXECUTION_ALLOW_UNSANDBOXED / EXECUTION_ALLOW_UNRESTRICTED_EGRESS / EXECUTION_ALLOW_FILE_REPOSITORIES | false | Explicit development exceptions; not pilot defaults |
| TELEMETRY_EXPORTER | none | console or otlp; unknown/missing required endpoint stops startup |
| OTEL_EXPORTER_OTLP_ENDPOINT | Required for otlp | HTTPS collector base; /v1/traces and /v1/metrics |
| METRICS_TOKEN_PATH / EXECUTION_METRICS_TOKEN_PATH | unset | Conditional /metrics; token >=32 chars |

The [complete source-read inventory](environment-inventory.md) includes additional test, quality, webhook, storage and provider settings. Required helper names (for example EXECUTION_SANDBOX_IMAGE) and computed `AF_MODEL_API_KEY_<PROVIDER>` names are covered here. Look up bounds/defaults in the exact source, not a copied env sample alone.

## Startup dependency order

Provision database roles and migrate; start API/catalog registration and verified authentication; register workload keys/pinned verification; start execution provider with images/storage; start agent runtime; open admin/employee applications. Provision installations and V2 assignments only after intended flags, credentials and scopes are configured.

A flags-only change cannot add a missing provider, MCP client or local BYOK engine. Live quality evaluations require explicit model/judge IDs, total budget and secret; they are never enabled by general runtime flags.

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [.env.example](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/.env.example)
- [apps/control-plane-api/src/database.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/database.ts)
- [apps/control-plane-api/src/auth.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts)
- [apps/agent-runtime/src/config.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/agent-runtime/src/config.ts)
- [apps/execution-runtime/src/main.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/execution-runtime/src/main.ts)
- [apps/execution-runtime/src/credential-client.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/execution-runtime/src/credential-client.ts)
- [apps/control-plane-api/src/secrets/secret-broker.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/secrets/secret-broker.ts)
- [packages/telemetry/src/telemetry.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/telemetry/src/telemetry.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](implementation-status.md)
