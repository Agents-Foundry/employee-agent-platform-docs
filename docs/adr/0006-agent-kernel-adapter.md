# ADR 0006: Agent kernel adapter boundary

**Record type:** historical architecture decision imported from the product repository. Its original status/date and phase context are preserved. Use the current architecture and implementation matrix for today’s behavior; an accepted decision is not evidence that every described future capability exists.

- Status: Accepted (implemented in Phase C: `apps/agent-runtime/src/kernel`, `NativeKernel`)
- Date: 2026-09-23

## Context

Open-source agent SDKs, such as the OpenHands Software Agent SDK, offer mature reasoning loops,
event models and confirmation pauses. Coupling platform contracts to one of them would make the
platform a front end for that project and block replacement.

## Decision

The runtime hosts an `AgentKernel` interface. Kernels (`OpenHandsKernel`, a future custom kernel
and so on) translate between their internal events and `agents-foundry/runtime/v1`.
Control-plane contracts never reference kernel types. Any reuse of kernel code follows
`docs/third-party-code.md`.

## Consequences

- Swapping kernels does not change control-plane APIs or stored run history.
- Some kernel features stay unreachable until they are expressed in the protocol. That is intentional.

## Source provenance

[Original decision at inspected commit](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/docs/adr/0006-agent-kernel-adapter.md).

[Current architecture](../architecture/overview.md) · [ADR index](README.md)
