# ADR 0007: Separate execution runtime

**Record type:** historical architecture decision imported from the product repository. Its original status/date and phase context are preserved. Use the current architecture and implementation matrix for today’s behavior; an accepted decision is not evidence that every described future capability exists.

- Status: Accepted (implemented in Phase E; see [ADR 0013](0013-execution-grants.md))
- Date: 2026-09-23

## Context

Shell, git, filesystem, browser and Playwright execution must be isolated with resource,
filesystem and network limits, and must be portable across hosting providers.

## Decision

Dangerous work runs in an execution runtime behind an `ExecutionProvider` interface
(`LocalExecutionProvider` first; Docker, Kubernetes and hosted sandboxes later). The agent
runtime requests execution; it does not host it. Workspaces are owned by
(organization, employee, agent, thread). If a workspace with uncommitted work is lost, the
runtime fails explicitly instead of silently recreating it. Phase A defines the `Workspace`
and `ExecutionRequest`/`ExecutionResult` contracts only.

## Consequences

- Neither the control-plane API nor the agent runtime spawns browsers or shells directly.
- Evidence capture belongs to the execution runtime, and the evidence is stored as artifacts.

## Source provenance

[Original decision at inspected commit](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/docs/adr/0007-separate-execution-runtime.md).

[Current architecture](../architecture/overview.md) · [ADR index](README.md)
