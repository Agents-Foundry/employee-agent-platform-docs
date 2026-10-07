# Request and protocol validation schemas

**Audience:** Developers and API consumers. **Implementation status:** Implemented contracts; availability of execution depends on the implementation matrix.

**Prerequisites:** Read the [HTTP conventions](README.md) and relevant endpoint page.

Extracted at `d2bc8d7fa3fc185cc4f487bdaa1f11611844763f`. These are literal source declarations, not evidence that a corresponding engine exists. Schemas express required fields, defaults, enum values, refinements and unknown-field rejection. Type-only structures still require runtime validation and authorization.

## uuid (1)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/agent-runtime/src/checkpoints.ts#L75).

```typescript
z.uuid()
```

## checkpointSchema (2)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/agent-runtime/src/checkpoints.ts#L76).

```typescript
z
  .object({
    format: z.literal(2),
    version: z.number().int().min(1).max(1_000_000),
    runId: uuid,
    sessionId: uuid,
    correlation: correlationSchema,
    task: taskSpecSchema,
    workflow: workflowDefinitionSchema.optional(),
    runtimeProfile: z.string().min(1).max(100),
    manifest: signedManifestV2Schema,
    kernelId: z.string().min(1).max(100),
    kernelState: z.unknown(),
    stepId: uuid.nullable(),
    approvalId: uuid.nullable(),
    runtimeSequence: z.number().int().min(0).max(1_000_000),
  })
  .strict()
```

## uuid (3)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/agent-runtime/src/kernel/native-kernel.ts#L44).

```typescript
z.uuid()
```

## stateSchema (4)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/agent-runtime/src/kernel/native-kernel.ts#L45).

```typescript
z.object({
  version: z.literal(2),
  messages: z.array(z.any()),
  turns: z.number().int().min(0),
  artifactIds: z.array(z.string()),
  turn: z
    .object({
      toolUses: z.array(z.object({ id: z.string(), name: z.string(), input: z.unknown() })),
      results: z.array(z.any()),
      index: z.number().int().min(0),
      inFlight: z
        .object({
          stepId: uuid,
          toolCallId: uuid,
          requestId: uuid,
          approvalId: uuid.nullable(),
        })
        .strict()
        .nullable(),
    })
    .strict()
    .nullable(),
})
```

## inputSchema (5)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/agent-runtime/src/tools/artifact-tool.ts#L15).

```typescript
z
  .object({
    name: z.string().regex(/^[A-Za-z0-9][A-Za-z0-9._-]{0,119}$/),
    type: z.enum(textTypes),
    mediaType: z.enum(['text/markdown', 'text/plain', 'application/json']),
    content: z.string().min(1),
  })
  .strict()
  .refine((value) => Buffer.byteLength(value.content, 'utf8') <= MAX_ARTIFACT_BYTES, {
    message: `content must be at most ${MAX_ARTIFACT_BYTES} bytes`,
  })
```

## createSchema (6)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/agent-runtime/src/tools/issue-tracker-tool.ts#L5).

```typescript
z
  .object({
    projectKey: z.string().regex(/^[A-Z][A-Z0-9]{1,9}$/),
    summary: z
      .string()
      .max(255)
      .refine((value) => value.trim().length > 0 && !/[\r\n]/.test(value), 'one non-blank line'),
    description: z
      .string()
      .max(20_000)
      .refine((value) => value.trim().length > 0, 'must not be blank'),
    issueType: z.enum(['Bug', 'Task', 'Story']),
  })
  .strict()
```

## readSchema (7)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/agent-runtime/src/tools/issue-tracker-tool.ts#L19).

```typescript
z
  .object({ issueKey: z.string().regex(/^[A-Z][A-Z0-9]{1,9}-[1-9]\d{0,8}$/) })
  .strict()
```

## inputSchema (8)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/agent-runtime/src/tools/issue-tracker-tool.ts#L22).

```typescript
z.union([readSchema, createSchema])
```

## inputSchema (9)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/agent-runtime/src/tools/source-control-tool.ts#L5).

```typescript
z
  .object({
    repository: z.string().regex(/^[A-Za-z0-9][A-Za-z0-9-]{0,38}\/[A-Za-z0-9._-]{1,100}$/),
    baseBranch: z.string().min(1).max(200),
    headBranch: z.string().regex(/^agents-foundry\/[a-z0-9][a-z0-9._-]{0,79}$/),
    title: z
      .string()
      .max(200)
      .refine((value) => value.trim().length > 0 && !/[\r\n]/.test(value), 'one non-blank line'),
    body: z.string().max(20_000),
    path: z.string().regex(/^[A-Za-z0-9_][A-Za-z0-9._-]{0,99}$/),
  })
  .strict()
```

## overrideSchema (10)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/actions/action-policy-service.ts#L29).

```typescript
z
  .object({
    // ALLOW is deliberately absent: organizations can only tighten platform policy.
    outcome: z.enum(['REQUIRE_APPROVAL', 'DENY']),
    reason: z.string().trim().min(1).max(500),
  })
  .strict()
```

## resolutionSchema (11)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/actions/action-reconciliation.ts#L52).

```typescript
z
  .object({
    resolution: z.enum(['APPLIED', 'NOT_APPLIED']),
    note: z.string().trim().min(1).max(500).optional(),
  })
  .strict()
```

## issueDraft (12)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/actions/action-registry.ts#L83).

```typescript
z
  .object({
    projectKey: z.string().regex(/^[A-Z][A-Z0-9]{1,9}$/),
    summary: nonBlank(255).refine((value) => !/[\r\n]/.test(value), 'must be one line'),
    description: nonBlank(20_000),
    issueType: z.enum(['Bug', 'Task', 'Story']),
  })
  .strict()
```

## issueReference (13)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/actions/action-registry.ts#L112).

```typescript
z
  .object({ issueKey: z.string().regex(/^[A-Z][A-Z0-9]{1,9}-[1-9]\d{0,8}$/) })
  .strict()
```

## pullRequest (14)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/actions/action-registry.ts#L146).

```typescript
z
  .object({
    repository: z.string().regex(/^[A-Za-z0-9][A-Za-z0-9-]{0,38}\/[A-Za-z0-9._-]{1,100}$/),
    baseBranch: z
      .string()
      .regex(/^(?!-)(?!.*\.\.)(?!.*\/\/)[A-Za-z0-9._/-]{1,200}$/)
      .refine((value) => !value.endsWith('/') && !value.endsWith('.lock'), 'invalid branch'),
    /** New branches only, in a namespace people can recognise and clean up. */
    headBranch: z.string().regex(/^agents-foundry\/[a-z0-9][a-z0-9._-]{0,79}$/),
    title: oneLine(200),
    body: z.string().max(20_000),
    /** Workspace directory the repository was checked out into, for example "repo". */
    path: z.string().regex(/^[A-Za-z0-9_][A-Za-z0-9._-]{0,99}$/),
  })
  .strict()
```

## actionParam (15)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/actions/action-routes.ts#L8).

```typescript
z.string().regex(/^[a-z][a-z0-9_]*(?:\.[a-z][a-z0-9_]*){1,5}$/)
```

## { version } (16)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/actions/action-routes.ts#L39).

```typescript
z.object({ version: z.number().int().positive() }).strict().parse(req.body)
```

## jiraSettings (17)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/actions/connector-service.ts#L17).

```typescript
z
  .object({
    authEmail: z.email().max(254).optional(),
    allowedProjects: z
      .array(z.string().regex(/^[A-Z][A-Z0-9]{1,9}$/))
      .max(50)
      .refine(unique, 'duplicate project key'),
  })
  .strict()
```

## githubSettings (18)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/actions/connector-service.ts#L27).

```typescript
z
  .object({
    allowedRepositories: z
      .array(z.string().regex(/^[A-Za-z0-9][A-Za-z0-9-]{0,38}\/[A-Za-z0-9._-]{1,100}$/))
      .max(50)
      .refine((names) => unique(names.map((name) => name.toLowerCase())), 'duplicate repository'),
  })
  .strict()
  .transform((settings) => ({ allowedProjects: [] as string[], ...settings }))
```

## common (19)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/actions/connector-service.ts#L36).

```typescript
{
  name: z.string().trim().min(1).max(120),
  baseUrl: z.string().max(300),
  secretRef: z.string().regex(secretReferencePattern),
}
```

