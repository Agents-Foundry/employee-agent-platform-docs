# execution API

**Audience:** API consumers and developers. **Implementation status:** Implemented (subject to route guards and feature flags).

**Prerequisites:** Read [HTTP conventions](README.md), sign in for browser API calls, or configure the signed workload identity for runtime calls.

This reference is extracted from route registrations at `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. Handler bindings below identify actual input validators, service calls and response expressions; referenced service schemas supply the full field bounds. Authentication middleware and service authorization still apply. See [request validators](request-schemas.md) and [wire contracts](contracts.md).

## Endpoints

| Method | Path | Access | Source |
| --- | --- | --- | --- |
| GET | `/api/execution/v1/artifact-content/:token` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/execution/execution-routes.ts#L129) |
| POST | `/api/execution/v1/artifacts/:id/retrievals` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/execution/execution-routes.ts#L119) |
| POST | `/api/execution/v1/runs` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/execution/execution-routes.ts#L85) |
| GET | `/api/execution/v1/runs/:id` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/execution/execution-routes.ts#L70) |
| POST | `/api/execution/v1/runs/:id/cancel` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/execution/execution-routes.ts#L111) |
| GET | `/api/execution/v1/runs/:id/events` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/execution/execution-routes.ts#L73) |
| GET | `/api/execution/v1/threads/:id` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/execution/execution-routes.ts#L65) |

## GET /api/execution/v1/artifact-content/:token

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** `token`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200; shared middleware/service errors also apply.
- **Handler-local error codes:** `ARTIFACT_RETRIEVAL_INVALID`.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    const token = String(req.params['token'] ?? '');
    if (token.length > 2048) throw new ExecutionError(403, 'ARTIFACT_RETRIEVAL_INVALID');
    const artifact = await options.artifacts.retrieve(res.locals['actor'], token);
    // Always a download, never rendered in the control plane's origin.
    res.setHeader('Content-Type', artifact.mediaType);
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader(
      'Content-Disposition',
      `attachment; filename="${artifact.name.replace(/[^A-Za-z0-9._-]/g, '_')}"`,
    );
    res.setHeader('Content-Length', String(artifact.content.byteLength));
    res.status(200).end(artifact.content);
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/execution/execution-routes.ts#L129).

## POST /api/execution/v1/artifacts/:id/retrievals

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 201; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    res
      .status(201)
      .json(
        await options.artifacts.requestRetrieval(
          res.locals['actor'],
          id(req.params['id'], 'ARTIFACT_NOT_FOUND'),
        ),
      );
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/execution/execution-routes.ts#L119).

## POST /api/execution/v1/runs

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 202; shared middleware/service errors also apply.
- **Handler-local error codes:** `GENERIC_RUNTIME_DISABLED`, `RUNTIME_MANIFEST_V2_REQUIRED`, `WORKFLOW_NOT_IN_MANIFEST`, `CONVERSATION_AGENT_MISMATCH`.
- **Input validators:** `startRunSchema(req.body)`.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    if (!options.genericRuntimeEnabled) throw new ExecutionError(404, 'GENERIC_RUNTIME_DISABLED');
    const actor = res.locals['actor'];
    const input = startRunSchema.parse(req.body);
    const manifest = await options.loadManifest(input.agentId, actor.organizationId, actor.id);
    if (manifest.payload.apiVersion !== 'agents-foundry/v2')
      throw new ExecutionError(409, 'RUNTIME_MANIFEST_V2_REQUIRED');
    if (input.task.workflow && !manifest.payload.workflows.includes(input.task.workflow))
      throw new ExecutionError(400, 'WORKFLOW_NOT_IN_MANIFEST');
    const conversation = input.conversationId
      ? await options.loadConversation(input.conversationId, actor.organizationId, actor.id)
      : null;
    if (conversation && conversation.agentId !== input.agentId)
      throw new ExecutionError(409, 'CONVERSATION_AGENT_MISMATCH');
    const run = await service.createRun({
      organizationId: actor.organizationId,
      employeeId: actor.id,
      agentId: input.agentId,
      title: input.title ?? input.task.objective,
      task: input.task,
      manifest,
      ...(input.threadId ? { threadId: input.threadId } : {}),
      ...(conversation ? { conversation: { id: conversation.id, title: conversation.title } } : {}),
    });
    res.status(202).json(runView(run));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/execution/execution-routes.ts#L85).

## GET /api/execution/v1/runs/:id

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    res.json(await service.getRun(res.locals['actor'], id(req.params['id'], 'RUN_NOT_FOUND')));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/execution/execution-routes.ts#L70).

## POST /api/execution/v1/runs/:id/cancel

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    res.json(
      runView(
        await service.cancelOwnRun(res.locals['actor'], id(req.params['id'], 'RUN_NOT_FOUND')),
      ),
    );
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/execution/execution-routes.ts#L111).

## GET /api/execution/v1/runs/:id/events

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** `eventQuery(req.query)`.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    const query = eventQuery.parse(req.query);
    res.json(
      await service.listEvents(
        res.locals['actor'],
        id(req.params['id'], 'RUN_NOT_FOUND'),
        query.afterSequence,
        query.limit,
      ),
    );
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/execution/execution-routes.ts#L73).

## GET /api/execution/v1/threads/:id

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** `id`; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    res.json(
      await service.getThread(res.locals['actor'], id(req.params['id'], 'THREAD_NOT_FOUND')),
    );
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/execution/execution-routes.ts#L65).

## Related documentation

[HTTP conventions](README.md) · [Request schemas](request-schemas.md) · [Wire contracts](contracts.md) · [Source inventory](../reference/provenance.md)
