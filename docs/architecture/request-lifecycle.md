# Request and evidence lifecycle

**Audience:** Architects, developers, QA. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

The generic path begins with an assigned v2 agent and an authenticated employee. A task is one run inside a durable thread. Browser-facing routes and workload routes use separate authentication mechanisms.

```mermaid
sequenceDiagram
  actor Employee
  participant API as Control plane
  participant DB as PostgreSQL
  participant Runtime as Agent runtime
  participant Model as Model provider
  participant Admin as Administrator
  participant Exec as Execution runtime
  participant Store as Artifact store
  Employee->>API: POST /api/execution/v1/runs (agentId, task)
  API->>API: Session, ownership, v2 manifest, workflow and flags
  API->>DB: Create thread/run and run.created
  API-->>Employee: 202 AgentRun
  Runtime->>API: Signed POST /runtime/v1/commands/claim
  API-->>Runtime: run.submit plus lease
  Runtime->>Runtime: Verify pinned signature and subject
  Runtime->>API: run.started, steps, model reservation
  Runtime->>Model: Complete with filtered tools
  Model-->>Runtime: Message and tool calls
  Runtime->>API: Action request with canonical payload digest
  API->>DB: Approval and WAITING_FOR_APPROVAL atomically
  Runtime->>API: Durable checkpoint
  Admin->>API: Approve pending request
  API->>DB: Requeue run and reset paused step
  Runtime->>API: Claim run.resume and emit run.resumed
  Runtime->>API: Request signed execution grant
  Runtime->>Exec: Operation and single-use grant
  Exec->>Exec: Verify, consume, execute within workspace
  Exec->>API: Execution identity uploads verified evidence
  API->>Store: Persist bytes and lifecycle record
  Exec-->>Runtime: Result and artifact registrations
  Runtime->>API: Tool result, artifact.created and run.completed
  Employee->>API: Read own run and event page
  Employee->>API: Request artifact retrieval permission
  API-->>Employee: Session-bound download path (60 seconds)
```

For a connector action such as `jira.issue.create`, the runtime uses `/runtime/v1/actions/execute` after approval; the control plane invokes the connector directly. There is no execution grant for that connector call. Reads can be allowed without a human approval, but still pass assignment, digest, scope and policy checks.

## Failure and cancellation

A rejection cancels the paused run. Unanswered expired approvals cancel it with `APPROVAL_EXPIRED`. An owning employee can cancel via `/api/execution/v1/runs/:id/cancel`. Invalid transitions and events after a terminal state are refused. Durable recovery reuses the prior request identifiers; it does not grant permission to repeat an external write with an unknown outcome.

## Legacy QA compatibility

`POST /api/qa/runs` remains supported. With eligible v2 agents and `QA_GENERIC_RUNTIME_ENABLED=true` it queues the generic `validate-story` workflow; otherwise it follows the legacy planned-QA/approval path. Legacy `READY` is not equivalent to generic `COMPLETED`. See [QA workflow](../use-cases/qa-engineer.md).

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/control-plane-api/src/execution/execution-routes.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/execution/execution-routes.ts)
- [apps/control-plane-api/src/runtime/runtime-transport-service.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-transport-service.ts)
- [apps/agent-runtime/src/kernel/native-kernel.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/agent-runtime/src/kernel/native-kernel.ts)
- [apps/control-plane-api/src/actions/action-gateway.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-gateway.ts)
- [apps/execution-runtime/src/execution-service.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/execution-runtime/src/execution-service.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
