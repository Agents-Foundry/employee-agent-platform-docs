# catalog API

**Audience:** API consumers and developers. **Implementation status:** Implemented (subject to route guards and feature flags).

**Prerequisites:** Read [HTTP conventions](README.md), sign in for browser API calls, or configure the signed workload identity for runtime calls.

This reference is extracted from route registrations at `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. Handler bindings below identify actual input validators, service calls and response expressions; referenced service schemas supply the full field bounds. Authentication middleware and service authorization still apply. See [request validators](request-schemas.md) and [wire contracts](contracts.md).

## Endpoints

| Method | Path | Access | Source |
| --- | --- | --- | --- |
| GET | `/api/catalog/v1/blueprints` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/catalog/catalog-routes.ts#L20) |
| GET | `/api/catalog/v1/blueprints/:id/versions/:version` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/catalog/catalog-routes.ts#L21) |
| GET | `/api/catalog/v1/quality` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/catalog/catalog-routes.ts#L25) |
| GET | `/api/organization/agent-installations` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/catalog/catalog-routes.ts#L38) |
| POST | `/api/organization/agent-installations` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/catalog/catalog-routes.ts#L41) |
| PUT | `/api/organization/agent-installations/:id` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/catalog/catalog-routes.ts#L44) |
| POST | `/api/organization/agent-installations/:id/retire` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/catalog/catalog-routes.ts#L47) |

## GET /api/catalog/v1/blueprints

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_req, res) => res.json(await catalog.summaries())
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/catalog/catalog-routes.ts#L20).

## GET /api/catalog/v1/blueprints/:id/versions/:version

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** `id`, `version`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await catalog.bundle(String(req.params['id']), String(req.params['version']), 404))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/catalog/catalog-routes.ts#L21).

## GET /api/catalog/v1/quality

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await quality.overview(res.locals['actor'], req.query))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/catalog/catalog-routes.ts#L25).

## GET /api/organization/agent-installations

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await installations.list(res.locals['actor'], req.query))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/catalog/catalog-routes.ts#L38).

## POST /api/organization/agent-installations

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.status(201).json(await installations.create(res.locals['actor'], req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/catalog/catalog-routes.ts#L41).

## PUT /api/organization/agent-installations/:id

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await installations.update(res.locals['actor'], String(req.params['id']), req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/catalog/catalog-routes.ts#L44).

## POST /api/organization/agent-installations/:id/retire

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    const { version } = z.object({ version: z.number().int().positive() }).strict().parse(req.body);
    res.json(await installations.retire(res.locals['actor'], String(req.params['id']), version));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/catalog/catalog-routes.ts#L47).

## Related documentation

[HTTP conventions](README.md) · [Request schemas](request-schemas.md) · [Wire contracts](contracts.md) · [Source inventory](../reference/provenance.md)
