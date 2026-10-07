# organization API

**Audience:** API consumers and developers. **Implementation status:** Implemented (subject to route guards and feature flags).

**Prerequisites:** Read [HTTP conventions](README.md), sign in for browser API calls, or configure the signed workload identity for runtime calls.

This reference is extracted from route registrations at `d2bc8d7fa3fc185cc4f487bdaa1f11611844763f`. Handler bindings below identify actual input validators, service calls and response expressions; referenced service schemas supply the full field bounds. Authentication middleware and service authorization still apply. See [request validators](request-schemas.md) and [wire contracts](contracts.md).

## Endpoints

| Method | Path | Access | Source |
| --- | --- | --- | --- |
| GET | `/api/organization/agents` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/app.ts#L209) |
| POST | `/api/organization/agents` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/app.ts#L215) |
| GET | `/api/organization/domains` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L27) |
| POST | `/api/organization/domains` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L30) |
| POST | `/api/organization/domains/:id/primary` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L36) |
| POST | `/api/organization/domains/:id/verify` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L33) |
| GET | `/api/organization/employees` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L39) |
| POST | `/api/organization/employees` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L42) |
| PUT | `/api/organization/employees/:id` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L45) |
| POST | `/api/organization/employees/:id/invitation` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L51) |
| PUT | `/api/organization/employees/:id/position` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L48) |
| POST | `/api/organization/invitations` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization-routes.ts#L43) |
| GET | `/api/organization/jobs/:kind` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/job-routes.ts#L18) |
| POST | `/api/organization/jobs/:kind` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/job-routes.ts#L21) |
| PUT | `/api/organization/jobs/:kind/:id` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/job-routes.ts#L24) |
| POST | `/api/organization/jobs/:kind/:id/archive` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/job-routes.ts#L29) |
| GET | `/api/organization/members` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization-routes.ts#L40) |
| POST | `/api/organization/members/:id/disable` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization-routes.ts#L67) |
| POST | `/api/organization/members/:id/recovery-link` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization-routes.ts#L79) |
| GET | `/api/organization/memberships` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L73) |
| PUT | `/api/organization/memberships/:id/status` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L76) |
| GET | `/api/organization/profile` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L20) |
| PUT | `/api/organization/profile` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L24) |
| GET | `/api/organization/setup-progress` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L21) |
| GET | `/api/organization/units` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L19) |
| POST | `/api/organization/units` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L23) |
| PUT | `/api/organization/units/:id` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L35) |
| GET | `/api/organization/units/:id/ancestors` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L26) |
| POST | `/api/organization/units/:id/archive` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L38) |
| PUT | `/api/organization/units/:id/head` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L32) |
| GET | `/api/organization/units/:id/head-position-options` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L29) |
| GET | `/api/organization/units/:id/members` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L43) |
| POST | `/api/organization/units/:id/members` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L46) |
| DELETE | `/api/organization/units/:id/members/:membershipId` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L50) |
| GET | `/api/organization/units/employee-options` | Password-mode organization admin; service authorization | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L20) |

## GET /api/organization/agents

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 403; shared middleware/service errors also apply.
- **Handler-local error codes:** `ADMIN_ROLE_REQUIRED`.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_request, response) => {
    const actor = response.locals['actor'];
    if (auth.mode !== 'password' || actor.role !== 'ADMIN')
      return response.status(403).json({ error: 'ADMIN_ROLE_REQUIRED' });
    return response.json(await database.listAgentAssignments(actor.organizationId));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/app.ts#L209).

## POST /api/organization/agents

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 403, 201, 409; shared middleware/service errors also apply.
- **Handler-local error codes:** `ADMIN_ROLE_REQUIRED`, `IDEMPOTENCY_CONFLICT`.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const actor = response.locals['actor'];
    if (auth.mode !== 'password' || actor.role !== 'ADMIN')
      return response.status(403).json({ error: 'ADMIN_ROLE_REQUIRED' });
    const input = provisioningSchema
      .extend({
        requestId: z.string().uuid(),
        installationId: z.string().uuid().optional(),
        name: z.string().trim().min(1).max(120),
        employeeIds: z
          .array(z.string().uuid())
          .min(1)
          .max(25)
          .refine((ids) => new Set(ids).size === ids.length)
          .transform((ids) => ids.sort()),
      })
      .strict()
      .parse(request.body);
    try {
      return response.status(201).json(await database.createAssignedAgents(actor, input));
    } catch (error) {
      if (error instanceof Error && error.message === 'IDEMPOTENCY_CONFLICT')
        return response.status(409).json({ error: 'IDEMPOTENCY_CONFLICT' });
      throw error;
    }
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/app.ts#L215).

## GET /api/organization/domains

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_req, res) =>
    res.json(await service.listDomains(res.locals['actor']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L27).

## POST /api/organization/domains

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.status(201).json(await service.registerDomain(res.locals['actor'], req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L30).

## POST /api/organization/domains/:id/primary

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await service.setPrimaryDomain(res.locals['actor'], req.params['id']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L36).

## POST /api/organization/domains/:id/verify

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await service.verifyDomain(res.locals['actor'], req.params['id']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L33).

## GET /api/organization/employees

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await service.listEmployees(res.locals['actor'], req.query))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L39).

