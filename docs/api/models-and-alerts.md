# models and alerts API

**Audience:** API consumers and developers. **Implementation status:** Implemented (subject to route guards and feature flags).

**Prerequisites:** Read [HTTP conventions](README.md), sign in for browser API calls, or configure the signed workload identity for runtime calls.

This reference is extracted from route registrations at `d2bc8d7fa3fc185cc4f487bdaa1f11611844763f`. Handler bindings below identify actual input validators, service calls and response expressions; referenced service schemas supply the full field bounds. Authentication middleware and service authorization still apply. See [request validators](request-schemas.md) and [wire contracts](contracts.md).

## Endpoints

| Method | Path | Access | Source |
| --- | --- | --- | --- |
| GET | `/api/organization/alert-webhooks` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/webhooks/webhook-routes.ts#L23) |
| POST | `/api/organization/alert-webhooks` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/webhooks/webhook-routes.ts#L24) |
| PUT | `/api/organization/alert-webhooks/:webhookId` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/webhooks/webhook-routes.ts#L27) |
| POST | `/api/organization/alert-webhooks/:webhookId/test` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/webhooks/webhook-routes.ts#L30) |
| GET | `/api/organization/model-alerts` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/spending-routes.ts#L43) |
| POST | `/api/organization/model-alerts/:alertId/acknowledge` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/spending-routes.ts#L46) |
| GET | `/api/organization/model-budget` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/spending-routes.ts#L24) |
| PUT | `/api/organization/model-budget` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/spending-routes.ts#L27) |
| GET | `/api/organization/model-credentials` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/secrets/model-credential-routes.ts#L23) |
| PUT | `/api/organization/model-credentials/:provider` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/secrets/model-credential-routes.ts#L24) |
| POST | `/api/organization/model-credentials/:provider/disable` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/secrets/model-credential-routes.ts#L27) |
| GET | `/api/organization/model-prices` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/spending-routes.ts#L33) |
| PUT | `/api/organization/model-prices` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/spending-routes.ts#L36) |
| POST | `/api/organization/model-prices/remove` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/spending-routes.ts#L39) |
| GET | `/api/organization/model-usage` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/spending-routes.ts#L30) |

## GET /api/organization/alert-webhooks

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_req, res) => res.json(await webhooks.list(res.locals['actor']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/webhooks/webhook-routes.ts#L23).

## POST /api/organization/alert-webhooks

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.status(201).json(await webhooks.create(res.locals['actor'], req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/webhooks/webhook-routes.ts#L24).

## PUT /api/organization/alert-webhooks/:webhookId

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `webhookId`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await webhooks.setStatus(res.locals['actor'], req.params['webhookId'], req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/webhooks/webhook-routes.ts#L27).

## POST /api/organization/alert-webhooks/:webhookId/test

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `webhookId`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 202; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.status(202).json(await webhooks.test(res.locals['actor'], req.params['webhookId']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/webhooks/webhook-routes.ts#L30).

## GET /api/organization/model-alerts

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await spending.alerts.list(res.locals['actor'], req.query))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/spending-routes.ts#L43).

## POST /api/organization/model-alerts/:alertId/acknowledge

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `alertId`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await spending.alerts.acknowledge(res.locals['actor'], req.params['alertId']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/spending-routes.ts#L46).

## GET /api/organization/model-budget

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_req, res) =>
    res.json(await spending.getBudget(res.locals['actor']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/spending-routes.ts#L24).

## PUT /api/organization/model-budget

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await spending.setBudget(res.locals['actor'], req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/spending-routes.ts#L27).

## GET /api/organization/model-credentials

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_req, res) => res.json(await service.list(res.locals['actor']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/secrets/model-credential-routes.ts#L23).

## PUT /api/organization/model-credentials/:provider

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `provider`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await service.set(res.locals['actor'], String(req.params['provider']), req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/secrets/model-credential-routes.ts#L24).

## POST /api/organization/model-credentials/:provider/disable

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `provider`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    const { version } = z.object({ version: z.number().int().positive() }).strict().parse(req.body);
    res.json(await service.disable(res.locals['actor'], String(req.params['provider']), version));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/secrets/model-credential-routes.ts#L27).

## GET /api/organization/model-prices

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_req, res) =>
    res.json(await spending.prices.list(res.locals['actor']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/spending-routes.ts#L33).

## PUT /api/organization/model-prices

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await spending.prices.set(res.locals['actor'], req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/spending-routes.ts#L36).

## POST /api/organization/model-prices/remove

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 204; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    await spending.prices.remove(res.locals['actor'], req.body);
    res.status(204).end();
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/spending-routes.ts#L39).

## GET /api/organization/model-usage

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await spending.usage(res.locals['actor'], req.query))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/spending-routes.ts#L30).

## Related documentation

[HTTP conventions](README.md) · [Request schemas](request-schemas.md) · [Wire contracts](contracts.md) · [Source inventory](../reference/provenance.md)