## createSchema (20)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/actions/connector-service.ts#L41).

```typescript
z.discriminatedUnion('provider', [
  z.object({ provider: z.literal('jira'), ...common, settings: jiraSettings }).strict(),
  z.object({ provider: z.literal('github'), ...common, settings: githubSettings }).strict(),
]) satisfies z.ZodType<{ provider: (typeof connectorProviders)[number] }>
```

## provisioningSchema (21)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/app.ts#L28).

```typescript
z
  .object({
    // Existence, answers and capabilities are resolved against the catalog of record.
    blueprintId: z.string().min(1).max(120),
    blueprintVersion: z.string().regex(/^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$/),
    provider: z
      .string()
      .trim()
      .min(1)
      .max(80)
      .regex(/^[a-zA-Z0-9._-]+$/),
    model: z
      .string()
      .trim()
      .min(1)
      .max(160)
      .regex(/^[a-zA-Z0-9._:/-]+$/),
    credentialMode: z.enum(['EMPLOYEE_BYOK', 'ORGANIZATION_MANAGED']),
    answers: z.record(z.string(), z.union([z.string(), z.array(z.string())])),
  })
  .strict()
```

## createConversationSchema (22)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/app.ts#L50).

```typescript
z.object({
  employeeId: z.string().min(1).max(120),
  agentId: z.string().min(1).max(120),
  title: z.string().trim().min(1).max(140),
})
```

## addMessageSchema (23)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/app.ts#L56).

```typescript
z.object({
  author: z.enum(['EMPLOYEE', 'AGENT', 'SYSTEM']),
  content: z.string().trim().min(1).max(20_000),
})
```

## qaRunSchema (24)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/app.ts#L61).

```typescript
z.object({
  employeeId: z.string().min(1).max(120),
  conversationId: z.string().uuid(),
  storyKey: z
    .string()
    .trim()
    .regex(/^[A-Z][A-Z0-9]+-\d+$/),
  targetUrl: z.url().refine((url) => ['http:', 'https:'].includes(new URL(url).protocol), {
    message: 'Only HTTP(S) targets are allowed.',
  }),
  instructions: z.string().trim().min(1).max(2000).optional(),
})
```

## approvalDecisionSchema (25)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/app.ts#L74).

```typescript
z.object({
  decision: z.enum(['APPROVED', 'REJECTED']),
})
```

## input (26)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/app.ts#L219).

```typescript
provisioningSchema
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
      .parse(request.body)
```

## input (27)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/app.ts#L265).

```typescript
z
      .object({
        decision: z.enum(['APPROVED', 'REJECTED']),
        reason: z.string().trim().min(1).max(500),
      })
      .strict()
      .parse(request.body)
```

## required (28)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/auth.ts#L65).

```typescript
(name: string) => z.string().trim().min(1).parse(env[name])
```

## { id_token } (29)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/auth.ts#L136).

```typescript
z
      .object({ id_token: z.string().min(1).max(20000) })
      .parse(await response.json())
```

## input (30)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/auth.ts#L259).

```typescript
z
      .object({
        email: z.string().trim().max(254).pipe(z.email()),
        password: z.string().min(1).max(256),
        client: z.enum(['admin', 'employee']).optional(),
      })
      .strict()
      .safeParse(req.body)
```

## input (31)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/auth.ts#L467).

```typescript
z
        .object({
          token: z.string().regex(/^[A-Za-z0-9_-]{43}$/),
          password: z
            .string()
            .min(15)
            .max(256)
            .refine((value) => [...value].length >= 15),
        })
        .strict()
        .safeParse(req.body)
```

## input (32)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/auth.ts#L532).

```typescript
z.object({ organizationId: z.string().uuid() }).strict().safeParse(req.body)
```

## input (33)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/auth.ts#L569).

```typescript
z
      .object({ token: z.string().regex(/^[A-Za-z0-9_-]{43}$/) })
      .strict()
      .safeParse(req.body)
```

## index (34)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/catalog/catalog-registry.ts#L50).

```typescript
<T extends { id: string; version: string }>(
    kind: string,
    items: unknown[],
    schema: z.ZodType<T>,
  ): Map<string, T> => {
    const map = new Map<string, T>();
    items.forEach((item, position) => {
      const parsed = schema.safeParse(item);
      if (!parsed.success) {
        problems.push(
          `${kind}[${position}]: ${parsed.error.issues.map((i) => `${i.path.join('.')} ${i.message}`).join(', ')}`,
        );
        return;
      }
      const id = key(parsed.data.id, parsed.data.version);
      if (map.has(id)) problems.push(`${kind} ${id}: duplicate version`);
      map.set(id, parsed.data);
    });
    return map;
  }
```

## bundleSchema (35)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/catalog/catalog-registry.ts#L108).

```typescript
z
  .object({
    blueprint: blueprintVersionSchema,
    skills: z.array(skillDefinitionSchema),
    tools: z.array(toolDefinitionSchema),
    workflows: z.array(workflowDefinitionSchema),
  })
  .strict()
```

## { version } (36)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/catalog/catalog-routes.ts#L48).

```typescript
z.object({ version: z.number().int().positive() }).strict().parse(req.body)
```

## name (37)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/catalog/installation-service.ts#L11).

```typescript
z.string().trim().min(1).max(120)
```

## semver (38)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/catalog/installation-service.ts#L12).

```typescript
z.string().regex(/^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$/)
```

## configuration (39)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/catalog/installation-service.ts#L13).

```typescript
z.record(z.string().max(60), z.unknown())
```

## createInput (40)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/catalog/installation-service.ts#L14).

```typescript
z
  .object({
    name,
    blueprintId: z.string().min(1).max(120),
    blueprintVersion: semver,
    configuration,
  })
  .strict()
```

## updateInput (41)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/catalog/installation-service.ts#L22).

```typescript
z
  .object({
    name,
    blueprintVersion: semver,
    configuration,
    version: z.number().int().positive(),
  })
  .strict()
```

## listQuery (42)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/catalog/installation-service.ts#L30).

```typescript
z
  .object({ status: z.enum(['ACTIVE', 'RETIRED', 'all']).default('ACTIVE') })
  .strict()
```

## input (43)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/create-customer.ts#L12).

```typescript
z
  .object({
    organization: z
      .object({
        name: z.string().trim().min(1).max(200),
        slug: z
          .string()
          .regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/)
          .max(80),
      })
      .strict(),
    admin: memberInput,
  })
  .strict()
  .parse(JSON.parse(readFileSync(filename, 'utf8')))
```

## { version } (44)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/credentials/credential-routes.ts#L38).

```typescript
z.object({ version: z.number().int().positive() }).strict().parse(req.body)
```

## createSchema (45)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/credentials/source-control-connections.ts#L23).

```typescript
z
  .object({
    provider: z.enum(sourceControlProviders),
    name: z.string().trim().min(1).max(120),
    gitHost: hostname,
    apiBaseUrl: z.string().max(300),
    credentialMode: z.enum(credentialModes),
    secretRef: z.string().regex(secretReferencePattern),
    appId: z
      .string()
      .regex(/^[0-9]{1,20}$/)
      .optional(),
    installationId: z
      .string()
      .regex(/^[0-9]{1,20}$/)
      .optional(),
    allowedRepositories: z
      .array(z.string().regex(repositoryNamePattern))
      .min(1)
      .max(100)
      .refine(unique, 'duplicate repository'),
  })
  .strict()
  .refine(
    (input) =>
      input.credentialMode === 'github_app'
        ? input.provider === 'github' && !!input.appId && !!input.installationId
        : !input.appId && !input.installationId,
    'GitHub App connections need appId and installationId; token connections take neither',
  )
```

## eventQuery (46)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/execution/execution-routes.ts#L8).

```typescript
z
  .object({
    afterSequence: z.coerce.number().int().min(0).max(1_000_000).default(0),
    limit: z.coerce.number().int().min(1).max(200).default(100),
  })
  .strict()
```

## startRunSchema (47)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/execution/execution-routes.ts#L15).

