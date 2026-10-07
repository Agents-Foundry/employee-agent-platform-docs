# ADR 0005: Action Gateway for governed external actions

**Record type:** historical architecture decision imported from the product repository. Its original status/date and phase context are preserved. Use the current architecture and implementation matrix for today’s behavior; an accepted decision is not evidence that every described future capability exists.

- Status: Accepted (implemented in Phase D; see [ADR 0012](0012-action-gateway-execution.md))
- Date: 2026-09-23

## Context

MCP servers and connectors expose tools that can write to external systems. Letting an agent
call them directly would bypass organization policy, approval and audit.

## Decision

Governed operations are requested as semantic actions (`jira.issue.create`,
`repository.pull_request.create`, …) through a control-plane Action Gateway. It performs
authorization, deterministic policy evaluation, approval, secret resolution and audit before it
dispatches to a connector or the execution runtime. Results are `APPROVED`, `REQUIRES_APPROVAL`
or `DENIED`, with remediation. An exposed MCP tool never implies permission. LLMs never make the
final authorization decision.

## Consequences

- Connectors contain no organization authorization logic.
- If policy evaluation is unavailable, governed writes are denied.
- Phase A records approval links on runs so the gateway can later pause and resume them.

## Source provenance

[Original decision at inspected commit](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/docs/adr/0005-action-gateway.md).

[Current architecture](../architecture/overview.md) · [ADR index](README.md)
