# ADR 0004: Agent Manifest v2

**Record type:** historical architecture decision imported from the product repository. Its original status/date and phase context are preserved. Use the current architecture and implementation matrix for today’s behavior; an accepted decision is not evidence that every described future capability exists.

- Status: Accepted
- Date: 2026-09-23

## Context

Manifest v1 (`agents-foundry/v1`) embeds QA questionnaire answers and a flat capability list.
The runtime needs a fully resolved, role-independent configuration: persona, runtime profile,
model profile, skills, tools, connectors, MCP, memory, knowledge, policies, workflows and
evaluations.

## Decision

Define `apiVersion: agents-foundry/v2`, `kind: AgentManifest`
(`packages/contracts/src/manifest-v2.ts`, strict Zod schema in `runtime/v1/schemas.ts`).
Signing is unchanged: Ed25519 over the same canonical JSON, with the same key and key-id
derivation. v1 manifests remain valid and are never re-signed or mutated. v2 issuance is gated
by `AGENT_MANIFEST_V2_ISSUANCE_ENABLED` until the second role validates the shape. Verifiers
dispatch on `apiVersion`; unknown versions fail closed.

## Consequences

- Clients support both versions during migration (the desktop verifier is updated).
- A blueprint upgrade issues a new manifest for a new agent instance; it never edits an active one.
- The v2 schema is strict; unknown sections are rejected rather than ignored.

## Source provenance

[Original decision at inspected commit](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/docs/adr/0004-agent-manifest-v2.md).

[Current architecture](../architecture/overview.md) · [ADR index](README.md)