## POST /api/organization/employees

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.status(201).json(await service.createEmployee(res.locals['actor'], req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L42).

## PUT /api/organization/employees/:id

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await service.updateEmployee(res.locals['actor'], req.params['id'], req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L45).

## POST /api/organization/employees/:id/invitation

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201, 409; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    try {
      const result = await db.inviteExistingEmployee(res.locals['actor'], req.params['id']);
      if (config.mode !== 'password') return;
      res.status(201).json({
        employeeId: result.employeeId,
        expiresAt: result.expiresAt,
        activationUrl: activationUrl(config.employeeUrl, result.token, result.purpose),
        purpose: result.purpose,
        delivery: 'MANUAL',
      });
    } catch (error) {
      if (
        error instanceof Error &&
        ['ACCOUNT_NOT_ACTIVE', 'MEMBER_ALREADY_EXISTS'].includes(error.message)
      ) {
        res.status(409).json({ error: error.message });
        return;
      }
      throw error;
    }
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L51).

## PUT /api/organization/employees/:id/position

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await service.assignPosition(res.locals['actor'], req.params['id'], req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L48).

## POST /api/organization/invitations

- **Authorization:** Password-mode organization admin; service authorization; route middleware: `admin`.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201, 409; shared middleware/service errors also apply.
- **Handler-local error codes:** `EMAIL_UNAVAILABLE`, `ACCOUNT_NOT_ACTIVE`.
- **Input validators:** `memberInput(req.body)`.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    if (config.mode !== 'password') return;
    const input = memberInput.parse(req.body);
    try {
      const invitation = await db.inviteEmployee(res.locals['actor'], input);
      res.status(201).json({
        employeeId: invitation.employeeId,
        expiresAt: invitation.expiresAt,
        activationUrl: activationUrl(config.employeeUrl, invitation.token, invitation.purpose),
        purpose: invitation.purpose,
        delivery: 'MANUAL',
      });
    } catch (error) {
      if (error instanceof Error && error.message === 'MEMBER_ALREADY_EXISTS') {
        res.status(409).json({ error: 'EMAIL_UNAVAILABLE' });
        return;
      }
      if (error instanceof Error && error.message === 'ACCOUNT_NOT_ACTIVE') {
        res.status(409).json({ error: 'ACCOUNT_NOT_ACTIVE' });
        return;
      }
      throw error;
    }
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization-routes.ts#L43).

## GET /api/organization/jobs/:kind

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `kind`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await service.list(res.locals['actor'], req.params['kind'], req.query))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/job-routes.ts#L18).

