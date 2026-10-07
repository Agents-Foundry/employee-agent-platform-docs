# ADR 0003: Generic AgentRun replaces role-specific run architecture

**Record type:** historical architecture decision imported from the product repository. Its original status/date and phase context are preserved. Use the current architecture and implementation matrix for today’s behavior; an accepted decision is not evidence that every described future capability exists.

- Status: Accepted
- Date: 2026-09-23

## Context

`QaRun`, `qa_runs` and `/api/qa/runs` hard-code the QA role: a six-string plan and one approval
action. Adding a second role this way would duplicate types, tables and routes for every role.

## Decision

Introduce role-independent `Thread`, `AgentRun`, `RunStep`, `AgentEvent` and `Artifact`
(contracts in `packages/contracts/src/execution.ts`, tables in migration 006). The QA route
dual-writes a generic run in the same transaction and links it through
`agent_runs.legacy_qa_run_id`. `QaRun*` types are marked legacy and remain until the QA role runs
through the generic runtime (Phase F).

## Consequences

- No new role may add a role-specific run table, type or route.
- Legacy QA responses stay compatible while clients migrate to `/api/execution/v1`.
- Two records exist per QA run during migration; the legacy row stays authoritative for legacy fields.

## Source provenance

[Original decision at inspected commit](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/docs/adr/0003-generic-agent-run.md).

[Current architecture](../architecture/overview.md) · [ADR index](README.md)