```typescript
z
  .object({
    agentId: z.string().min(1).max(120),
    title: z.string().trim().min(1).max(200).optional(),
    threadId: z.uuid().optional(),
    /** Run in this conversation's thread; its approvals and outcome are posted back to it. */
    conversationId: z.uuid().optional(),
    task: taskSpecSchema,
  })
  .strict()
  .refine((input) => !(input.threadId && input.conversationId), 'threadId or conversationId')
```

## id (48)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/execution/execution-routes.ts#L60).

```typescript
(value: unknown, missing: string) => {
    const parsed = z.uuid().safeParse(value);
    if (!parsed.success) throw new ExecutionError(404, missing);
    return parsed.data;
  }
```

## parsed (49)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/execution/execution-routes.ts#L61).

```typescript
z.uuid().safeParse(value)
```

## entry (50)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/identity-directory.ts#L6).

```typescript
z
  .object({
    subject: z.string().min(1).max(512),
    employeeId: z.string().min(1).max(120),
    organization: z
      .object({
        id: z.string().min(1).max(120),
        name: z.string().min(1).max(200),
        slug: z.string().min(1).max(120),
      })
      .strict(),
    displayName: z.string().min(1).max(200),
    email: z.email(),
    passwordHash: z.string().regex(passwordHashPattern).optional(),
    role: z.enum(['ADMIN', 'EMPLOYEE']),
    team: z.string().min(1).max(120),
  })
  .strict()
```

## { version } (51)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/job-routes.ts#L30).

```typescript
z.object({ version: z.number().int().positive() }).strict().parse(req.body)
```

## uuid (52)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/job-service.ts#L13).

```typescript
z.string().uuid()
```

## base (53)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/job-service.ts#L14).

```typescript
z
  .object({
    name: z.string().trim().min(1).max(160),
    code: z
      .string()
      .trim()
      .toUpperCase()
      .regex(/^[A-Z0-9][A-Z0-9_-]{0,39}$/),
    description: z.string().trim().max(2000).default(''),
  })
  .strict()
```

## schemas (54)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/job-service.ts#L25).

```typescript
{
  families: base,
  disciplines: base.extend({ jobFamilyId: uuid }),
  roles: base.extend({ jobFamilyId: uuid, disciplineId: uuid }),
  levels: base.extend({ rank: z.number().int().min(0).max(10000) }),
  positions: base.extend({
    organizationalUnitId: uuid,
    roleId: uuid,
    jobLevelId: uuid,
    reportsToPositionId: uuid.nullable(),
  }),
}
```

## querySchema (55)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/job-service.ts#L74).

```typescript
z
  .object({
    search: z.string().trim().max(160).default(''),
    page: z.coerce.number().int().min(1).max(100000).default(1),
    pageSize: z.coerce.number().int().min(1).max(100).default(25),
    status: z.enum(['active', 'archived', 'all']).default('active'),
    sort: z.enum(['name', 'code', 'updated']).default('name'),
  })
  .strict()
```

## input (56)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/job-service.ts#L206).

```typescript
(
      id ? schemas[kind].extend({ version: z.number().int().positive() }) : schemas[kind]
    ).parse(raw) as Record<string, SqlParam>
```

## { version } (57)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-routes.ts#L39).

```typescript
z.object({ version: z.number().int().positive() }).strict().parse(req.body)
```

## id (58)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-service.ts#L12).

```typescript
z.string().uuid()
```

## unitInput (59)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-service.ts#L13).

```typescript
z
  .object({
    name: z.string().trim().min(1).max(160),
    code: z
      .string()
      .trim()
      .toUpperCase()
      .regex(/^[A-Z0-9][A-Z0-9_-]{0,39}$/),
    unitType: z.enum(unitTypes),
    parentId: id.nullable(),
    description: z.string().trim().max(2000).default(''),
  })
  .strict()
```

## listInput (60)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-service.ts#L26).

```typescript
z
  .object({
    page: z.coerce.number().int().min(1).max(100000).default(1),
    pageSize: z.coerce.number().int().min(1).max(100).default(25),
    search: z.string().trim().max(160).default(''),
    status: z.enum(['active', 'archived', 'all']).default('active'),
    unitType: z.enum(unitTypes).optional(),
    parentId: z.union([id, z.literal('root')]).optional(),
    sort: z.enum(['name', 'code', 'updated']).default('name'),
  })
  .strict()
```

## input (61)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-service.ts#L196).

```typescript
(
      unitId ? unitInput.extend({ version: z.number().int().positive() }) : unitInput
    ).parse(raw)
```

## { positionId, version } (62)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-service.ts#L312).

```typescript
z
      .object({ positionId: id.nullable(), version: z.number().int().positive() })
      .strict()
      .parse(raw)
```

## { page, pageSize, status } (63)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-service.ts#L347).

```typescript
z
        .object({
          page: z.coerce.number().int().min(1).max(100000).default(1),
          pageSize: z.coerce.number().int().min(1).max(100).default(25),
          status: z.enum(['active', 'ended', 'all']).default('active'),
        })
        .strict()
        .parse(query)
```

## input (64)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-service.ts#L414).

```typescript
z
      .object({
        employeeId: id,
        membershipType: z.enum(['member', 'lead', 'manager', 'owner', 'contributor']),
        isPrimary: z.boolean(),
        startedAt: z.iso.datetime({ offset: true }).optional(),
      })
      .strict()
      .parse(raw)
```

## id (65)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-service.ts#L24).

```typescript
z.string().uuid()
```

## text (66)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-service.ts#L25).

```typescript
(max: number) => z.string().trim().max(max)
```

## profileInput (67)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-service.ts#L26).

```typescript
z
  .object({
    name: z.string().trim().min(1).max(160),
    legalName: text(200),
    code: z
      .string()
      .trim()
      .toUpperCase()
      .regex(/^[A-Z0-9][A-Z0-9_-]{0,39}$/),
    slug: z
      .string()
      .trim()
      .toLowerCase()
      .regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/)
      .max(80),
    website: z.union([z.literal(''), z.url().startsWith('https://')]),
    industry: text(160),
    country: z.union([z.literal(''), z.string().regex(/^[A-Z]{2}$/)]),
    timezone: z.string().refine((value) => {
      try {
        new Intl.DateTimeFormat('en', { timeZone: value });
        return true;
      } catch {
        return false;
      }
    }),
    locale: z.string().regex(/^[a-z]{2}(?:-[A-Z]{2})?$/),
    version: z.number().int().positive(),
  })
  .strict()
```

## employeeInput (68)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-service.ts#L56).

```typescript
z
  .object({
    displayName: z.string().trim().min(1).max(200),
    email: z
      .email()
      .max(254)
      .transform((value) => value.toLowerCase()),
    employeeNumber: text(60).nullable(),
    employmentType: z.enum(['employee', 'contractor', 'external']),
  })
  .strict()
```

## pageInput (69)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-service.ts#L67).

```typescript
z
  .object({
    page: z.coerce.number().int().min(1).max(100000).default(1),
    pageSize: z.coerce.number().int().min(1).max(100).default(25),
    search: text(160).default(''),
    status: z.enum(['active', 'inactive', 'all']).default('active'),
  })
  .strict()
```

## domainInput (70)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-service.ts#L75).

```typescript
z
  .object({
    domain: z.string().trim().max(253),
    domainType: z.enum(['custom_domain', 'platform_subdomain']),
  })
  .strict()
```

## input (71)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-service.ts#L479).

```typescript
employeeInput
      .extend({
        version: z.number().int().positive(),
        employmentStatus: z.enum(['active', 'inactive']),
      })
      .parse(raw)
```

## input (72)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-service.ts#L523).

```typescript
z
      .object({ positionId: id.nullable(), version: z.number().int().positive() })
      .strict()
      .parse(raw)
```

## input (73)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-service.ts#L604).

```typescript
z
      .object({ status: z.enum(['active', 'suspended']), version: z.number().int().positive() })
      .strict()
      .parse(raw)
```

## memberInput (74)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization-routes.ts#L7).

```typescript
z
  .object({
    email: z.email().max(254),
    displayName: z.string().trim().min(1).max(200),
    team: z.string().trim().min(1).max(120),
  })
  .strict()
```

## { purpose } (75)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization-routes.ts#L81).

```typescript
z
      .object({ purpose: z.enum(['activate', 'reset']) })
      .strict()
      .parse(req.body)
```

## id (76)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization-routes.ts#L85).