## POST /api/organization/jobs/:kind

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `kind`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.status(201).json(await service.save(res.locals['actor'], req.params['kind'], req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/job-routes.ts#L21).

## PUT /api/organization/jobs/:kind/:id

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `kind`, `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(
      await service.save(res.locals['actor'], req.params['kind'], req.body, req.params['id']),
    )
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/job-routes.ts#L24).

## POST /api/organization/jobs/:kind/:id/archive

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `kind`, `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 204; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    const { version } = z.object({ version: z.number().int().positive() }).strict().parse(req.body);
    await service.archive(res.locals['actor'], req.params['kind'], req.params['id'], version);
    res.status(204).end();
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/job-routes.ts#L29).

## GET /api/organization/members

- **Authorization:** Password-mode organization admin; service authorization; route middleware: `admin`.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_req, res) =>
    res.json(await db.listMembers(res.locals['actor'].organizationId))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization-routes.ts#L40).

## POST /api/organization/members/:id/disable

- **Authorization:** Password-mode organization admin; service authorization; route middleware: `admin`.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 204; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    await db.disableMember(res.locals['actor'], z.string().uuid().parse(req.params['id']));
    res.status(204).end();
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization-routes.ts#L67).

## POST /api/organization/members/:id/recovery-link

- **Authorization:** Password-mode organization admin; service authorization; route middleware: `admin`, `linkLimit`.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201, 409; shared middleware/service errors also apply.
- **Handler-local error codes:** `RECOVERY_STATE_CONFLICT`.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    if (config.mode !== 'password') return;
    const { purpose } = z
      .object({ purpose: z.enum(['activate', 'reset']) })
      .strict()
      .parse(req.body);
    const id = z.string().uuid().parse(req.params['id']);
    try {
      const result = await db.issueEmployeeLink(res.locals['actor'], id, purpose);
      res.status(201).json({
        employeeId: id,
        purpose,
        expiresAt: result.expiresAt,
        activationUrl: activationUrl(config.employeeUrl, result.token, purpose),
        delivery: 'MANUAL',
      });
    } catch (error) {
      if (error instanceof Error && error.message === 'RECOVERY_STATE_CONFLICT') {
        res.status(409).json({ error: 'RECOVERY_STATE_CONFLICT' });
        return;
      }
      throw error;
    }
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization-routes.ts#L79).

## GET /api/organization/memberships

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await service.listMemberships(res.locals['actor'], req.query))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L73).

## PUT /api/organization/memberships/:id/status

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await service.setMembershipStatus(res.locals['actor'], req.params['id'], req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L76).

## GET /api/organization/profile

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_req, res) => res.json(await service.profile(res.locals['actor']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L20).

## PUT /api/organization/profile

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await service.updateProfile(res.locals['actor'], req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L24).

## GET /api/organization/setup-progress

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_req, res) =>
    res.json(await service.setupProgress(res.locals['actor']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts#L21).

## GET /api/organization/units

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => res.json(await service.list(res.locals['actor'], req.query))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L19).

## POST /api/organization/units

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.status(201).json(await service.save(res.locals['actor'], req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L23).

## PUT /api/organization/units/:id

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await service.save(res.locals['actor'], req.body, req.params['id']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L35).

## GET /api/organization/units/:id/ancestors

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await service.ancestors(res.locals['actor'], req.params['id']))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L26).

## POST /api/organization/units/:id/archive

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 204; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    const { version } = z.object({ version: z.number().int().positive() }).strict().parse(req.body);
    await service.archive(res.locals['actor'], req.params['id'], version);
    res.status(204).end();
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L38).

## PUT /api/organization/units/:id/head

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await service.setHeadPosition(res.locals['actor'], req.params['id'], req.body))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L32).

## GET /api/organization/units/:id/head-position-options

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await service.headPositionOptions(res.locals['actor'], req.params['id'], req.query))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L29).

## GET /api/organization/units/:id/members

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await service.members(res.locals['actor'], req.params['id'], req.query))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L43).

## POST /api/organization/units/:id/members

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    await service.addMember(res.locals['actor'], req.params['id'], req.body);
    res.status(201).json({ saved: true });
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L46).

## DELETE /api/organization/units/:id/members/:membershipId

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** `id`, `membershipId`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 204; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    await service.removeMember(res.locals['actor'], req.params['id'], req.params['membershipId']);
    res.status(204).end();
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L50).

## GET /api/organization/units/employee-options

- **Authorization:** Password-mode organization admin; service authorization.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) =>
    res.json(await service.employeeOptions(res.locals['actor'], req.query))
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L20).

## Related documentation

[HTTP conventions](README.md) · [Request schemas](request-schemas.md) · [Wire contracts](contracts.md) · [Source inventory](../reference/provenance.md)
