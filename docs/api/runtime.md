# runtime API

**Audience:** API consumers and developers. **Implementation status:** Implemented (subject to route guards and feature flags).

**Prerequisites:** Read [HTTP conventions](README.md), sign in for browser API calls, or configure the signed workload identity for runtime calls.

This reference is extracted from route registrations at `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. Handler bindings below identify actual input validators, service calls and response expressions; referenced service schemas supply the full field bounds. Authentication middleware and service authorization still apply. See [request validators](request-schemas.md) and [wire contracts](contracts.md).

## Endpoints

| Method | Path | Access | Source |
| --- | --- | --- | --- |
| POST | `/runtime/v1/actions` | Agent workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L106) |
| POST | `/runtime/v1/actions/execute` | Agent workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L110) |
| POST | `/runtime/v1/actions/grant` | Agent workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L114) |
| PUT | `/runtime/v1/artifact-content/:token` | Execution workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L162) |
| POST | `/runtime/v1/artifacts` | Agent workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L144) |
| POST | `/runtime/v1/artifacts/execution` | Execution workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L148) |
| POST | `/runtime/v1/artifacts/execution/authorize` | Execution workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L155) |
| POST | `/runtime/v1/artifacts/execution/complete` | Execution workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L174) |
| POST | `/runtime/v1/checkpoints` | Agent workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L134) |
| POST | `/runtime/v1/checkpoints/load` | Agent workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L138) |
| POST | `/runtime/v1/commands/claim` | Agent workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L93) |
| POST | `/runtime/v1/credentials/redeem` | Execution workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L178) |
| POST | `/runtime/v1/credentials/release` | Execution workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L182) |
| POST | `/runtime/v1/events` | Agent workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L101) |
| POST | `/runtime/v1/heartbeat` | Agent workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L130) |
| POST | `/runtime/v1/models/credential` | Agent workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L122) |
| POST | `/runtime/v1/models/reserve` | Agent workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L118) |
| POST | `/runtime/v1/models/settle` | Agent workload signature | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L126) |

## POST /runtime/v1/actions

- **Authorization:** Agent workload signature.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const runtime = await authenticate(request);
    response.json(await transport.requestAction(runtime, json(request)));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L106).

## POST /runtime/v1/actions/execute

- **Authorization:** Agent workload signature.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const runtime = await authenticate(request);
    response.json(await transport.executeAction(runtime, json(request)));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L110).

## POST /runtime/v1/actions/grant

- **Authorization:** Agent workload signature.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const runtime = await authenticate(request);
    response.json(await transport.issueGrant(runtime, json(request)));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L114).

## PUT /runtime/v1/artifact-content/:token

- **Authorization:** Execution workload signature.
- **Parameters:** `token`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 204; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
      const runtime = await authenticateExecution(request);
      await artifacts.receiveDirectContent(
        runtime,
        String(request.params['token']),
        Buffer.isBuffer(request.body) ? request.body : Buffer.alloc(0),
      );
      response.status(204).end();
    }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L162).

## POST /runtime/v1/artifacts

- **Authorization:** Agent workload signature.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const runtime = await authenticate(request);
    response.status(201).json(await artifacts.uploadFromAgent(runtime, json(request)));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L144).

## POST /runtime/v1/artifacts/execution

- **Authorization:** Execution workload signature.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
      const runtime = await authenticateExecution(request);
      response.status(201).json(await artifacts.uploadFromExecution(runtime, json(request)));
    }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L148).

## POST /runtime/v1/artifacts/execution/authorize

- **Authorization:** Execution workload signature.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
      const runtime = await authenticateExecution(request);
      response.status(201).json(await artifacts.authorizeDirectUpload(runtime, json(request)));
    }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L155).

## POST /runtime/v1/artifacts/execution/complete

- **Authorization:** Execution workload signature.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const runtime = await authenticateExecution(request);
    response.status(201).json(await artifacts.completeDirectUpload(runtime, json(request)));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L174).

## POST /runtime/v1/checkpoints

- **Authorization:** Agent workload signature.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const runtime = await authenticate(request);
    response.status(201).json(await transport.saveCheckpoint(runtime, json(request)));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L134).

## POST /runtime/v1/checkpoints/load

- **Authorization:** Agent workload signature.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 204; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const runtime = await authenticate(request);
    const checkpoint = await transport.loadCheckpoint(runtime, json(request));
    if (!checkpoint) return response.status(204).end();
    return response.json(checkpoint);
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L138).

## POST /runtime/v1/commands/claim

- **Authorization:** Agent workload signature.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 204; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const runtime = await authenticate(request);
    // Runtimes poll here, so no scheduler is needed to expire credential leases (ADR 0031).
    await credentials.expireDue();
    const claim = await transport.claim(runtime);
    if (!claim) return response.status(204).end();
    return response.json(claim);
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L93).

## POST /runtime/v1/credentials/redeem

- **Authorization:** Execution workload signature.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const runtime = await authenticateExecution(request);
    response.json(await credentials.redeem(runtime, json(request)));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L178).

## POST /runtime/v1/credentials/release

- **Authorization:** Execution workload signature.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const runtime = await authenticateExecution(request);
    response.json(await credentials.release(runtime, json(request)));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L182).

## POST /runtime/v1/events

- **Authorization:** Agent workload signature.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const runtime = await authenticate(request);
    const ack = await transport.ingest(runtime, json(request));
    response.status(ack.duplicate ? 200 : 201).json(ack);
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L101).

## POST /runtime/v1/heartbeat

- **Authorization:** Agent workload signature.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const runtime = await authenticate(request);
    response.json(await transport.heartbeat(runtime, json(request)));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L130).

## POST /runtime/v1/models/credential

- **Authorization:** Agent workload signature.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const runtime = await authenticate(request);
    response.json(await transport.modelCredential(runtime, json(request)));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L122).

## POST /runtime/v1/models/reserve

- **Authorization:** Agent workload signature.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const runtime = await authenticate(request);
    response.json(await transport.reserveModelTokens(runtime, json(request)));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L118).

## POST /runtime/v1/models/settle

- **Authorization:** Agent workload signature.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const runtime = await authenticate(request);
    response.json(await transport.settleModelTokens(runtime, json(request)));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-routes.ts#L126).

## Related documentation

[HTTP conventions](README.md) · [Request schemas](request-schemas.md) · [Wire contracts](contracts.md) · [Source inventory](../reference/provenance.md)
