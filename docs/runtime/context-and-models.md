# Context construction and model invocation

**Audience:** Runtime developers, administrators. **Implementation status:** Partially Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

The implemented kernel is `native-v1`: a bounded model/tool loop, defaulting to 12 model turns and 4096 output tokens per turn. These are constructor defaults, not documented environment variables. Its checkpoint format is version 2 and contains messages, turns, artifact IDs and a pending tool turn.

The system prompt includes signed identity, skill IDs, available workflow IDs, the resolved workflow's ordered guidance, governance/secret instructions and assignment configuration. The initial user message includes the objective, optional workflow/work item and task inputs. Model completions append assistant blocks; tool results become user blocks. This is not a long-term memory engine.

Only tools both implemented in the registry and listed in the manifest are offered. With no `EXECUTION_RUNTIME_URL`, workspace/browser/build/edit/dependency tools are absent. An unknown tool fails with `TOOL_NOT_AVAILABLE`; invalid input produces `TOOL_INPUT_INVALID`. Tool requests are digested after validation, so approval binds the canonical validated payload.

## Model gateway

The manifest pins provider/model/profile and credential mode. The shipped live provider is Anthropic over HTTPS; the optional scripted provider is deterministic test/demo behavior. Missing providers fail `MODEL_PROVIDER_UNAVAILABLE`. Organization credentials are obtained per call from the control plane; employee BYOK fails closed. An operator-environment fallback is opt-in development behavior.

The host reserves tokens/cost before a model call. Estimated input uses approximately three characters per token across system, messages and tools; actual usage is settled afterwards. A denial produces `MODEL_BUDGET_EXCEEDED` before the provider is called. An uncertain call remains charged at its reservation. A failed settlement does not free budget or pretend the completed provider call never happened.

## Implementation Status / Architecture Gap

There is no streaming response protocol, token-by-token UI, context condensation, vector store, memory provider, multi-provider routing policy or executable Skill Runtime. `memory`, `knowledge`, `persona` and skill version fields describe configuration; their presence is not evidence that all corresponding engines execute. The kernel currently places skill IDs, not the full skill instruction bodies, in its prompt. Add bounded context management before claiming unbounded conversational continuity.

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/agent-runtime/src/kernel/native-kernel.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/agent-runtime/src/kernel/native-kernel.ts)
- [apps/agent-runtime/src/models/model-gateway.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/agent-runtime/src/models/model-gateway.ts)
- [apps/agent-runtime/src/models/anthropic-provider.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/agent-runtime/src/models/anthropic-provider.ts)
- [apps/agent-runtime/src/main.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/agent-runtime/src/main.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
