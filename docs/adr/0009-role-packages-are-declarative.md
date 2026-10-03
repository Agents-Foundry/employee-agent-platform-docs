# ADR 0009: Role packages are declarative expertise

**Record type:** historical architecture decision imported from the product repository. Its original status/date and phase context are preserved. Use the current architecture and implementation matrix for today’s behavior; an accepted decision is not evidence that every described future capability exists.

- Status: Accepted; validated in Phase G by the Frontend Engineer (ADR 0015)
- Date: 2026-09-23

## Context

The platform must support many employee roles without a runtime per role.

## Decision

A role package (for example `qa-engineer-agent`) contains only declarative expertise: the agent
definition, persona, prompts, responsibilities, skills, workflows, required tools and
connectors, default policy and evaluations. The generic runtime interprets it. The runtime,
control plane and execution runtime must not branch on role identity (`if role === 'qa'`);
role behaviour belongs in manifests, skills and workflows. Organizational job roles never grant
application security permissions.

## Consequences

- Phase A's QA compatibility adapter was replaced in Phase B by declarative catalog data and a
  generic resolver. A test adds a second role purely as data (see `docs/agent-catalog.md`).
- The Frontend Engineer role (Phase G) is the acceptance test for this ADR.

## Source provenance

[Original decision at inspected commit](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/docs/adr/0009-role-packages-are-declarative.md).

[Current architecture](../architecture/overview.md) · [ADR index](README.md)