```typescript
z.string().uuid().parse(req.params['id'])
```

## text (77)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/quality/quality-history.ts#L22).

```typescript
z.string().min(1).max(200)
```

## historyRecordSchema (78)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/quality/quality-history.ts#L23).

```typescript
z
  .object({
    v: z.literal(HISTORY_VERSION),
    runId: text,
    runAt: z.iso.datetime(),
    commit: z.string().max(64).nullable(),
    provider: text,
    model: text,
    judgeModel: text,
    blueprint: text,
    suite: text,
    task: text,
    trial: z.number().int().min(1).max(100),
    passed: z.boolean(),
    score: z.number().min(0).max(1),
    passThreshold: z.number().min(0).max(1),
    failedGates: z.array(text).max(50),
    runStatus: text,
    tokens: z.number().int().min(0),
    estimatedCostUsd: z.number().min(0).nullable(),
  })
  .strict()
```

## overviewQuery (79)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/quality/quality-service.ts#L8).

```typescript
z
  .object({
    days: z.coerce.number().int().min(7).max(730).default(182),
    blueprint: z
      .string()
      .regex(/^[a-z0-9.-]{1,120}(@[0-9A-Za-z.+-]{1,40})?$/)
      .optional(),
  })
  .strict()
```

## [organizationId, employeeId, purpose] (80)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/recover-member.ts#L9).

```typescript
z
  .tuple([z.string().uuid(), z.string().uuid(), z.enum(['activate', 'reset'])])
  .parse(process.argv.slice(2))
```

## identitySchema (81)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/runtime/runtime-identity.ts#L29).

```typescript
z
  .object({
    id: z.string().regex(/^[a-z0-9][a-z0-9._-]{0,119}$/),
    /** Base64 DER SubjectPublicKeyInfo of an Ed25519 key. */
    publicKeySpki: z
      .string()
      .regex(/^[A-Za-z0-9+/]+={0,2}$/)
      .max(200),
    organizations: z
      .array(z.string().regex(/^(\*|[A-Za-z0-9_.:-]{1,120})$/))
      .min(1)
      .max(1000),
    runtimeProfiles: z
      .array(z.string().regex(/^[a-z0-9][a-z0-9._-]{0,99}$/))
      .min(1)
      .max(50),
    role: z.enum(['agent', 'execution']).optional(),
  })
  .strict()
```

## registrySchema (82)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/runtime/runtime-identity.ts#L48).

```typescript
z.array(identitySchema).max(100)
```

## { version } (83)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/secrets/model-credential-routes.ts#L28).

```typescript
z.object({ version: z.number().int().positive() }).strict().parse(req.body)
```

## bindingSchema (84)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/secrets/model-credentials.ts#L13).

```typescript
z
  .object({
    secretRef: z.string().regex(secretReferencePattern),
    /** The version being replaced; omitted when the provider has no binding yet. */
    version: z.number().int().positive().optional(),
  })
  .strict()
```

## alertId (85)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/model-budget-alerts.ts#L31).

```typescript
z.string().uuid()
```

## price (86)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/model-prices.ts#L14).

```typescript
z.number().int().min(0).max(MAX_PRICE)
```

## provider (87)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/model-prices.ts#L15).

```typescript
z.string().regex(/^[a-zA-Z0-9._-]{1,80}$/)
```

## model (88)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/model-prices.ts#L16).

```typescript
z.string().regex(/^[a-zA-Z0-9._:/-]{1,160}$/)
```

## priceInput (89)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/model-prices.ts#L17).

```typescript
z
  .object({
    provider,
    model,
    inputMicrosPerMillionTokens: price,
    outputMicrosPerMillionTokens: price,
    expectedPriceId: z.string().uuid().nullable(),
  })
  .strict()
```

## removalInput (90)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/model-prices.ts#L26).

```typescript
z.object({ provider, model, expectedPriceId: z.string().uuid() }).strict()
```

## limit (91)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/model-spending-service.ts#L43).

```typescript
z.number().int().positive().max(MAX_LIMIT).nullable()
```

## costLimit (92)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/model-spending-service.ts#L44).

```typescript
z.number().int().positive().max(MAX_COST_LIMIT).nullable()
```

## budgetInput (93)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/model-spending-service.ts#L45).

```typescript
z
  .object({
    monthlyTokenLimit: limit,
    runTokenLimit: limit,
    currency: z
      .string()
      .regex(/^[A-Z]{3}$/)
      .optional(),
    monthlyCostLimitMicros: costLimit.optional(),
    runCostLimitMicros: costLimit.optional(),
    alertThresholdsPercent: z
      .array(z.number().int().min(1).max(99))
      .max(5)
      .refine((values) => new Set(values).size === values.length, 'duplicate threshold')
      .optional(),
    version: z.number().int().min(0),
  })
  .strict()
```

## createInput (94)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/webhooks/alert-webhook-service.ts#L44).

```typescript
z
  .object({ url: z.string().max(500), description: z.string().trim().max(200) })
  .strict()
```

## statusInput (95)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/webhooks/alert-webhook-service.ts#L47).

```typescript
z
  .object({ status: z.enum(['ACTIVE', 'DISABLED']), version: z.number().int().min(1) })
  .strict()
```

## webhookId (96)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/webhooks/alert-webhook-service.ts#L50).

```typescript
z.string().uuid()
```

## slug (97)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L11).

```typescript
z.string().regex(/^[a-z0-9][a-z0-9._-]{0,99}$/)
```

## semver (98)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L12).

```typescript
z.string().regex(/^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$/)
```

## action (99)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L13).

```typescript
z.string().regex(/^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$/)
```

## capability (100)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L14).

```typescript
z.string().regex(/^[a-z][A-Za-z0-9]*(\.[a-z][A-Za-z0-9_]*)+$/)
```

## text (101)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L15).

```typescript
(max: number) => z.string().trim().min(1).max(max)
```

## reference (102)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L16).

```typescript
z.object({ id: slug, version: semver }).strict()
```

## skillDefinitionSchema (103)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L19).

```typescript
z
  .object({
    id: slug,
    version: semver,
    title: text(120),
    description: text(1000),
    requires: z
      .object({
        tools: z.array(slug).max(20).refine(unique),
        connectorCapabilities: z.array(capability).max(20).refine(unique),
      })
      .strict(),
    activatesWhen: z.object({ workflows: z.array(slug).max(50).refine(unique) }).strict(),
  })
  .strict() satisfies z.ZodType<SkillDefinition>
```

## toolDefinitionSchema (104)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L35).

```typescript
z
  .object({
    id: slug,
    version: semver,
    description: text(1000),
    risk: z.enum(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']),
    executionLocation: z.enum(['LOCAL', 'EXECUTION_RUNTIME', 'CONTROL_PLANE']),
    sideEffects: z.enum(['NONE', 'LOCAL_WRITE', 'EXTERNAL_WRITE']),
    governedActions: z.array(action).max(50).refine(unique),
    timeoutMs: z.number().int().min(1000).max(3_600_000),
  })
  .strict() satisfies z.ZodType<ToolDefinition>
```

## workflowDefinitionSchema (105)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L48).

```typescript
z
  .object({
    id: slug,
    version: semver,
    title: text(120),
    description: text(1000),
    steps: z
      .array(
        z.object({ id: slug, title: text(120), skill: slug, action: action.optional() }).strict(),
      )
      .min(1)
      .max(50)
      .refine((steps) => unique(steps.map((step) => step.id)), 'Step ids must be unique.'),
  })
  .strict() satisfies z.ZodType<WorkflowDefinition>
```

## question (106)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L64).

```typescript
z
  .object({
    id: z.string().regex(/^[a-zA-Z][a-zA-Z0-9]{0,59}$/),
    label: text(120),
    type: z.enum(['text', 'url', 'multiselect']),
    required: z.boolean(),
    options: z.array(text(80)).min(1).max(50).refine(unique).optional(),
    scope: z.enum(['INSTALLATION', 'AGENT']),
  })
  .strict()
  .refine(
    (q) => (q.type === 'multiselect') === Boolean(q.options),
    'Only multiselect has options.',
  )
```

## issueKey (107)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L79).

```typescript
z.string().regex(/^[A-Z][A-Z0-9]{1,9}-[1-9]\d{0,8}$/)
```

