# authentication API

**Audience:** API consumers and developers. **Implementation status:** Implemented (subject to route guards and feature flags).

**Prerequisites:** Read [HTTP conventions](README.md), sign in for browser API calls, or configure the signed workload identity for runtime calls.

This reference is extracted from route registrations at `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. Handler bindings below identify actual input validators, service calls and response expressions; referenced service schemas supply the full field bounds. Authentication middleware and service authorization still apply. See [request validators](request-schemas.md) and [wire contracts](contracts.md).

## Endpoints

| Method | Path | Access | Source |
| --- | --- | --- | --- |
| POST | `/api/auth/activate` | Authentication lifecycle; per-route guards | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L457) |
| GET | `/api/auth/callback` | Authentication lifecycle; per-route guards | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L401) |
| GET | `/api/auth/config` | Authentication lifecycle; per-route guards | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L178) |
| POST | `/api/auth/link-account` | Authentication lifecycle; per-route guards | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L566) |
| GET | `/api/auth/link-preview` | Authentication lifecycle; per-route guards | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L550) |
| GET | `/api/auth/login` | Authentication lifecycle; per-route guards | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L358) |
| POST | `/api/auth/logout` | Authentication lifecycle; per-route guards | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L451) |
| GET | `/api/auth/memberships` | Authentication lifecycle; per-route guards | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L522) |
| POST | `/api/auth/password` | Authentication lifecycle; per-route guards | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L257) |
| POST | `/api/auth/reset-password` | Authentication lifecycle; per-route guards | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L457) |
| GET | `/api/auth/session` | Authenticated actor; service ownership/role checks | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L174) |
| POST | `/api/auth/switch` | Authentication lifecycle; per-route guards | [handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L531) |

## POST /api/auth/activate

- **Authorization:** Authentication lifecycle; per-route guards; route middleware: `requireOrigin`, `passwordLimit`.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 404, 400, 429, 204; shared middleware/service errors also apply.
- **Handler-local error codes:** `NOT_FOUND`, `INVALID_ACTIVATION`, `LOGIN_RATE_LIMITED`.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
      res.setHeader('Cache-Control', 'no-store');
      if (config.mode !== 'password') {
        res.status(404).json({ error: 'NOT_FOUND' });
        return;
      }
      const input = z
        .object({
          token: z.string().regex(/^[A-Za-z0-9_-]{43}$/),
          password: z
            .string()
            .min(15)
            .max(256)
            .refine((value) => [...value].length >= 15),
        })
        .strict()
        .safeParse(req.body);
      if (!input.success) {
        res.status(400).json({ error: 'INVALID_ACTIVATION' });
        return;
      }
      if (passwordChecks >= 4) {
        res.status(429).json({ error: 'LOGIN_RATE_LIMITED' });
        return;
      }
      passwordChecks++;
      try {
        const hash = await hashPassword(input.data.password);
        const resetting = req.path === '/api/auth/reset-password';
        const accepted = resetting
          ? await database.resetPassword(hashToken(input.data.token), hash)
          : await database.acceptInvitation(hashToken(input.data.token), hash);
        if (!accepted) {
          res.status(400).json({
            error: resetting ? 'INVALID_OR_EXPIRED_RESET' : 'INVALID_OR_EXPIRED_INVITATION',
          });
          return;
        }
        // Activation does not replace an existing browser session or log a different user in.
        res.status(204).end();
      } finally {
        passwordChecks--;
      }
    }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L457).

## GET /api/auth/callback

- **Authorization:** Authentication lifecycle; per-route guards.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 404, 400, 403, 401; shared middleware/service errors also apply.
- **Handler-local error codes:** `GOOGLE_NOT_CONFIGURED`, `INVALID_LOGIN_CALLBACK`, `MEMBERSHIP_REQUIRED`, `GOOGLE_SIGN_IN_FAILED`.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    if (!provider) {
      res.status(404).json({ error: 'GOOGLE_NOT_CONFIGURED' });
      return;
    }
    res.setHeader('Cache-Control', 'no-store');
    const binding = cookie(req, loginName);
    res.clearCookie(loginName, options);
    const transaction = binding ? await database.consumeLogin(hashToken(binding)) : undefined;
    if (
      !transaction ||
      req.query['state'] !== transaction.state ||
      typeof req.query['code'] !== 'string' ||
      req.query['code'].length > 4000 ||
      req.query['error']
    ) {
      res.status(400).json({ error: 'INVALID_LOGIN_CALLBACK' });
      return;
    }
    try {
      const subject = await provider.exchange(
        req.query['code'],
        transaction.verifier,
        transaction.nonce,
      );
      if (
        !(await database.findIdentity(
          GOOGLE_ISSUER,
          subject,
          res.locals['tenantOrganizationId'] as string | undefined,
        ))
      ) {
        res.status(403).json({ error: 'MEMBERSHIP_REQUIRED', issuer: GOOGLE_ISSUER, subject });
        return;
      }
      const old = cookie(req, sessionName);
      if (old) await database.deleteSession(hashToken(old));
      const session = randomToken();
      await database.createSession(
        hashToken(session),
        GOOGLE_ISSUER,
        subject,
        Date.now() + 8 * 3600000,
      );
      res.cookie(sessionName, session, { ...options, maxAge: 8 * 3600000 });
      res.redirect(transaction.destination);
    } catch {
      res.status(401).json({ error: 'GOOGLE_SIGN_IN_FAILED' });
    }
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L401).

## GET /api/auth/config

- **Authorization:** Authentication lifecycle; per-route guards.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
(_req, res) => {
    res.setHeader('Cache-Control', 'no-store');
    res.json(publicAuthConfig(config));
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L178).

## POST /api/auth/link-account

- **Authorization:** Authentication lifecycle; per-route guards; route middleware: `requireAccount`.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 403, 400, 404; shared middleware/service errors also apply.
- **Handler-local error codes:** `CANONICAL_HOST_REQUIRED`, `INVALID_LINK`, `INVALID_OR_EXPIRED_LINK`.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    if (res.locals['tenantOrganizationId'])
      return res.status(403).json({ error: 'CANONICAL_HOST_REQUIRED' });
    const input = z
      .object({ token: z.string().regex(/^[A-Za-z0-9_-]{43}$/) })
      .strict()
      .safeParse(req.body);
    if (!input.success) return res.status(400).json({ error: 'INVALID_LINK' });
    const actor = await database.acceptAccountLink(
      hashToken(input.data.token),
      res.locals['accountUserId'],
    );
    if (!actor) return res.status(404).json({ error: 'INVALID_OR_EXPIRED_LINK' });
    const session = randomToken();
    await database.createAccountSession(
      hashToken(session),
      res.locals['accountUserId'],
      actor.organizationId,
      Date.now() + 8 * 3600000,
    );
    await database.deleteSession(res.locals['accountSessionHash']);
    res.cookie(sessionName, session, { ...options, maxAge: 8 * 3600000 });
    return res.json(actor);
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L566).

## GET /api/auth/link-preview

- **Authorization:** Authentication lifecycle; per-route guards; route middleware: `requireAccount`.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 403, 400, 404; shared middleware/service errors also apply.
- **Handler-local error codes:** `CANONICAL_HOST_REQUIRED`, `INVALID_LINK`, `INVALID_OR_EXPIRED_LINK`.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    if (res.locals['tenantOrganizationId'])
      return res.status(403).json({ error: 'CANONICAL_HOST_REQUIRED' });
    const token = z
      .string()
      .regex(/^[A-Za-z0-9_-]{43}$/)
      .safeParse(req.query['token']);
    if (!token.success) return res.status(400).json({ error: 'INVALID_LINK' });
    const preview = await database.previewAccountLink(
      hashToken(token.data),
      res.locals['accountUserId'],
    );
    if (!preview) return res.status(404).json({ error: 'INVALID_OR_EXPIRED_LINK' });
    res.setHeader('Cache-Control', 'no-store');
    return res.json(preview);
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L550).

## GET /api/auth/login

- **Authorization:** Authentication lifecycle; per-route guards.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 404, 400; shared middleware/service errors also apply.
- **Handler-local error codes:** `GOOGLE_NOT_CONFIGURED`, `INVALID_CLIENT`.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    if (config.mode !== 'google') {
      res.status(404).json({ error: 'GOOGLE_NOT_CONFIGURED' });
      return;
    }
    const destination =
      req.query['client'] === 'admin'
        ? config.adminUrl
        : req.query['client'] === 'employee'
          ? config.employeeUrl
          : undefined;
    if (!destination) {
      res.status(400).json({ error: 'INVALID_CLIENT' });
      return;
    }
    const state = randomToken(),
      nonce = randomToken(),
      verifier = randomToken(),
      binding = randomToken();
    const previous = cookie(req, loginName);
    if (previous) await database.discardLogin(hashToken(previous));
    await database.createLogin(
      hashToken(binding),
      { state, nonce, verifier, destination },
      Date.now() + 600000,
    );
    const url = new URL('https://accounts.google.com/o/oauth2/v2/auth');
    url.search = new URLSearchParams({
      client_id: config.clientId,
      redirect_uri: config.callbackUrl,
      response_type: 'code',
      scope: 'openid email profile',
      state,
      nonce,
      hd: config.workspaceDomain,
      code_challenge: createHash('sha256').update(verifier).digest('base64url'),
      code_challenge_method: 'S256',
      prompt: 'select_account',
    }).toString();
    res.cookie(loginName, binding, { ...options, maxAge: 600000 });
    res.setHeader('Cache-Control', 'no-store');
    res.redirect(url.href);
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L358).

## POST /api/auth/logout

- **Authorization:** Authentication lifecycle; per-route guards; route middleware: `requireOrigin`.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 204; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    const token = cookie(req, sessionName);
    if (token) await database.deleteSession(hashToken(token));
    res.clearCookie(sessionName, options);
    res.status(204).end();
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L451).

## GET /api/auth/memberships

- **Authorization:** Authentication lifecycle; per-route guards; route middleware: `requireAccount`.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_req, res) => {
    res.setHeader('Cache-Control', 'no-store');
    res.json(
      await database.listAccountMemberships(
        res.locals['accountActor'],
        res.locals['tenantOrganizationId'],
      ),
    );
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L522).

## POST /api/auth/password

- **Authorization:** Authentication lifecycle; per-route guards; route middleware: `requireOrigin`, `passwordLimit`, `accountLimit`.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 401, 429; shared middleware/service errors also apply.
- **Handler-local error codes:** `INVALID_CREDENTIALS`, `LOGIN_RATE_LIMITED`.
- **Input validators:** Service validation or route has no parsed body/query.

The complete login/transaction handler is intentionally linked rather than excerpted incompletely: [request, response and branch guards](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L257).

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L257).

## POST /api/auth/reset-password

- **Authorization:** Authentication lifecycle; per-route guards; route middleware: `requireOrigin`, `passwordLimit`.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 404, 400, 429, 204; shared middleware/service errors also apply.
- **Handler-local error codes:** `NOT_FOUND`, `INVALID_ACTIVATION`, `LOGIN_RATE_LIMITED`.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
      res.setHeader('Cache-Control', 'no-store');
      if (config.mode !== 'password') {
        res.status(404).json({ error: 'NOT_FOUND' });
        return;
      }
      const input = z
        .object({
          token: z.string().regex(/^[A-Za-z0-9_-]{43}$/),
          password: z
            .string()
            .min(15)
            .max(256)
            .refine((value) => [...value].length >= 15),
        })
        .strict()
        .safeParse(req.body);
      if (!input.success) {
        res.status(400).json({ error: 'INVALID_ACTIVATION' });
        return;
      }
      if (passwordChecks >= 4) {
        res.status(429).json({ error: 'LOGIN_RATE_LIMITED' });
        return;
      }
      passwordChecks++;
      try {
        const hash = await hashPassword(input.data.password);
        const resetting = req.path === '/api/auth/reset-password';
        const accepted = resetting
          ? await database.resetPassword(hashToken(input.data.token), hash)
          : await database.acceptInvitation(hashToken(input.data.token), hash);
        if (!accepted) {
          res.status(400).json({
            error: resetting ? 'INVALID_OR_EXPIRED_RESET' : 'INVALID_OR_EXPIRED_INVITATION',
          });
          return;
        }
        // Activation does not replace an existing browser session or log a different user in.
        res.status(204).end();
      } finally {
        passwordChecks--;
      }
    }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L457).

## GET /api/auth/session

- **Authorization:** Authenticated actor; service ownership/role checks.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 200 on normal JSON response; shared middleware/service errors also apply.
- **Handler-local error codes:** No additional literal error code in this handler; consult service and common errors.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (_request, response) =>
    response.json(response.locals['actor'])
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts#L174).

## POST /api/auth/switch

- **Authorization:** Authentication lifecycle; per-route guards; route middleware: `requireAccount`.
- **Parameters:** No path parameters; body/query bindings are shown below.
- **Explicit handler HTTP statuses:** 400, 403; shared middleware/service errors also apply.
- **Handler-local error codes:** `INVALID_ORGANIZATION`, `TENANT_HOST_MISMATCH`, `MEMBERSHIP_REQUIRED`.
- **Input validators:** Service validation or route has no parsed body/query.

Request/response implementation binding (TypeScript, not a copyable HTTP command):

```typescript
async (req, res) => {
    const input = z.object({ organizationId: z.string().uuid() }).strict().safeParse(req.body);
    if (!input.success) return res.status(400).json({ error: 'INVALID_ORGANIZATION' });
    const target = input.data.organizationId;
    if (res.locals['tenantOrganizationId'] && res.locals['tenantOrganizationId'] !== target)
      return res.status(403).json({ error: 'TENANT_HOST_MISMATCH' });
    const actor = await database.accountMembership(res.locals['accountUserId'], target);
    if (!actor) return res.status(403).json({ error: 'MEMBERSHIP_REQUIRED' });
    const session = randomToken();
    await database.createAccountSession(
      hashToken(session),
      res.locals['accountUserId'],
      target,
      Date.now() + 8 * 3600000,
    );
    await database.deleteSession(res.locals['accountSessionHash']);
    res.cookie(sessionName, session, { ...options, maxAge: 8 * 3600000 });
    return res.json(actor);
  }
```

[Source handler](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts#L531).

## Related documentation

[HTTP conventions](README.md) · [Request schemas](request-schemas.md) · [Wire contracts](contracts.md) · [Source inventory](../reference/provenance.md)
