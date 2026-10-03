# execution server API

**Audience:** API consumers and developers. **Implementation status:** Implemented (subject to route guards and feature flags).

**Prerequisites:** Read [HTTP conventions](README.md), sign in for browser API calls, or configure the signed workload identity for runtime calls.

This reference is extracted from route registrations at `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. Handler bindings below identify actual input validators, service calls and response expressions; referenced service schemas supply the full field bounds. Authentication middleware and service authorization still apply. See [request validators](request-schemas.md) and [wire contracts](contracts.md).

## Endpoints

| Method | Path | Access | Source |
| --- | --- | --- | --- |
| GET | `/execution/v1/health` | Private service network; public health within that boundary | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/execution-runtime/src/server.ts#L1) |
| POST | `/execution/v1/operations` | Control-plane-signed single-use grant; private service network | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/execution-runtime/src/server.ts#L1) |
| GET | `/metrics` | Operator bearer token; conditional route | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/execution-runtime/src/server.ts#L1) |

## GET /execution/v1/health

- **Authorization:** Private service network; public health within that boundary.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
Health returns { status, provider, isolation, enforces }.
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/execution-runtime/src/server.ts#L1).

## POST /execution/v1/operations

- **Authorization:** Control-plane-signed single-use grant; private service network.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200, 400, 413, 415; shared middleware/service errors also apply.
- **Handler-local error codes:** `REQUEST_INVALID`, `REQUEST_TOO_LARGE`, `JSON_REQUIRED`, `EXECUTION_RUNTIME_ERROR`.
- **Input validators:** `parseExecutionRequest`.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
Request: { protocol: 'agents-foundry/execution/v1', grant, operation }. Response: ExecuteOperationResponse; result.status is SUCCEEDED | FAILED | TIMED_OUT | DENIED. HTTP 200 does not imply operation success.
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/execution-runtime/src/server.ts#L1).

## GET /metrics

- **Authorization:** Operator bearer token; conditional route.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200, 401; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
Exists only with execution metrics configuration. Response is Prometheus text, not JSON.
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/execution-runtime/src/server.ts#L1).

## Related documentation

[HTTP conventions](README.md) · [Request schemas](request-schemas.md) · [Wire contracts](contracts.md) · [Source inventory](../reference/provenance.md)