## relativePath (108)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L80).

```typescript
z.string().regex(/^[A-Za-z0-9._-]+(\/[A-Za-z0-9._-]+)*$/)
```

## answers (109)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L81).

```typescript
z.record(z.string(), z.union([z.string(), z.array(z.string())]))
```

## evaluationTask (110)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L82).

```typescript
z
  .object({
    objective: text(500),
    workflow: slug,
    workItemKey: issueKey.optional(),
    inputs: z.record(z.string(), z.string().max(2000)).optional(),
  })
  .strict()
```

## blueprintVersions (111)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L90).

```typescript
z.array(semver).min(1).max(20).refine(unique).optional()
```

## weight (112)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L91).

```typescript
z.number().positive().max(100)
```

## needles (113)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L92).

```typescript
z.array(text(200)).min(1).max(20).optional()
```

## check (114)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L93).

```typescript
<T extends z.ZodRawShape>(shape: T) =>
  z.object({ id: slug, weight, required: z.boolean().optional(), ...shape }).strict()
```

## qualityTaskSchema (115)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L96).

```typescript
z
  .object({
    id: slug,
    title: text(200),
    blueprintVersions,
    answers,
    task: evaluationTask,
    approve: z.array(action).max(20).refine(unique),
    executionResults: z
      .array(
        z
          .object({
            operation: z.enum(['command', 'dependencies.install', 'playwright.run']),
            match: text(300),
            status: z.enum(['SUCCEEDED', 'FAILED']),
            output: z.string().max(20_000),
          })
          .strict(),
      )
      .max(50)
      .optional(),
    budget: z
      .object({
        maxTurns: z.number().int().min(1).max(50),
        maxInputTokens: z.number().int().min(1000).max(5_000_000),
        maxOutputTokens: z.number().int().min(100).max(500_000),
      })
      .strict(),
    checks: z
      .array(
        z.discriminatedUnion('kind', [
          check({ kind: z.enum(['tool-called', 'tool-not-called']), tool: slug }),
          check({ kind: z.enum(['action-executed', 'action-not-executed']), action }),
          check({ kind: z.literal('no-denials') }),
          check({
            kind: z.literal('run-status'),
            status: z.enum(['COMPLETED', 'CANCELLED', 'FAILED']),
          }),
          check({
            kind: z.literal('artifact'),
            type: z.enum(['report', 'test_report']),
            contains: needles,
          }),
          check({
            kind: z.literal('file-written'),
            pathIncludes: z.string().regex(/^[A-Za-z0-9._/-]{1,200}$/),
            contains: needles,
          }),
        ]),
      )
      .max(30),
    rubric: z.array(z.object({ id: slug, description: text(500), weight }).strict()).max(20),
    passThreshold: z.number().min(0).max(1),
  })
  .strict()
  .refine((task) => task.checks.length + task.rubric.length > 0, 'A task needs a check.')
  .refine(
    (task) => unique([...task.checks.map((c) => c.id), ...task.rubric.map((c) => c.id)]),
    'Check and criterion ids must be unique.',
  )
```

## evaluationSuiteSchema (116)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L157).

```typescript
z
  .object({
    id: slug,
    blueprintId: z.string().regex(/^[a-z0-9][a-z0-9-]*(\.[a-z0-9][a-z0-9-]*)+$/),
    title: text(120),
    world: z
      .object({
        issueProjects: z
          .array(z.string().regex(/^[A-Z][A-Z0-9]{1,9}$/))
          .max(20)
          .refine(unique),
        issues: z
          .array(
            z
              .object({
                key: issueKey,
                type: z.enum(['Bug', 'Task', 'Story']),
                summary: text(255),
                description: text(5000),
              })
              .strict(),
          )
          .max(50),
        repositories: z
          .array(z.string().regex(/^[A-Za-z0-9][A-Za-z0-9-]{0,38}\/[A-Za-z0-9._-]{1,100}$/))
          .max(20)
          .refine(unique),
        repositoryFiles: z.record(relativePath, z.string().max(20_000)),
      })
      .strict(),
    scenarios: z
      .array(
        z
          .object({
            id: slug,
            title: text(200),
            blueprintVersions,
            answers,
            task: evaluationTask,
            steps: z
              .array(
                z
                  .object({
                    tool: slug,
                    input: z.record(z.string(), z.unknown()),
                    expect: z
                      .object({
                        outcome: z.enum(['SUCCEEDED', 'FAILED', 'NOT_AVAILABLE']),
                        code: z
                          .string()
                          .regex(/^[A-Z][A-Z0-9_]*$/)
                          .optional(),
                        contains: text(500).optional(),
                        approval: z
                          .object({ action, decision: z.enum(['APPROVED', 'REJECTED']) })
                          .strict()
                          .optional(),
                      })
                      .strict()
                      .refine(
                        (e) => (e.outcome === 'FAILED') === Boolean(e.code),
                        'A FAILED step names its error code, and only a FAILED step does.',
                      ),
                  })
                  .strict(),
              )
              .min(1)
              .max(30),
            expect: z
              .object({
                offeredTools: z.array(slug).max(50).refine(unique),
                runStatus: z.enum(['COMPLETED', 'CANCELLED', 'FAILED']),
                executedActions: z.array(action).max(30),
              })
              .strict(),
          })
          .strict(),
      )
      .min(1)
      .max(50)
      .refine((items) => unique(items.map((item) => item.id)), 'Scenario ids must be unique.'),
    qualityTasks: z
      .array(qualityTaskSchema)
      .max(50)
      .refine((items) => unique(items.map((item) => item.id)), 'Quality task ids must be unique.')
      .optional(),
  })
  .strict() satisfies z.ZodType<EvaluationSuiteDefinition>
```

## blueprintVersionSchema (117)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/catalog-schemas.ts#L246).

```typescript
z
  .object({
    id: z.string().regex(/^[a-z0-9][a-z0-9-]*(\.[a-z0-9][a-z0-9-]*)+$/),
    version: semver,
    title: text(120),
    department: text(120),
    role: slug,
    mission: text(1000),
    persona: z.object({ profile: slug }).strict(),
    runtime: z.object({ profile: slug, isolation: z.enum(['sandboxed', 'local']) }).strict(),
    model: z.object({ profile: slug }).strict(),
    skills: z.array(reference).max(100),
    tools: z.array(reference).max(100),
    workflows: z.array(reference).max(100),
    connectors: z
      .array(
        z
          .object({
            capability: z.string().regex(/^[a-z][A-Za-z0-9]{0,59}$/),
            capabilities: z.array(capability).min(1).max(20).refine(unique),
            selection: z
              .object({
                questionId: z.string().min(1).max(60),
                providers: z.record(text(80), slug),
              })
              .strict(),
          })
          .strict(),
      )
      .max(20),
    mcp: z
      .array(
        z
          .object({
            id: slug,
            whenAnswer: z
              .object({ questionId: z.string().min(1).max(60), includes: text(80) })
              .strict()
              .optional(),
          })
          .strict(),
      )
      .max(20),
    memory: z.object({ profile: slug }).strict(),
    knowledge: z.object({ sources: z.array(slug).max(50).refine(unique) }).strict(),
    policy: z
      .object({ profile: slug, actions: z.array(action).min(1).max(100).refine(unique) })
      .strict(),
    evaluations: z.object({ suite: slug }).strict(),
    questionnaire: z
      .array(question)
      .max(50)
      .refine((items) => unique(items.map((item) => item.id)), 'Question ids must be unique.'),
  })
  .strict() satisfies z.ZodType<AgentBlueprintVersionDefinition>
```

## uuid (118)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts#L39).

```typescript
z.uuid()
```

## recordId (119)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts#L42).

```typescript
z.string().regex(/^[A-Za-z0-9_.:-]{1,120}$/)
```

## timestamp (120)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts#L43).

```typescript
z.iso.datetime({ offset: true })
```

## digest (121)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts#L44).

```typescript
z.string().regex(/^[a-f0-9]{64}$/)
```

## slug (122)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts#L45).

```typescript
z.string().regex(/^[a-z0-9][a-z0-9._-]{0,99}$/)
```

## executionOperationSchema (123)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts#L85).

