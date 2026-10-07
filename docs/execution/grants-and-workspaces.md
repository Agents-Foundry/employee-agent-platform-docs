# Execution grants, workspace ownership and local state

**Audience:** Execution developers, operators, security reviewers. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

Execution is a separate workload, not a shell embedded in the employee client. The agent obtains a control-plane-signed grant for an exact action/operation input, then sends `{ protocol: "agents-foundry/execution/v1", grant, operation }` to `/execution/v1/operations`. The execution process verifies signature, expiry, subject, input digest, capability and provider isolation. A grant authorizes one bounded operation; it is not an unrestricted repository token.

## Local SQLite records

These tables are created by StateStore and do not belong to the control-plane PostgreSQL migration stream. SQLite uses WAL; persistence must survive execution-process restarts.

| Table | Fields / constraints | Purpose |
| --- | --- | --- |
| grants | grant_id PK; state RUNNING/DONE CHECK; JSON-valid optional response; started_at/completed_at; added request_id/workspace_id | Durable single-use claim and completed response replay |
| workspaces | id PK; organization_id/employee_id/agent_id/thread_id; state; created_at/last_used_at; UNIQUE complete subject tuple | Associate one workspace with one tenant/employee/agent/thread |
| pending_credentials | grant_id PK; lease_id/request_id/workspace_id/target/started_at | Recover outstanding repository credential release after interruption |

`claimGrant` inserts once. A concurrent RUNNING grant does not execute again. DONE returns the stored ExecuteOperationResponse. A claim released before any work may be retried; startup closes unfinished work conservatively instead of blindly repeating it. Recovery is described in [failure handling](../operations/failure-handling.md).

## Workspace lifecycle

The registry detects lost workspace directories. A missing recorded workspace is not silently recreated as a fresh repository. Scope lookup includes all four subject IDs, not merely a repository name or agent ID. The contract defines PROVISIONING, READY, IN_USE, SUSPENDED, LOST and DESTROYED; supported transitions depend on provider operations, not a public workspace CRUD API.

Host code validates repository URLs/paths, rejects escaping paths/symlinks and runs constrained Git/file operations. Repository-supplied commands and Playwright execute in the configured Docker sandbox with time/output/resource limits. Host checkout and filesystem orchestration are not themselves container-network isolation; review [sandbox boundaries](operations-and-sandbox.md) and the threat model before accepting untrusted repositories.

Credential redemption is bound to an active grant and execution workload role. Checkout keys do not enter the model or tool result. Direct evidence upload uses control-plane authorization and completion checks; stored artifact metadata is centrally retained even though temporary workspace files are local.

## Operation response and diagnosis

HTTP 200 can contain DENIED, FAILED or TIMED_OUT. Read `result.status`, errors, truncation indicators and artifact records. Preserve the SQLite database alongside workspace files when diagnosing a restart. Do not edit a DONE grant to force replay or delete state to bypass an unknown outcome.

There is no distributed execution state backend or turnkey multi-node workspace scheduling. Route a persistent thread to its existing execution storage and document the deployment's recovery plan before scaling horizontally.

## Source provenance

Reviewed against platform commit `d2bc8d7fa3fc185cc4f487bdaa1f11611844763f`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/execution-runtime/src/state-store.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/execution-runtime/src/state-store.ts)
- [apps/execution-runtime/src/server.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/execution-runtime/src/server.ts)
- [apps/execution-runtime/src/execution-service.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/execution-runtime/src/execution-service.ts)
- [packages/contracts/src/execution-runtime/v1/schemas.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
