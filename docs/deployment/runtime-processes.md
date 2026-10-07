# Running the agent and execution processes

**Audience:** Operators, runtime developers. **Implementation status:** Partially Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

These are local process setup instructions derived from shipped scripts. Production process supervision, certificates and workload-key distribution are deployment responsibilities.

1. Create an Ed25519 key with `npm run keygen --workspace @agents-foundry/agent-runtime -- ../../.data/runtime-key.pem`. The path is relative to the workspace working directory. Save its printed public SPKI in the operator registry; protect the private file.
2. Create a separate execution identity key with the same keygen command and a different output path. Register both in the JSON file named by `AGENT_RUNTIME_IDENTITIES_PATH`. Set `role` to `agent` and `execution` respectively, use explicit tenant IDs and `runtimeProfiles: ["standard-agent"]`. Wildcard tenant registration is an explicit shared-runtime trust decision, not a recommended pilot default.
3. Fetch `/api/manifest-key` as an authenticated actor, then distribute and independently pin `publicKeySpki` as `MANIFEST_VERIFICATION_KEY` for the agent and `EXECUTION_GRANT_VERIFICATION_KEY` for the execution runtime. Do not fetch-and-trust it from an unverified network endpoint on every operation.
4. Configure the agent process with `CONTROL_PLANE_URL`, `AGENT_RUNTIME_ID`, `AGENT_RUNTIME_PRIVATE_KEY_PATH`, `MANIFEST_VERIFICATION_KEY` and `EXECUTION_RUNTIME_URL`. Start using `npm run dev:runtime` locally.
5. Configure execution with the grant verification key, state directory, provider and optional signed control-plane identity (`EXECUTION_RUNTIME_ID`, `EXECUTION_RUNTIME_KEY_PATH`, `EXECUTION_CONTROL_PLANE_URL`). Start using `npm run dev:execution`. Loopback port 4500 is its default.

Agent defaults: polling every 2000 ms, concurrency 4, heartbeat every 30000 ms, control-plane checkpoints and artifact store. See the [configuration inventory](../reference/configuration.md) for bounds and all source locations.

## Sandbox selection

The execution default is `local`, which does not enforce CPU/memory/PID/network isolation and refuses a sandbox-required manifest. For pilot repository-code execution choose `EXECUTION_PROVIDER=container`, set `EXECUTION_SANDBOX_IMAGE`, prebuild/pull the intended images and keep the egress proxy enabled. `EXECUTION_PLAYWRIGHT_IMAGE` can select a separate browser image. The supplied Playwright Dockerfile is a sandbox image, not a complete product deployment image.

Development bypasses (`EXECUTION_ALLOW_UNSANDBOXED`, `EXECUTION_ALLOW_UNRESTRICTED_EGRESS`, file-repository opt-in, environment model keys) must remain unset in a controlled pilot. Configure durable state per execution instance; its single-use grants and workspace records rely on this state. Do not place the SQLite state database on arbitrary shared/network filesystems and claim distributed execution safety.

## Implementation Status / Architecture Gap

No service unit, container stack, autoscaler or cloud deployment template is shipped. The execution endpoint authorizes through a grant and binds loopback by default; non-loopback exposure requires a private authenticated transport boundary supplied by deployment. Test live Vault, object storage and telemetry before accepting a pilot.

## Source provenance

Reviewed against platform commit `d2bc8d7fa3fc185cc4f487bdaa1f11611844763f`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/agent-runtime/src/config.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/agent-runtime/src/config.ts)
- [apps/agent-runtime/src/keygen.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/agent-runtime/src/keygen.ts)
- [apps/agent-runtime/src/main.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/agent-runtime/src/main.ts)
- [apps/execution-runtime/src/main.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/execution-runtime/src/main.ts)
- [apps/execution-runtime/src/credential-client.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/execution-runtime/src/credential-client.ts)
- [apps/control-plane-api/src/runtime/runtime-identity.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/runtime/runtime-identity.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