```typescript
z.discriminatedUnion('kind', [
  z
    .object({
      kind: z.literal('git.checkout'),
      repositoryUrl: url(['https:', 'file:']),
      ref: gitRef,
      path: workspacePathSchema.refine((value) => value !== '.', 'checkout needs a subdirectory'),
    })
    .strict(),
  z.object({ kind: z.literal('git.status'), path: workspacePathSchema }).strict(),
  z.object({ kind: z.literal('file.read'), path: workspacePathSchema }).strict(),
  z
    .object({
      kind: z.literal('file.write'),
      path: workspacePathSchema.refine((value) => value !== '.', 'write needs a file path'),
      content: z
        .string()
        .refine(
          (value) => new TextEncoder().encode(value).byteLength <= MAX_WRITE_BYTES,
          `content must be at most ${MAX_WRITE_BYTES} bytes`,
        ),
    })
    .strict(),
  z
    .object({
      kind: z.literal('command'),
      command: slug,
      args: z.array(z.string().max(1000)).max(50),
      cwd: workspacePathSchema,
    })
    .strict(),
  z
    .object({
      kind: z.literal('playwright.run'),
      project: slug,
      baseUrl: url(['https:', 'http:']),
      path: workspacePathSchema.optional(),
    })
    .strict(),
  z
    .object({
      kind: z.literal('dependencies.install'),
      path: workspacePathSchema,
      registryUrl: url(['https:', 'http:']).refine(
        (value) => !new URL(value).search && !new URL(value).hash,
        'registryUrl must not have a query or fragment',
      ),
    })
    .strict(),
]) satisfies z.ZodType<ExecutionOperation>
```

## limitsSchema (124)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts#L147).

```typescript
z
  .object({
    timeoutMs: z.number().int().min(1000).max(3_600_000),
    cpuMillis: z.number().int().min(1).max(64_000),
    memoryMb: z.number().int().min(64).max(65_536),
    maxProcesses: z.number().int().min(1).max(1024),
    network: z
      .object({
        mode: z.enum(['NONE', 'ALLOW_LIST']),
        allowedHosts: z.array(z.string().max(253)).max(20),
      })
      .strict(),
  })
  .strict()
```

## signedExecutionGrantSchema (125)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts#L162).

```typescript
z
  .object({
    payload: z
      .object({
        kind: z.literal(EXECUTION_GRANT_KIND),
        grantId: uuid,
        requestId: uuid,
        action: z.string().regex(/^[a-z][a-z0-9_]*(?:\.[a-z][a-z0-9_]*){1,5}$/),
        correlation: z
          .object({
            organizationId: recordId,
            employeeId: recordId,
            agentId: recordId,
            threadId: uuid,
            runId: uuid,
            stepId: uuid,
            toolCallId: uuid,
          })
          .strict(),
        operationKind: z.enum([
          'git.checkout',
          'git.status',
          'file.read',
          'file.write',
          'command',
          'playwright.run',
          'dependencies.install',
        ]),
        operationDigest: digest,
        isolation: z.enum(['sandboxed', 'local']),
        limits: limitsSchema,
        credential: z
          .object({
            leaseId: uuid,
            provider: z.enum(sourceControlProviders),
            gitHost: hostname,
          })
          .strict()
          .optional(),
        issuedAt: timestamp,
        expiresAt: timestamp,
      })
      .strict(),
    signature: z
      .string()
      .regex(/^[A-Za-z0-9+/]+={0,2}$/)
      .max(200),
    algorithm: z.literal('Ed25519'),
    keyId: digest,
  })
  .strict() satisfies z.ZodType<SignedExecutionGrant>
```

## requestSchema (126)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts#L221).

```typescript
z
  .object({
    protocol: z.literal(EXECUTION_PROTOCOL_V1),
    grant: z.unknown(),
    operation: z.unknown(),
  })
  .strict()
```

## errorSchema (127)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts#L240).

```typescript
z
  .object({ code: z.string().regex(/^[A-Z][A-Z0-9_]{1,63}$/), message: z.string().max(2000) })
  .strict()
```

## responseSchema (128)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts#L243).

```typescript
z
  .object({
    result: z
      .object({
        requestId: z.string().max(120),
        status: z.enum(['SUCCEEDED', 'FAILED', 'TIMED_OUT', 'DENIED']),
        exitCode: z.number().int().optional(),
        artifactIds: z.array(uuid).max(50),
        durationMs: z.number().int().min(0),
        error: errorSchema.optional(),
      })
      .strict(),
    workspace: z
      .object({
        id: uuid,
        state: z.enum(['PROVISIONING', 'READY', 'IN_USE', 'SUSPENDED', 'LOST', 'DESTROYED']),
      })
      .strict(),
    output: z.string().max(300_000),
    truncated: z.boolean(),
    artifacts: z.array(artifactRegistrationSchema).max(50),
  })
  .strict()
```

## redeemRequestSchema (129)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts#L269).

```typescript
z.object({ leaseId: uuid, grant: z.unknown() }).strict()
```

## redeemResponseSchema (130)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts#L278).

```typescript
z
  .object({
    leaseId: uuid,
    credential: z
      .object({
        scheme: z.literal('basic'),
        username: z.string().regex(/^[A-Za-z0-9._-]{1,100}$/),
        password: z
          .string()
          .min(1)
          .max(4096)
          .regex(/^[\x21-\x7e]+$/),
      })
      .strict(),
    expiresAt: timestamp,
  })
  .strict()
```

## releaseRequestSchema (131)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts#L303).

```typescript
z
  .object({ leaseId: uuid, grantId: uuid, outcome: z.enum(credentialReleaseOutcomes) })
  .strict()
```

## executionArtifactUploadSchema (132)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts#L321).

```typescript
z
  .object({
    grant: z.unknown(),
    artifact: artifactUploadDescriptorSchema,
    content: artifactContentSchema,
  })
  .strict()
```

## executionArtifactAuthorizeSchema (133)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts#L329).

```typescript
z
  .object({ grant: z.unknown(), artifact: directArtifactDescriptorSchema })
  .strict()
```

## executionArtifactCompleteSchema (134)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/execution-runtime/v1/schemas.ts#L340).

```typescript
z
  .object({ grant: z.unknown(), artifactId: z.uuid() })
  .strict()
```

## recordId (135)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L81).

```typescript
z.string().regex(/^[A-Za-z0-9_.:-]{1,120}$/)
```

## uuid (136)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L82).

```typescript
z.uuid()
```

## timestamp (137)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L83).

```typescript
z.iso.datetime({ offset: true })
```

## shortText (138)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L84).

```typescript
z.string().trim().min(1).max(200)
```

## digest (139)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L85).

```typescript
z.string().regex(/^[a-f0-9]{64}$/)
```

## semver (140)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L86).

```typescript
z.string().regex(/^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$/)
```

## slug (141)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L87).

```typescript
z.string().regex(/^[a-z0-9][a-z0-9._-]{0,99}$/)
```

## errorSchema (142)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L88).

```typescript
z
  .object({ code: z.string().regex(/^[A-Z][A-Z0-9_]{1,63}$/), message: z.string().max(2000) })
  .strict()
```

## answers (143)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L91).

```typescript
z.record(
  z.string().max(80),
  z.union([z.string().max(2048), z.array(z.string().max(200)).max(50)]),
)
```

## capability (144)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L95).

```typescript
z
  .object({ action: z.string().max(120), outcome: z.enum(['ALLOW', 'REQUIRE_APPROVAL', 'DENY']) })
  .strict()
```

## keySource (145)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L98).

```typescript
z.enum(['EMPLOYEE_BYOK', 'ORGANIZATION_MANAGED'])
```

## correlationSchema (146)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L100).

```typescript
z
  .object({
    organizationId: recordId,
    employeeId: recordId,
    agentId: recordId,
    threadId: uuid,
    runId: uuid,
    stepId: uuid.optional(),
    toolCallId: uuid.optional(),
    actionId: uuid.optional(),
  })
  .strict() satisfies z.ZodType<RuntimeCorrelation>
```

## taskSpecSchema (147)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L113).

