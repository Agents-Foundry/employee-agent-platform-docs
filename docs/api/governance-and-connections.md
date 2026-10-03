# governance and connections API

**Audience:** API consumers and developers. **Implementation status:** Implemented (subject to route guards and feature flags).

**Prerequisites:** Read [HTTP conventions](README.md), sign in for browser API calls, or configure the signed workload identity for runtime calls.

This reference is extracted from route registrations at `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. Handler bindings below identify actual input validators, service calls and response expressions; referenced service schemas supply the full field bounds. Authentication middleware and service authorization still apply. See [request validators](request-schemas.md) and [wire contracts](contracts.md).

## Endpoints

| Method | Path | Access | Source |
| --- | --- | --- | --- |
| GET | `/api/organization/action-policies` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-routes.ts#L44) |
| DELETE | `/api/organization/action-policies/:action` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-routes.ts#L50) |
| PUT | `/api/organization/action-policies/:action` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-routes.ts#L45) |
| GET | `/api/organization/action-reconciliations` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-routes.ts#L57) |
| POST | `/api/organization/action-reconciliations/:requestId/resolution` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-routes.ts#L60) |
| GET | `/api/organization/connector-connections` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-routes.ts#L34) |
| POST | `/api/organization/connector-connections` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-routes.ts#L35) |
| POST | `/api/organization/connector-connections/:id/disable` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-routes.ts#L38) |
| GET | `/api/organization/credential-leases` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/credentials/credential-routes.ts#L43) |
| POST | `/api/organization/credential-leases/:id/revoke` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/credentials/credential-routes.ts#L44) |
| GET | `/api/organization/source-control-connections` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/credentials/credential-routes.ts#L31) |
| POST | `/api/organization/source-control-connections` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/credentials/credential-routes.ts#L34) |
| POST | `/api/organization/source-control-connections/:id/disable` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/credentials/credential-routes.ts#L37) |

## GET /api/organization/action-policies

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_req, res) => res.json(await policies.list(res.locals['actor']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-routes.ts#L44).

## DELETE /api/organization/action-policies/:action

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `action`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 204; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** `actionParam(req.params['action'])`.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    await policies.clear(res.locals['actor'], actionParam.parse(req.params['action']));
    res.status(204).end();
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-routes.ts#L50).

## PUT /api/organization/action-policies/:action

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `action`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** `actionParam(req.params['action'])`.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(
      await policies.set(res.locals['actor'], actionParam.parse(req.params['action']), req.body),
    )
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-routes.ts#L45).

## GET /api/organization/action-reconciliations

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_req, res) =>
    res.json(await reconciliations.list(res.locals['actor']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-routes.ts#L57).

## POST /api/organization/action-reconciliations/:requestId/resolution

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `requestId`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(
      await reconciliations.resolve(
        res.locals['actor'],
        z.uuid().parse(req.params['requestId']),
        req.body,
      ),
    )
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-routes.ts#L60).

## GET /api/organization/connector-connections

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_req, res) => res.json(await connectors.list(res.locals['actor']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-routes.ts#L34).

## POST /api/organization/connector-connections

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.status(201).json(await connectors.create(res.locals['actor'], req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-routes.ts#L35).

## POST /api/organization/connector-connections/:id/disable

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    const { version } = z.object({ version: z.number().int().positive() }).strict().parse(req.body);
    res.json(await connectors.disable(res.locals['actor'], String(req.params['id']), version));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-routes.ts#L38).

## GET /api/organization/credential-leases

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_req, res) => res.json(await credentials.list(res.locals['actor']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/credentials/credential-routes.ts#L43).

## POST /api/organization/credential-leases/:id/revoke

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await credentials.revoke(res.locals['actor'], z.uuid().parse(req.params['id'])))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/credentials/credential-routes.ts#L44).

## GET /api/organization/source-control-connections

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_req, res) =>
    res.json(await connections.list(res.locals['actor']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/credentials/credential-routes.ts#L31).

## POST /api/organization/source-control-connections

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.status(201).json(await connections.create(res.locals['actor'], req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/credentials/credential-routes.ts#L34).

## POST /api/organization/source-control-connections/:id/disable

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    const { version } = z.object({ version: z.number().int().positive() }).strict().parse(req.body);
    res.json(await connections.disable(res.locals['actor'], String(req.params['id']), version));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/credentials/credential-routes.ts#L37).

## Related documentation

[HTTP conventions](README.md) · [Request schemas](request-schemas.md) · [Wire contracts](contracts.md) · [Source inventory](../reference/provenance.md)
