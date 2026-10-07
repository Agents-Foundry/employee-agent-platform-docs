# Glossary and naming distinctions

**Audience:** All readers. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

| Term | Meaning in this implementation |
| --- | --- |
| Agent blueprint/version | Declarative global role definition with exact dependency pins |
| Agent installation | Tenant-specific shared answers applied to future instances |
| Assigned agent | One employee's instance with immutable signed configuration |
| Manifest | Resolved signed instance configuration; neither raw role package nor raw secret |
| Organization role | Job architecture; does not confer API authorization |
| Security role | ADMIN or EMPLOYEE on active membership |
| Thread | Durable context hosting multiple task invocations |
| Run | One invocation with an explicit state machine |
| Step | Ordered logical unit of a run |
| Runtime event | Append-only product execution history; not security audit or model token streaming |
| Skill | Versioned catalog guidance and requirements; not executable code |
| Tool | Definition plus runtime implementation, narrowed by manifest |
| Connector | Provider adapter behind control-plane authorization |
| MCP | Declarative server identifiers; no implemented client |
| Action Gateway | Policy, approval and single-use execution/grant authority |
| Approval | Human decision bound to a payload and expiry, not blanket permission |
| Grant | Signed one-operation execution authority with digest, limits and expiry |
| Credential lease | One-use bounded authorization for execution runtime checkout credentials |
| Artifact | Verified run evidence metadata and stored bytes with retention |
| Checkpoint | Private bound kernel state for recovery, not a reusable permission |
| BYOK | Employee-held credential mode; current server execution refuses it |
| Controlled pilot | Deployment whose named proofs and accepted limits were assessed; not a production certification |

## Source provenance

Reviewed against platform commit `d2bc8d7fa3fc185cc4f487bdaa1f11611844763f`. These references support the behavior described; types alone are not evidence that a capability executes.

- [packages/contracts/src/catalog.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog.ts)
- [packages/contracts/src/execution.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution.ts)
- [packages/contracts/src/manifest-v2.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/manifest-v2.ts)
- [packages/contracts/src/actions.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/actions.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](implementation-status.md)
