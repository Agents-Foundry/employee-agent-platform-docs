# agents and conversations API

**Audience:** API consumers and developers. **Implementation status:** Implemented (subject to route guards and feature flags).

**Prerequisites:** Read [HTTP conventions](README.md), sign in for browser API calls, or configure the signed workload identity for runtime calls.

This reference is extracted from route registrations at `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. Handler bindings below identify actual input validators, service calls and response expressions; referenced service schemas supply the full field bounds. Authentication middleware and service authorization still apply. See [request validators](request-schemas.md) and [wire contracts](contracts.md).

## Endpoints

| Method | Path | Access | Source |
| --- | --- | --- | --- |
| GET | `/api/agents/:id/manifest` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L282) |
| GET | `/api/approvals` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L395) |
| POST | `/api/approvals/:id/decision` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L405) |
| GET | `/api/blueprints` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L206) |
| GET | `/api/bootstrap` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L202) |
| GET | `/api/conversations` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L298) |
| POST | `/api/conversations` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L305) |
| GET | `/api/conversations/:id` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L323) |
| POST | `/api/conversations/:id/messages` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L330) |
| GET | `/api/health` | Public liveness | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L161) |
| GET | `/api/lifecycle-events` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L292) |
| GET | `/api/manifest-key` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L241) |
| GET | `/api/provisioning` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L244) |
| POST | `/api/provisioning` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L253) |
| POST | `/api/provisioning/:id/decision` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L262) |
| POST | `/api/qa/runs` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L348) |
| GET | `/metrics` | Operator bearer token; conditional route | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/metrics-route.ts#L20) |

## GET /api/agents/:id/manifest

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const actor = response.locals['actor'];
    response.json(
      await database.getManifest(
        String(request.params['id']),
        actor.organizationId,
        actor.role === 'EMPLOYEE' ? actor.id : undefined,
      ),
    );
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L282).

## GET /api/approvals

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_request, response) => {
    const actor = response.locals['actor'];
    response.json(
      await database.listApprovals(
        actor.organizationId,
        actor.role === 'EMPLOYEE' ? actor.id : undefined,
      ),
    );
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L395).

## POST /api/approvals/:id/decision

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 403; shared middleware/service errors also apply.
- **Handler-local error codes:** `ADMIN_ROLE_REQUIRED`.
- **Input validators:** `approvalDecisionSchema(request.body)`.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const actor = response.locals['actor'];
    if (actor.role !== 'ADMIN') {
      return response.status(403).json({ error: 'ADMIN_ROLE_REQUIRED' });
    }
    const { decision } = approvalDecisionSchema.parse(request.body);
    return response.json(
      await database.decideApproval(
        String(request.params['id']),
        decision,
        actor.id,
        actor.organizationId,
      ),
    );
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L405).

## GET /api/blueprints

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_request, response) =>
    response.json(await database.catalog.legacyBlueprints())
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L206).

## GET /api/bootstrap

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_request, response) => {
    response.json(await database.getBootstrap(response.locals['actor'], auth.mode === 'demo'));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L202).

## GET /api/conversations

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 403; shared middleware/service errors also apply.
- **Handler-local error codes:** `ACTOR_FORBIDDEN`.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const actor = response.locals['actor'];
    if (request.query['employeeId'] && request.query['employeeId'] !== actor.id)
      return response.status(403).json({ error: 'ACTOR_FORBIDDEN' });
    return response.json(await database.listConversations(actor.id, actor.organizationId));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L298).

## POST /api/conversations

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 403, 201; shared middleware/service errors also apply.
- **Handler-local error codes:** `ACTOR_FORBIDDEN`.
- **Input validators:** `createConversationSchema(request.body)`.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const input = createConversationSchema.parse(request.body);
    const actor = response.locals['actor'];
    if (actor.role !== 'EMPLOYEE' || input.employeeId !== actor.id)
      return response.status(403).json({ error: 'ACTOR_FORBIDDEN' });
    return response
      .status(201)
      .json(
        await database.createConversation(
          actor.id,
          input.agentId,
          input.title,
          actor.organizationId,
          auth.mode === 'demo',
        ),
      );
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L305).

## GET /api/conversations/:id

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const actor = response.locals['actor'];
    response.json(
      await database.getConversation(String(request.params['id']), actor.organizationId, actor.id),
    );
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L323).

## POST /api/conversations/:id/messages

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 403, 201; shared middleware/service errors also apply.
- **Handler-local error codes:** `ACTOR_FORBIDDEN`.
- **Input validators:** `addMessageSchema(request.body)`.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const input = addMessageSchema.parse(request.body);
    const actor = response.locals['actor'];
    if (actor.role !== 'EMPLOYEE' || input.author !== 'EMPLOYEE')
      return response.status(403).json({ error: 'ACTOR_FORBIDDEN' });
    return response
      .status(201)
      .json(
        await database.addMessage(
          String(request.params['id']),
          'EMPLOYEE',
          input.content,
          actor.organizationId,
          actor.id,
        ),
      );
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L330).

## GET /api/health

- **Authorization:** Public liveness.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_request, response) => {
    response.json({
      status: 'ok',
      service: 'control-plane-api',
      timestamp: new Date().toISOString(),
    });
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L161).

## GET /api/lifecycle-events

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 403; shared middleware/service errors also apply.
- **Handler-local error codes:** `ADMIN_ROLE_REQUIRED`.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_request, response) => {
    const actor = response.locals['actor'];
    if (actor.role !== 'ADMIN') return response.status(403).json({ error: 'ADMIN_ROLE_REQUIRED' });
    return response.json(await database.listLifecycleEvents(actor.organizationId));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L292).

## GET /api/manifest-key

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_request, response) =>
    response.json(database.signer.verificationKey)
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L241).

## GET /api/provisioning

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_request, response) => {
    const actor = response.locals['actor'];
    response.json(
      await database.listProvisioning(
        actor.organizationId,
        actor.role === 'EMPLOYEE' ? actor.id : undefined,
      ),
    );
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L244).

## POST /api/provisioning

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 403, 201; shared middleware/service errors also apply.
- **Handler-local error codes:** `EMPLOYEE_ROLE_REQUIRED`.
- **Input validators:** `provisioningSchema(request.body)`.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const actor = response.locals['actor'];
    if (actor.role !== 'EMPLOYEE')
      return response.status(403).json({ error: 'EMPLOYEE_ROLE_REQUIRED' });
    const input = provisioningSchema.parse(request.body);
    return response
      .status(201)
      .json(await database.requestProvisioning(actor.id, input, actor.organizationId));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L253).

## POST /api/provisioning/:id/decision

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 403; shared middleware/service errors also apply.
- **Handler-local error codes:** `ADMIN_ROLE_REQUIRED`.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const actor = response.locals['actor'];
    if (actor.role !== 'ADMIN') return response.status(403).json({ error: 'ADMIN_ROLE_REQUIRED' });
    const input = z
      .object({
        decision: z.enum(['APPROVED', 'REJECTED']),
        reason: z.string().trim().min(1).max(500),
      })
      .strict()
      .parse(request.body);
    return response.json(
      await database.decideProvisioning(
        String(request.params['id']),
        actor.organizationId,
        actor.id,
        input.decision,
        input.reason,
      ),
    );
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L262).

## POST /api/qa/runs

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 403, 202, 500; shared middleware/service errors also apply.
- **Handler-local error codes:** `ACTOR_FORBIDDEN`, `POLICY_CONFIGURATION_ERROR`.
- **Input validators:** `qaRunSchema(request.body)`.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    const input: QaRunRequest = qaRunSchema.parse(request.body);
    const actor = response.locals['actor'];
    if (actor.role !== 'EMPLOYEE' || input.employeeId !== actor.id)
      return response.status(403).json({ error: 'ACTOR_FORBIDDEN' });
    await database.getConversation(input.conversationId, actor.organizationId, actor.id);
    if (database.qaGenericRuntimeEnabled) {
      const generic = await database.createGenericQaRun(
        input,
        actor.organizationId,
        auth.mode === 'demo',
      );
      if (generic) return response.status(202).json(generic);
    }
    const policy = evaluatePolicy('qa.execute_playwright');
    if (policy.outcome !== 'REQUIRE_APPROVAL') {
      return response.status(500).json({ error: 'POLICY_CONFIGURATION_ERROR' });
    }
    const plan = [
      `Read acceptance criteria from ${input.storyKey}`,
      'Map impacted UI and API paths from the assigned repositories',
      'Generate deterministic smoke and regression scenarios',
      `Run isolated Playwright checks against ${new URL(input.targetUrl).origin}`,
      'Capture trace, screenshots, console, and network evidence',
      'Draft defects for human review; never publish automatically',
    ];
    const { instructions: _unused, ...legacyInput } = input;
    const legacy = await database.createQaRun(
      {
        ...legacyInput,
        plan,
        approvalSummary: `Approve isolated Playwright execution for ${input.storyKey} against ${input.targetUrl}.`,
      },
      actor.organizationId,
      auth.mode === 'demo',
    );
    const result: QaRunResponse = { mode: 'LEGACY_STATIC_PLAN', ...legacy };
    await database.addMessage(
      input.conversationId,
      'AGENT',
      `I prepared a six-step QA plan for ${input.storyKey}. Browser execution is paused for admin approval (${result.approval.id}).`,
      actor.organizationId,
      actor.id,
    );
    return response.status(202).json(result);
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L348).

## GET /metrics

- **Authorization:** Operator bearer token; conditional route.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 401; shared middleware/service errors also apply.
- **Handler-local error codes:** `METRICS_TOKEN_REQUIRED`.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (request, response) => {
    let expected: string;
    try {
      expected = readFileSync(tokenPath, 'utf8').trim();
    } catch {
      expected = '';
    }
    const presented = /^Bearer (.+)$/.exec(request.header('authorization') ?? '')?.[1] ?? '';
    // Compared as digests, so neither length nor content leaks through timing.
    if (expected.length < 32 || !timingSafeEqual(digest(presented), digest(expected))) {
      response.setHeader('WWW-Authenticate', 'Bearer');
      response.status(401).json({ error: 'METRICS_TOKEN_REQUIRED' });
      return;
    }
    response.setHeader('Cache-Control', 'no-store');
    response.type('text/plain; version=0.0.4').send(await telemetry.metrics.prometheus());
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/metrics-route.ts#L20).

## Related documentation

[HTTP conventions](README.md) · [Request schemas](request-schemas.md) · [Wire contracts](contracts.md) · [Source inventory](../reference/provenance.md)