```typescript
z
  .object({
    objective: z.string().trim().min(1).max(2000),
    workflow: slug.optional(),
    workItem: z
      .object({ system: slug, key: z.string().min(1).max(120), url: z.url().max(2048).optional() })
      .strict()
      .optional(),
    inputs: z
      .record(
        z.string().max(80),
        z.union([
          z.string().max(2048),
          z.number(),
          z.boolean(),
          z.array(z.string().max(200)).max(50),
        ]),
      )
      .refine((value) => Object.keys(value).length <= 50, 'At most 50 inputs.'),
  })
  .strict() satisfies z.ZodType<TaskSpec>
```

## artifactRegistrationSchema (148)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L135).

```typescript
z
  .object({
    id: uuid,
    type: z.enum(artifactTypes),
    mediaType: z.string().regex(/^[a-z0-9!#$&^_.+-]{1,64}\/[a-z0-9!#$&^_.+-]{1,64}$/i),
    name: z
      .string()
      .trim()
      .min(1)
      .max(255)
      .regex(/^[^/\\\0]+$/),
    storageReference: z.string().max(600).regex(artifactStorageReferencePattern),
    checksum: z.object({ algorithm: z.literal('sha256'), value: digest }).strict(),
    sizeBytes: z
      .number()
      .int()
      .min(0)
      .max(5 * 1024 ** 3),
    retentionPolicy: z.enum(artifactRetentionPolicies),
  })
  .strict() satisfies z.ZodType<ArtifactRegistration>
```

## payloadSchemas (149)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L157).

```typescript
{
  'run.started': z.object({ runtimeSessionId: uuid, kernel: slug }).strict(),
  'run.paused': z.object({ reason: z.literal('APPROVAL_REQUIRED'), actionId: uuid }).strict(),
  'run.resumed': z.object({ approvalId: uuid }).strict(),
  'run.completed': z
    .object({ summary: z.string().max(4000), artifactIds: z.array(uuid).max(200) })
    .strict(),
  'run.failed': z.object({ error: errorSchema, retryable: z.boolean() }).strict(),
  'run.cancelled': z.object({ reason: z.string().trim().min(1).max(500) }).strict(),
  'step.started': z.object({ kind: z.enum(runStepKinds), title: shortText }).strict(),
  'step.completed': z.object({ outputSummary: z.string().max(4000).optional() }).strict(),
  'step.failed': z.object({ error: errorSchema }).strict(),
  'agent.message': z.object({ content: z.string().trim().min(1).max(20_000) }).strict(),
  'agent.reasoning.started': z.object({}).strict() as z.ZodType<Record<string, never>>,
  'model.requested': z.object({ modelProfile: slug, capability: slug }).strict(),
  'model.responded': z
    .object({
      modelProfile: slug,
      inputTokens: z.number().int().min(0),
      outputTokens: z.number().int().min(0),
      latencyMs: z.number().int().min(0),
      finishReason: z.string().max(40),
    })
    .strict(),
  'tool.requested': z
    .object({ toolCallId: uuid, toolId: slug, toolVersion: semver, inputDigest: digest })
    .strict(),
  'tool.started': z.object({ toolCallId: uuid }).strict(),
  'tool.completed': z
    .object({
      toolCallId: uuid,
      outputDigest: digest,
      durationMs: z.number().int().min(0),
      artifactIds: z.array(uuid).max(200),
    })
    .strict(),
  'tool.failed': z
    .object({ toolCallId: uuid, error: errorSchema, durationMs: z.number().int().min(0) })
    .strict(),
  'artifact.created': z.object({ artifact: artifactRegistrationSchema }).strict(),
}
```

## envelopeSchema (150)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L199).

```typescript
z
  .object({
    protocol: z.string(),
    eventId: uuid,
    runId: uuid,
    threadId: uuid,
    stepId: uuid.optional(),
    sequence: z.number().int().min(1).max(1_000_000),
    type: z.string(),
    occurredAt: timestamp,
    correlation: correlationSchema,
    payload: z.unknown(),
  })
  .strict()
```

## manifestV1Schema (151)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L260).

```typescript
z
  .object({
    apiVersion: z.literal('agents-foundry/v1'),
    manifestId: uuid,
    agentId: recordId,
    organizationId: recordId,
    employeeId: recordId,
    blueprint: z.object({ id: z.string().max(120), version: semver }).strict(),
    model: z
      .object({
        provider: z.string().max(80),
        model: z.string().max(160),
        credentialMode: keySource,
      })
      .strict(),
    answers,
    capabilities: z.array(capability).max(100),
    conversationSync: z.literal('REQUIRED'),
    policyVersion: z.string().max(80),
    issuedAt: timestamp,
  })
  .strict()
```

## versionedReference (152)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L283).

```typescript
z.object({ id: slug, version: semver }).strict()
```

## manifestV2PayloadSchema (153)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L285).

```typescript
z
  .object({
    apiVersion: z.literal('agents-foundry/v2'),
    kind: z.literal('AgentManifest'),
    metadata: z
      .object({
        manifestId: uuid,
        agentId: recordId,
        organizationId: recordId,
        employeeId: recordId,
        issuedAt: timestamp,
        blueprint: z
          .object({ id: z.string().max(120), version: semver, digest: digest.optional() })
          .strict(),
        installationId: uuid.optional(),
      })
      .strict(),
    identity: z.object({ name: shortText, role: slug, department: shortText }).strict(),
    persona: z.object({ profile: slug }).strict(),
    runtime: z.object({ profile: slug, isolation: z.enum(['sandboxed', 'local']) }).strict(),
    model: z
      .object({
        profile: slug,
        provider: z.string().max(80),
        model: z.string().max(160),
        credentialMode: keySource,
      })
      .strict(),
    skills: z.array(versionedReference).max(100),
    tools: z.array(slug).max(100),
    connectors: z
      .array(z.object({ id: slug, capabilities: z.array(z.string().max(120)).max(50) }).strict())
      .max(50),
    mcp: z.array(slug).max(50),
    memory: z.object({ profile: slug }).strict(),
    knowledge: z.object({ sources: z.array(slug).max(50) }).strict(),
    policies: z
      .object({
        profile: slug,
        policyVersion: z.string().max(80),
        capabilities: z.array(capability).max(100),
      })
      .strict(),
    workflows: z.array(slug).max(100),
    evaluations: z.object({ suite: slug }).strict(),
    configuration: answers,
    conversationSync: z.literal('REQUIRED'),
  })
  .strict()
```

## signature (154)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L335).

```typescript
{
  signature: z
    .string()
    .regex(/^[A-Za-z0-9+/]+={0,2}$/)
    .max(200),
  algorithm: z.literal('Ed25519'),
  keyId: z.string().regex(/^[a-f0-9]{64}$/),
}
```

## signedManifestV2Schema (155)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L343).

```typescript
z
  .object({ payload: manifestV2PayloadSchema, ...signature })
  .strict() satisfies z.ZodType<SignedAgentManifestV2>
```

## signedManifestV1Schema (156)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L346).

```typescript
z
  .object({ payload: manifestV1Schema, ...signature })
  .strict() satisfies z.ZodType<SignedAgentManifest>
```

## commandBase (157)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L369).

```typescript
{
  protocol: z.literal(RUNTIME_PROTOCOL_V1),
  commandId: uuid,
  issuedAt: timestamp,
  correlation: correlationSchema,
}
```

## commandSchema (158)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L375).

```typescript
z.discriminatedUnion('type', [
  z
    .object({
      ...commandBase,
      type: z.literal('run.submit'),
      run: z
        .object({
          runId: uuid,
          threadId: uuid,
          task: taskSpecSchema,
          runtimeProfile: slug,
          manifest: signedManifestV2Schema,
          workspace: z
            .object({ workspaceId: uuid, persistence: z.enum(['EPHEMERAL', 'PERSISTENT']) })
            .strict()
            .nullable(),
          workflow: workflowDefinitionSchema.optional(),
        })
        .strict(),
    })
    .strict(),
  z
    .object({
      ...commandBase,
      type: z.literal('run.resume'),
      runId: uuid,
      approval: z
        .object({
          approvalId: uuid,
          decision: z.enum(['APPROVED', 'REJECTED']),
          decidedAt: timestamp,
        })
        .strict(),
    })
    .strict(),
  z
    .object({
      ...commandBase,
      type: z.literal('run.cancel'),
      runId: uuid,
      reason: z.string().trim().min(1).max(500),
    })
    .strict(),
  z
    .object({
      ...commandBase,
      type: z.literal('run.recover'),
      runId: uuid,
      reason: z.literal('LEASE_EXPIRED'),
      openStepIds: z.array(uuid).max(200),
    })
    .strict(),
])
```

