# API conventions and navigation

**Audience:** API consumers, developers, administrators. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

The API reference follows actual route registrations. Browser routes use authenticated sessions; workload routes use Ed25519 request signatures; execution operations use payload-bound grants. There is no general public bearer API-token scheme for business CRUD.

| Area | Reference |
| --- | --- |
| Sign-in, activation, account linking and switching | [Authentication](authentication.md) |
| Profile, people, units, positions and membership | [Organization](organization.md) |
| Catalog versions and installations | [Catalog](catalog.md) |
| Assignment, manifest, provisioning, conversations and approvals | [Agents and conversations](agents-and-conversations.md) |
| Threads, runs, cancellation and artifact retrieval | [Execution API](execution.md) |
| Connector/source-control connections, policies and reconciliation | [Governance and connections](governance-and-connections.md) |
| Model budgets, prices, credentials, usage, quality and alerts | [Models and alerts](models-and-alerts.md) |
| Signed commands, events, actions, checkpoints, credentials and evidence | [Runtime transport](runtime.md) |
| Execution process operation and health endpoints | [Execution server](execution-server.md) |
| Literal field bounds / request validators | [Schemas](request-schemas.md) |
| Request, response and domain TypeScript representations | [Contracts](contracts.md) |

## HTTP and ownership conventions

Local API base is http://localhost:4100. In deployed browser clients `/api` is reverse-proxied on the configured shared hostname. Cookies are sent with credentials; Origin must exactly match a configured UI for mutations. Do not post caller-supplied tenant/role identity and expect it to override the session.

JSON browser requests are capped at 64 KiB. Business API responses use Cache-Control: no-store. Runtime transport has its own raw-body parser/limits and authentication outside /api. Runtime signatures cover AF-RUNTIME-V1, uppercase method, exact original path, timestamp, nonce and SHA-256 of raw bytes; skew is at most five minutes and nonces are single-use.

Path UUID/record validation varies by handler. Collection pagination is service-defined; execution events use afterSequence >=0 and limit 1–200 (default 100). Versioned organization updates use optimistic `version` and return conflict instead of overwriting a stale record. Use current field names from source schemas; unknown fields are rejected where schemas are strict.

## Responses and errors

Common error envelope is `{ "error": "CODE" }`; Zod/protocol validation may add `details`. 400 denotes validation, 401 authentication failure, 403 forbidden role/origin/workload, 404 unavailable/ownership-hidden resource or disabled route, 409 stale/conflicting/expired state, 413 oversized body, 415 wrong content type, 421 unrecognized host and 500 internal failure. Services retain exact error codes—see the route handler/source and troubleshooting table.

`POST /api/execution/v1/runs` returns 202 AgentRun, not synchronous completion. Workload claims return 204 when no command is pending. An execution operation can return HTTP 200 with FAILED, DENIED or TIMED_OUT result.status. Never infer success solely from HTTP status.

## Examples and schemas

The [copyable API workflow](../../examples/README.md) explains cookies, Origin, known IDs and artifact retrieval. Example task/manifest/protocol JSON is validated by the source parser. Route excerpts show actual response service expressions; full wire types and validators are available above. The generator fails on unresolved route-path expressions rather than emitting guessed endpoints.

No OpenAPI document is shipped by the product. This repository does not invent one from incomplete typings. A source-linked contract reference and complete registration inventory preserve the known behavior; automated service-schema OpenAPI generation is a documentation tooling follow-up.

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/control-plane-api/src/app.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts)
- [apps/control-plane-api/src/auth.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts)
- [apps/control-plane-api/src/runtime/runtime-routes.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts)
- [apps/execution-runtime/src/server.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/execution-runtime/src/server.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