## actionName (159)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L456).

```typescript
z.string().regex(/^[a-z][a-z0-9_]*(?:\.[a-z][a-z0-9_]*){1,5}$/)
```

## risk (160)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L457).

```typescript
z.enum(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'])
```

## actionRequestSchema (161)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L458).

```typescript
z
  .object({
    protocol: z.literal(RUNTIME_PROTOCOL_V1),
    requestId: uuid,
    correlation: correlationSchema.extend({ stepId: uuid, toolCallId: uuid }).strict(),
    action: actionName,
    toolId: slug,
    toolVersion: semver,
    inputDigest: digest,
    summary: z.string().trim().min(1).max(500),
    parameters: z
      .record(z.string().regex(/^[A-Za-z][A-Za-z0-9_]{0,63}$/), z.unknown())
      .refine((value) => Object.keys(value).length <= 50, 'At most 50 parameters.')
      .optional(),
  })
  .strict()
```

## decisionBase (162)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L487).

```typescript
{ requestId: uuid, risk, reason: z.string().max(500) }
```

## actionDecisionSchema (163)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L488).

```typescript
z.discriminatedUnion('decision', [
  z.object({ ...decisionBase, decision: z.literal('ALLOWED') }).strict(),
  z.object({ ...decisionBase, decision: z.literal('DENIED') }).strict(),
  z
    .object({ ...decisionBase, decision: z.literal('APPROVAL_REQUIRED'), approvalId: uuid })
    .strict(),
])
```

## claimResponseSchema (164)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L504).

```typescript
z
  .object({
    command: z.unknown(),
    lease: z
      .object({
        sessionId: uuid,
        runtimeSequence: z.number().int().min(0).max(1_000_000),
        leaseExpiresAt: timestamp,
      })
      .strict(),
  })
  .strict()
```

## executeRequestSchema (165)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L525).

```typescript
z
  .object({
    protocol: z.literal(RUNTIME_PROTOCOL_V1),
    requestId: uuid,
    correlation: correlationSchema.extend({ stepId: uuid, toolCallId: uuid }).strict(),
  })
  .strict()
```

## executionSchema (166)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L543).

```typescript
z
  .object({
    requestId: uuid,
    status: z.enum(['SUCCEEDED', 'FAILED']),
    result: z.record(z.string().max(64), z.string().max(2048)).optional(),
    error: errorSchema.optional(),
  })
  .strict()
```

## tokens (167)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L561).

```typescript
z.number().int().min(0).max(10_000_000)
```

## modelName (168)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L562).

```typescript
z.string().regex(/^[a-zA-Z0-9._:/-]{1,160}$/)
```

## reservationRequestSchema (169)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L563).

```typescript
z
  .object({
    protocol: z.literal(RUNTIME_PROTOCOL_V1),
    reservationId: uuid,
    correlation: correlationSchema,
    provider: z.string().regex(/^[a-zA-Z0-9._-]{1,80}$/),
    model: modelName,
    estimatedInputTokens: tokens,
    maxOutputTokens: tokens.min(1),
  })
  .strict()
```

## reservationSchema (170)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L587).

```typescript
z.discriminatedUnion('decision', [
  z
    .object({ reservationId: uuid, decision: z.literal('ALLOWED'), maxOutputTokens: tokens.min(1) })
    .strict(),
  z
    .object({
      reservationId: uuid,
      decision: z.literal('DENIED'),
      code: z.literal('MODEL_BUDGET_EXCEEDED'),
      reason: z.string().max(500),
    })
    .strict(),
])
```

## settlementRequestSchema (171)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L609).

```typescript
z
  .object({
    protocol: z.literal(RUNTIME_PROTOCOL_V1),
    reservationId: uuid,
    correlation: correlationSchema,
    inputTokens: tokens,
    outputTokens: tokens,
  })
  .strict()
```

## heartbeatRequestSchema (172)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L632).

```typescript
z
  .object({ protocol: z.literal(RUNTIME_PROTOCOL_V1), runIds: z.array(uuid).max(256) })
  .strict()
```

## heartbeatSchema (173)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L645).

```typescript
z
  .object({ held: z.array(uuid).max(256), lost: z.array(uuid).max(256) })
  .strict()
```

## checkpointBinding (174)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L659).

```typescript
z
  .object({
    manifestId: recordId,
    manifestDigest: digest,
    workflow: slug.nullable(),
    stepId: uuid.nullable(),
    approvalId: uuid.nullable(),
    kernelId: slug,
    runtimeSequence: z.number().int().min(0).max(1_000_000),
  })
  .strict()
```

## checkpointVersion (175)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L670).

```typescript
z.number().int().min(1).max(1_000_000)
```

## checkpointBody (176)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L671).

```typescript
z.string().min(2)
```

## checkpointSaveSchema (177)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L673).

```typescript
z
  .object({
    protocol: z.literal(RUNTIME_PROTOCOL_V1),
    correlation: correlationSchema,
    sessionId: uuid,
    version: checkpointVersion,
    binding: checkpointBinding,
    sha256: digest,
    body: checkpointBody,
  })
  .strict()
```

## checkpointLoadSchema (178)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L696).

```typescript
z
  .object({ protocol: z.literal(RUNTIME_PROTOCOL_V1), correlation: correlationSchema })
  .strict()
```

## checkpointAckSchema (179)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L709).

```typescript
z.object({ runId: uuid, version: checkpointVersion }).strict()
```

## modelCredentialRequestSchema (180)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L737).

```typescript
z
  .object({
    protocol: z.literal(RUNTIME_PROTOCOL_V1),
    correlation: correlationSchema,
    provider: z.string().regex(/^[a-zA-Z0-9._-]{1,80}$/),
  })
  .strict()
```

## modelCredentialSchema (181)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L754).

```typescript
z
  .object({
    provider: z.string().regex(/^[a-zA-Z0-9._-]{1,80}$/),
    apiKey: z.string().min(1).max(8192),
  })
  .strict()
```

## artifactUploadDescriptorSchema (182)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L776).

```typescript
z
  .object({
    id: uuid,
    mediaType: z.string().regex(/^[a-z0-9!#$&^_.+-]{1,64}\/[a-z0-9!#$&^_.+-]{1,64}$/i),
    name: artifactName,
    checksum: z.object({ algorithm: z.literal('sha256'), value: digest }).strict(),
    sizeBytes: z.number().int().min(0).max(MAX_ARTIFACT_UPLOAD_BYTES),
    retentionPolicy: z.enum(artifactRetentionPolicies),
  })
  .strict() satisfies z.ZodType<ArtifactUploadDescriptor>
```

## directArtifactDescriptorSchema (183)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L788).

```typescript
artifactUploadDescriptorSchema
  .extend({
    mediaType: z.enum(directUploadMediaTypes),
    sizeBytes: z.number().int().min(1).max(MAX_DIRECT_ARTIFACT_BYTES),
  })
  .strict()
```

## uploadAuthorizationSchema (184)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L795).

```typescript
z
  .object({
    artifactId: uuid,
    target: z.enum(['STORE', 'CONTROL_PLANE']),
    url: z.string().min(1).max(2000),
    headers: z.record(z.string().max(100), z.string().max(4000)),
    expiresAt: z.iso.datetime(),
  })
  .strict()
```

## artifactUploadRequestSchema (185)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L819).

```typescript
z
  .object({
    protocol: z.literal(RUNTIME_PROTOCOL_V1),
    correlation: correlationSchema.extend({ stepId: uuid }).strict(),
    artifact: artifactUploadDescriptorSchema,
    content: artifactContentSchema,
  })
  .strict()
```

## artifactUploadSchema (186)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts#L837).

```typescript
z
  .object({
    artifactId: uuid,
    storageReference: z.string().max(600).regex(artifactStorageReferencePattern),
    checksum: z.object({ algorithm: z.literal('sha256'), value: digest }).strict(),
    sizeBytes: z.number().int().min(0).max(MAX_DIRECT_ARTIFACT_BYTES),
  })
  .strict()
```

## Related documentation

[API index](README.md) · [Implementation status](../reference/implementation-status.md)
