# Wire and domain contract reference

**Audience:** Developers and API consumers. **Implementation status:** Implemented contracts; availability of execution depends on the implementation matrix.

**Prerequisites:** Read the [HTTP conventions](README.md) and relevant endpoint page.

Extracted at `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These are literal source declarations, not evidence that a corresponding engine exists. Schemas express required fields, defaults, enum values, refinements and unknown-field rejection. Type-only structures still require runtime validation and authorization.

## ConnectorProvider (1)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/actions.ts#L6).

```typescript
export type ConnectorProvider = (typeof connectorProviders)[number];
```

## ConnectorConnectionSettings (2)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/actions.ts#L14).

```typescript
export interface ConnectorConnectionSettings {
  /** Account the API token belongs to (Jira Cloud basic authentication). */
  authEmail?: string;
  /** Issue-tracker project keys the gateway allows. Empty means none (always empty for GitHub). */
  allowedProjects: string[];
  /** Source-control repositories (`owner/name`) the gateway allows (Phase G, GitHub). */
  allowedRepositories?: string[];
}
```

## ConnectorConnection (3)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/actions.ts#L24).

```typescript
export interface ConnectorConnection {
  id: string;
  organizationId: string;
  provider: ConnectorProvider;
  name: string;
  baseUrl: string;
  secretRef: string;
  settings: ConnectorConnectionSettings;
  status: 'ACTIVE' | 'DISABLED';
  version: number;
  createdAt: string;
  updatedAt: string;
}
```

## ConnectorConnectionInput (4)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/actions.ts#L38).

```typescript
export interface ConnectorConnectionInput {
  provider: ConnectorProvider;
  name: string;
  baseUrl: string;
  secretRef: string;
  settings: ConnectorConnectionSettings;
}
```

## OrganizationPolicyOutcome (5)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/actions.ts#L47).

```typescript
export type OrganizationPolicyOutcome = 'REQUIRE_APPROVAL' | 'DENY';
```

## OrganizationActionPolicy (6)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/actions.ts#L49).

```typescript
export interface OrganizationActionPolicy {
  organizationId: string;
  action: string;
  outcome: OrganizationPolicyOutcome;
  reason: string;
  updatedBy: string;
  updatedAt: string;
}
```

## GovernedActionSummary (7)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/actions.ts#L59).

```typescript
export interface GovernedActionSummary {
  action: string;
  defaultOutcome: 'ALLOW' | 'REQUIRE_APPROVAL' | 'DENY';
  risk: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  /** Executed by the control plane through a connector, rather than by the runtime. */
  executedBy: 'CONTROL_PLANE' | 'RUNTIME';
  connectorProvider: ConnectorProvider | null;
  override: OrganizationActionPolicy | null;
}
```

## ActionApprovalStatus (8)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/actions.ts#L70).

```typescript
export type ActionApprovalStatus = 'PENDING' | 'APPROVED' | 'REJECTED' | 'EXPIRED';
```

## ArtifactType (9)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/artifacts.ts#L20).

```typescript
export type ArtifactType = (typeof artifactTypes)[number];
```

## ArtifactRetentionPolicy (10)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/artifacts.ts#L28).

```typescript
export type ArtifactRetentionPolicy = (typeof artifactRetentionPolicies)[number];
```

## ArtifactRegistration (11)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/artifacts.ts#L38).

```typescript
export interface ArtifactRegistration {
  id: string;
  type: ArtifactType;
  mediaType: string;
  name: string;
  storageReference: string;
  checksum: { algorithm: 'sha256'; value: string };
  sizeBytes: number;
  retentionPolicy: ArtifactRetentionPolicy;
}
```

## Artifact (12)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/artifacts.ts#L49).

```typescript
export interface Artifact extends ArtifactRegistration {
  organizationId: string;
  threadId: string;
  runId: string;
  stepId: string | null;
  createdAt: string;
  createdBy: string;
}
```

## ArtifactContentState (13)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/artifacts.ts#L62).

```typescript
export type ArtifactContentState = 'AVAILABLE' | 'DELETED' | 'UNMANAGED';
```

## ArtifactContent (14)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/artifacts.ts#L64).

```typescript
export interface ArtifactContent {
  state: ArtifactContentState;
  /** When retention removes the bytes; null for a legal hold or unmanaged content. */
  expiresAt: string | null;
  deletedAt: string | null;
  deletionReason: string | null;
}
```

## ArtifactSummary (15)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/artifacts.ts#L73).

```typescript
export type ArtifactSummary = Omit<Artifact, 'storageReference'> & { content?: ArtifactContent };
```

## ArtifactUploadAuthorization (16)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/artifacts.ts#L103).

```typescript
export interface ArtifactUploadAuthorization {
  artifactId: string;
  target: 'STORE' | 'CONTROL_PLANE';
  url: string;
  headers: Record<string, string>;
  expiresAt: string;
}
```

## ArtifactUploadDescriptor (17)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/artifacts.ts#L112).

```typescript
export interface ArtifactUploadDescriptor {
  id: string;
  mediaType: string;
  name: string;
  checksum: { algorithm: 'sha256'; value: string };
  sizeBytes: number;
  retentionPolicy: ArtifactRetentionPolicy;
}
```

## ArtifactUpload (18)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/artifacts.ts#L122).

```typescript
export interface ArtifactUpload {
  artifactId: string;
  storageReference: string;
  checksum: { algorithm: 'sha256'; value: string };
  sizeBytes: number;
}
```

## ArtifactRetrieval (19)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/artifacts.ts#L133).

```typescript
export interface ArtifactRetrieval {
  artifactId: string;
  path: string;
  expiresAt: string;
}
```

## EvidenceReference (20)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/artifacts.ts#L140).

```typescript
export interface EvidenceReference {
  artifactId: string;
  description: string;
}
```

## SkillDefinition (21)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L7).

```typescript
export interface SkillDefinition {
  id: string;
  version: string;
  title: string;
  description: string;
  /** Tools and connector capabilities the skill cannot work without. */
  requires: { tools: string[]; connectorCapabilities: string[] };
  /** Workflows in which the runtime may activate the skill. */
  activatesWhen: { workflows: string[] };
}
```

## ToolExecutionLocation (22)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L18).

```typescript
export type ToolExecutionLocation = 'LOCAL' | 'EXECUTION_RUNTIME' | 'CONTROL_PLANE';
```

## ToolSideEffects (23)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L19).

```typescript
export type ToolSideEffects = 'NONE' | 'LOCAL_WRITE' | 'EXTERNAL_WRITE';
```

## ToolDefinition (24)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L22).

```typescript
export interface ToolDefinition {
  id: string;
  version: string;
  description: string;
  risk: ApprovalRisk;
  executionLocation: ToolExecutionLocation;
  sideEffects: ToolSideEffects;
  /** Governed actions the tool can request through the Action Gateway. */
  governedActions: string[];
  timeoutMs: number;
}
```

## WorkflowStepDefinition (25)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L34).

```typescript
export interface WorkflowStepDefinition {
  id: string;
  title: string;
  skill: string;
  /** Governed action this step may request; policy decides the outcome. */
  action?: string;
}
```

## WorkflowDefinition (26)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L42).

```typescript
export interface WorkflowDefinition {
  id: string;
  version: string;
  title: string;
  description: string;
  steps: WorkflowStepDefinition[];
}
```

## ConnectorRequirementDefinition (27)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L51).

```typescript
export interface ConnectorRequirementDefinition {
  capability: string;
  capabilities: string[];
  selection: { questionId: string; providers: Record<string, string> };
}
```

## McpRequirementDefinition (28)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L57).

```typescript
export interface McpRequirementDefinition {
  id: string;
  whenAnswer?: { questionId: string; includes: string };
}
```

## QuestionScope (29)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L63).

```typescript
export type QuestionScope = 'INSTALLATION' | 'AGENT';
```

## CatalogQuestion (30)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L65).

```typescript
export interface CatalogQuestion extends BlueprintQuestion {
  scope: QuestionScope;
}
```

## AgentBlueprintVersionDefinition (31)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L69).

```typescript
export interface AgentBlueprintVersionDefinition {
  id: string;
  version: string;
  title: string;
  department: string;
  role: string;
  mission: string;
  persona: { profile: string };
  runtime: { profile: string; isolation: 'sandboxed' | 'local' };
  model: { profile: string };
  skills: VersionedReference[];
  tools: VersionedReference[];
  workflows: VersionedReference[];
  connectors: ConnectorRequirementDefinition[];
  mcp: McpRequirementDefinition[];
  memory: { profile: string };
  knowledge: { sources: string[] };
  /** Actions this role may ever request; outcomes come from the policy engine. */
  policy: { profile: string; actions: string[] };
  evaluations: { suite: string };
  questionnaire: CatalogQuestion[];
}
```

## CatalogDefinitions (32)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L92).

```typescript
export interface CatalogDefinitions {
  skills: SkillDefinition[];
  tools: ToolDefinition[];
  workflows: WorkflowDefinition[];
  blueprints: AgentBlueprintVersionDefinition[];
  /** Governance evaluations per role (ADR 0019); validated, but not part of bundle digests. */
  evaluationSuites: EvaluationSuiteDefinition[];
}
```

## EvaluationWorld (33)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L105).

```typescript
export interface EvaluationWorld {
  issueProjects: string[];
  issues: { key: string; type: 'Bug' | 'Task' | 'Story'; summary: string; description: string }[];
  repositories: string[];
  /** Relative path to content, created by every repository checkout. */
  repositoryFiles: Record<string, string>;
}
```

## EvaluationExecutionResult (34)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L118).

```typescript
export interface EvaluationExecutionResult {
  operation: 'command' | 'dependencies.install' | 'playwright.run';
  match: string;
  status: 'SUCCEEDED' | 'FAILED';
  output: string;
}
```

## EvaluationStepExpectation (35)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L126).

```typescript
export interface EvaluationStepExpectation {
  /** SUCCEEDED: the tool ran; FAILED: it returned an error code; NOT_AVAILABLE: not granted. */
  outcome: 'SUCCEEDED' | 'FAILED' | 'NOT_AVAILABLE';
  /** Error code for FAILED, for example ACTION_DENIED. */
  code?: string;
  /** Text the tool result must contain. */
  contains?: string;
  /** The call pauses for this governed action; the evaluator then decides. */
  approval?: { action: string; decision: 'APPROVED' | 'REJECTED' };
}
```

## EvaluationStep (36)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L137).

```typescript
export interface EvaluationStep {
  tool: string;
  input: Record<string, unknown>;
  expect: EvaluationStepExpectation;
}
```

## EvaluationScenario (37)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L148).

```typescript
export interface EvaluationScenario {
  id: string;
  title: string;
  /** Blueprint versions the scenario applies to; all versions of the role when absent. */
  blueprintVersions?: string[];
  /** Answers to every question (both scopes) for the evaluated agent. */
  answers: Record<string, string | string[]>;
  task: {
    objective: string;
    workflow: string;
    workItemKey?: string;
    inputs?: Record<string, string>;
  };
  steps: EvaluationStep[];
  expect: {
    /** Tools the runtime must offer the model, sorted. */
    offeredTools: string[];
    runStatus: 'COMPLETED' | 'CANCELLED' | 'FAILED';
    /** Control-plane actions that reached an external system and succeeded, in order. */
    executedActions: string[];
  };
}
```

## QualityCheck (38)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L175).

```typescript
export type QualityCheck = { id: string; weight: number; required?: boolean } & (
  | { kind: 'tool-called' | 'tool-not-called'; tool: string }
  | { kind: 'action-executed' | 'action-not-executed'; action: string }
  /** No governed action the model requested was denied by policy. */
  | { kind: 'no-denials' }
  | { kind: 'run-status'; status: 'COMPLETED' | 'CANCELLED' | 'FAILED' }
  /** A stored artifact of this type whose content includes every string (case-insensitive). */
  | { kind: 'artifact'; type: 'report' | 'test_report'; contains?: string[] }
  /** A file written whose path includes `pathIncludes` and whose content includes every string. */
  | { kind: 'file-written'; pathIncludes: string; contains?: string[] }
);
```

## QualityCriterion (39)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L188).

```typescript
export interface QualityCriterion {
  id: string;
  description: string;
  weight: number;
}
```

## QualityTask (40)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L198).

```typescript
export interface QualityTask {
  id: string;
  title: string;
  /** Blueprint versions the task applies to; all versions of the role when absent. */
  blueprintVersions?: string[];
  answers: Record<string, string | string[]>;
  task: EvaluationScenario['task'];
  /** Governed actions the evaluator approves; every other approval is rejected. */
  approve: string[];
  /** What commands, installs and browser runs return during this task. */
  executionResults?: EvaluationExecutionResult[];
  /** Hard limits for the evaluated model. The run stops when one is reached. */
  budget: { maxTurns: number; maxInputTokens: number; maxOutputTokens: number };
  checks: QualityCheck[];
  rubric: QualityCriterion[];
  /** Weighted score (0 to 1) at or above which the task passes. */
  passThreshold: number;
}
```

## EvaluationSuiteDefinition (41)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L217).

```typescript
export interface EvaluationSuiteDefinition {
  id: string;
  /** The role (blueprint id) whose versions reference this suite. */
  blueprintId: string;
  title: string;
  world: EvaluationWorld;
  scenarios: EvaluationScenario[];
  /** Model-quality tasks, run only on request with real models (ADR 0020). */
  qualityTasks?: QualityTask[];
}
```

## ResolvedBlueprintBundle (42)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L229).

```typescript
export interface ResolvedBlueprintBundle {
  blueprint: AgentBlueprintVersionDefinition;
  skills: SkillDefinition[];
  tools: ToolDefinition[];
  workflows: WorkflowDefinition[];
  capabilities: ManifestCapability[];
  /** SHA-256 of the canonical bundle; pinned by installations and manifests. */
  digest: string;
}
```

## CatalogBlueprintSummary (43)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L239).

```typescript
export interface CatalogBlueprintSummary {
  id: string;
  version: string;
  title: string;
  department: string;
  role: string;
  mission: string;
  digest: string;
  latest: boolean;
}
```

## InstallationStatus (44)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L250).

```typescript
export type InstallationStatus = 'ACTIVE' | 'RETIRED';
```

## OrganizationAgentInstallation (45)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L252).

```typescript
export interface OrganizationAgentInstallation {
  id: string;
  organizationId: string;
  name: string;
  blueprintId: string;
  blueprintVersion: string;
  blueprintDigest: string;
  /** Validated answers to the blueprint's INSTALLATION-scoped questions. */
  configuration: Record<string, string | string[]>;
  status: InstallationStatus;
  version: number;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
}
```

## AgentInstallationInput (46)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog.ts#L268).

```typescript
export interface AgentInstallationInput {
  name: string;
  blueprintId: string;
  blueprintVersion: string;
  configuration: Record<string, string | string[]>;
}
```

## SourceControlProvider (47)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/credentials.ts#L7).

```typescript
export type SourceControlProvider = (typeof sourceControlProviders)[number];
```

## CredentialMode (48)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/credentials.ts#L17).

```typescript
export type CredentialMode = (typeof credentialModes)[number];
```

## SourceControlConnection (49)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/credentials.ts#L20).

```typescript
export interface SourceControlConnection {
  id: string;
  organizationId: string;
  provider: SourceControlProvider;
  name: string;
  /** Git host the connection authenticates to, for example `github.com`. */
  gitHost: string;
  /** Provider API origin, used only by the control plane (GitHub App token minting). */
  apiBaseUrl: string;
  credentialMode: CredentialMode;
  /** `secret://` reference to the token or the GitHub App private key. Never the value. */
  secretRef: string;
  /** GitHub App only. */
  appId?: string;
  installationId?: string;
  /** Repositories (`owner/name` or `workspace/repository`) checkouts may authenticate to. */
  allowedRepositories: string[];
  status: 'ACTIVE' | 'DISABLED';
  version: number;
  createdAt: string;
  updatedAt: string;
}
```

## SourceControlConnectionInput (50)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/credentials.ts#L43).

```typescript
export interface SourceControlConnectionInput {
  provider: SourceControlProvider;
  name: string;
  gitHost: string;
  apiBaseUrl: string;
  credentialMode: CredentialMode;
  secretRef: string;
  appId?: string;
  installationId?: string;
  allowedRepositories: string[];
}
```

## CredentialLeaseStatus (51)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/credentials.ts#L62).

```typescript
export type CredentialLeaseStatus = (typeof credentialLeaseStatuses)[number];
```

## CredentialLease (52)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/credentials.ts#L68).

```typescript
export interface CredentialLease {
  id: string;
  organizationId: string;
  connectionId: string;
  provider: SourceControlProvider;
  repository: string;
  repositoryUrl: string;
  ref: string;
  operationKind: 'git.checkout';
  grantId: string;
  requestId: string;
  runId: string;
  employeeId: string;
  agentId: string;
  status: CredentialLeaseStatus;
  issuedAt: string;
  expiresAt: string;
  redeemedAt?: string;
  releasedAt?: string;
  revokedAt?: string;
  revokeReason?: string;
  outcome?: string;
}
```

## GrantCredentialBinding (53)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/credentials.ts#L96).

```typescript
export interface GrantCredentialBinding {
  leaseId: string;
  provider: SourceControlProvider;
  gitHost: string;
}
```

## CredentialRedeemRequest (54)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/credentials.ts#L108).

```typescript
export interface CredentialRedeemRequest {
  leaseId: string;
  /** The complete signed grant; its signature, lease and operation are checked again. */
  grant: unknown;
}
```

## RepositoryCredential (55)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/credentials.ts#L115).

```typescript
export interface RepositoryCredential {
  scheme: 'basic';
  username: string;
  password: string;
}
```

## CredentialRedeemResponse (56)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/credentials.ts#L121).

```typescript
export interface CredentialRedeemResponse {
  leaseId: string;
  credential: RepositoryCredential;
  /** The credential is refused by the execution runtime after this time. */
  expiresAt: string;
}
```

## CredentialReleaseOutcome (57)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/credentials.ts#L135).

```typescript
export type CredentialReleaseOutcome = (typeof credentialReleaseOutcomes)[number];
```

## CredentialReleaseRequest (58)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/credentials.ts#L138).

```typescript
export interface CredentialReleaseRequest {
  leaseId: string;
  grantId: string;
  outcome: CredentialReleaseOutcome;
}
```

## CredentialReleaseResponse (59)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/credentials.ts#L144).

```typescript
export interface CredentialReleaseResponse {
  leaseId: string;
  status: CredentialLeaseStatus;
}
```

## ModelCredentialBinding (60)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/credentials.ts#L153).

```typescript
export interface ModelCredentialBinding {
  provider: string;
  secretRef: string;
  status: 'ACTIVE' | 'DISABLED';
  version: number;
  updatedAt: string;
  updatedBy: string;
}
```

## ExecutionOperationKind (61)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution-runtime/v1/protocol.ts#L23).

```typescript
export type ExecutionOperationKind = ExecutionOperation['kind'];
```

## ExecutionGrantPayload (62)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution-runtime/v1/protocol.ts#L29).

```typescript
export interface ExecutionGrantPayload {
  kind: typeof EXECUTION_GRANT_KIND;
  grantId: string;
  /** The governed action request this grant executes. */
  requestId: string;
  action: string;
  correlation: {
    organizationId: string;
    employeeId: string;
    agentId: string;
    threadId: string;
    runId: string;
    stepId: string;
    toolCallId: string;
  };
  operationKind: ExecutionOperationKind;
  /** Canonical SHA-256 of the operation; the runtime must present exactly this operation. */
  operationDigest: string;
  /** From the signed manifest. A provider that cannot deliver it must refuse the grant. */
  isolation: 'sandboxed' | 'local';
  limits: ResourceLimits;
  /**
   * Present only for a `git.checkout` the control plane authenticates (ADR 0031): the lease
   * the execution runtime redeems for this checkout. Never a secret.
   */
  credential?: GrantCredentialBinding;
  issuedAt: string;
  expiresAt: string;
}
```

## SignedExecutionGrant (63)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution-runtime/v1/protocol.ts#L64).

```typescript
export interface SignedExecutionGrant {
  payload: ExecutionGrantPayload;
  signature: string;
  algorithm: 'Ed25519';
  keyId: string;
}
```

## ExecuteOperationRequest (64)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution-runtime/v1/protocol.ts#L71).

```typescript
export interface ExecuteOperationRequest {
  protocol: typeof EXECUTION_PROTOCOL_V1;
  grant: SignedExecutionGrant;
  operation: ExecutionOperation;
}
```

## ExecuteOperationResponse (65)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution-runtime/v1/protocol.ts#L77).

```typescript
export interface ExecuteOperationResponse {
  result: ExecutionResult;
  workspace: { id: string; state: WorkspaceState };
  /** Bounded text for the model (file content, status, summary). Never secrets. */
  output: string;
  truncated: boolean;
  /** Evidence already stored by the execution runtime; the agent runtime registers it on the run. */
  artifacts: ArtifactRegistration[];
}
```

## ExecutionArtifactUploadRequest (66)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution-runtime/v1/protocol.ts#L92).

```typescript
export interface ExecutionArtifactUploadRequest {
  grant: SignedExecutionGrant;
  artifact: import('../../artifacts.js').ArtifactUploadDescriptor;
  content: string;
}
```

## Iso8601 (67)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L5).

```typescript
export type Iso8601 = string;
```

## RuntimeCorrelation (68)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L8).

```typescript
export interface RuntimeCorrelation {
  organizationId: string;
  employeeId: string;
  agentId: string;
  threadId: string;
  runId: string;
  stepId?: string;
  toolCallId?: string;
  actionId?: string;
}
```

## WorkItemReference (69)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L20).

```typescript
export interface WorkItemReference {
  system: string;
  key: string;
  url?: string;
}
```

## TaskInputValue (70)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L26).

```typescript
export type TaskInputValue = string | number | boolean | string[];
```

## TaskSpec (71)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L29).

```typescript
export interface TaskSpec {
  objective: string;
  workflow?: string;
  workItem?: WorkItemReference;
  inputs: Record<string, TaskInputValue>;
}
```

## ThreadStatus (72)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L37).

```typescript
export type ThreadStatus = (typeof threadStatuses)[number];
```

## Thread (73)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L40).

```typescript
export interface Thread {
  id: string;
  organizationId: string;
  employeeId: string;
  agentId: string;
  conversationId: string | null;
  title: string;
  status: ThreadStatus;
  createdAt: Iso8601;
  updatedAt: Iso8601;
}
```

## AgentRunStatus (74)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L60).

```typescript
export type AgentRunStatus = (typeof agentRunStatuses)[number];
```

## ManifestApiVersion (75)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L63).

```typescript
export type ManifestApiVersion = (typeof manifestApiVersions)[number];
```

## ManifestReference (76)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L65).

```typescript
export interface ManifestReference {
  manifestId: string;
  apiVersion: ManifestApiVersion;
  keyId: string;
}
```

## AgentRun (77)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L72).

```typescript
export interface AgentRun {
  id: string;
  organizationId: string;
  threadId: string;
  employeeId: string;
  agentId: string;
  /** Null only for the unsigned local-demo agent. */
  manifest: ManifestReference | null;
  task: TaskSpec;
  runtimeProfile: string;
  status: AgentRunStatus;
  statusReason: string | null;
  /** Link to the legacy QA record while QA migrates (ADR 0003). */
  legacyQaRunId: string | null;
  createdAt: Iso8601;
  updatedAt: Iso8601;
  startedAt: Iso8601 | null;
  completedAt: Iso8601 | null;
}
```

## RunStepKind (78)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L93).

```typescript
export type RunStepKind = (typeof runStepKinds)[number];
```

## RunStepStatus (79)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L104).

```typescript
export type RunStepStatus = (typeof runStepStatuses)[number];
```

## RunStep (80)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L106).

```typescript
export interface RunStep {
  id: string;
  organizationId: string;
  runId: string;
  sequence: number;
  kind: RunStepKind;
  title: string;
  status: RunStepStatus;
  detail: Record<string, unknown>;
  createdAt: Iso8601;
  startedAt: Iso8601 | null;
  completedAt: Iso8601 | null;
}
```

## ControlPlaneEventType (81)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L152).

```typescript
export type ControlPlaneEventType = (typeof controlPlaneEventTypes)[number];
```

## RuntimeEventType (82)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L153).

```typescript
export type RuntimeEventType = (typeof runtimeEventTypes)[number];
```

## AgentEventType (83)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L154).

```typescript
export type AgentEventType = ControlPlaneEventType | RuntimeEventType;
```

## AgentEventSource (84)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L160).

```typescript
export type AgentEventSource = 'CONTROL_PLANE' | 'RUNTIME';
```

## AgentEvent (85)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L163).

```typescript
export interface AgentEvent {
  id: string;
  organizationId: string;
  threadId: string;
  runId: string;
  stepId: string | null;
  sequence: number;
  type: AgentEventType;
  source: AgentEventSource;
  actorId: string | null;
  payload: Record<string, unknown>;
  occurredAt: Iso8601;
  recordedAt: Iso8601;
}
```

## ExecutionError (86)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L178).

```typescript
export interface ExecutionError {
  code: string;
  message: string;
}
```

## ToolCall (87)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L183).

```typescript
export interface ToolCall {
  id: string;
  runId: string;
  stepId: string;
  toolId: string;
  toolVersion: string;
  /** SHA-256 of the canonical input; raw input stays in the runtime. */
  inputDigest: string;
  requestedAt: Iso8601;
}
```

## ToolResult (88)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L194).

```typescript
export interface ToolResult {
  toolCallId: string;
  status: 'SUCCEEDED' | 'FAILED' | 'DENIED';
  outputDigest?: string;
  error?: ExecutionError;
  artifactIds: string[];
  durationMs: number;
  completedAt: Iso8601;
}
```

## ApprovalRisk (89)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L205).

```typescript
export type ApprovalRisk = (typeof approvalRisks)[number];
```

## ApprovalRequest (90)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L208).

```typescript
export interface ApprovalRequest {
  id: string;
  organizationId: string;
  action: string;
  risk: ApprovalRisk;
  requestedBy: string;
  agentId: string | null;
  runId: string | null;
  stepId: string | null;
  resource: { type: string; id: string };
  summary: string;
  evidence: EvidenceReference[];
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  requestedAt: Iso8601;
  expiresAt: Iso8601 | null;
  decidedBy?: string;
  decidedAt?: Iso8601;
  decisionReason?: string;
}
```

## WorkspaceState (91)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L236).

```typescript
export type WorkspaceState = (typeof workspaceStates)[number];
```

## RepositoryMapping (92)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L238).

```typescript
export interface RepositoryMapping {
  repositoryUrl: string;
  ref: string;
  path: string;
}
```

## Workspace (93)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L245).

```typescript
export interface Workspace {
  id: string;
  organizationId: string;
  employeeId: string;
  agentId: string;
  threadId: string;
  provider: string;
  environment: string | null;
  repositories: RepositoryMapping[];
  state: WorkspaceState;
  createdAt: Iso8601;
}
```

## WorkspaceBinding (94)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L259).

```typescript
export interface WorkspaceBinding {
  workspaceId: string;
  /** A missing persistent workspace must fail the run, never be silently recreated. */
  persistence: 'EPHEMERAL' | 'PERSISTENT';
}
```

## ResourceLimits (95)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L265).

```typescript
export interface ResourceLimits {
  timeoutMs: number;
  cpuMillis: number;
  memoryMb: number;
  maxProcesses: number;
  network: { mode: 'NONE' | 'ALLOW_LIST'; allowedHosts: string[] };
}
```

## ExecutionOperation (96)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L273).

```typescript
export type ExecutionOperation =
  | { kind: 'command'; command: string; args: string[]; cwd: string }
  | { kind: 'file.read'; path: string }
  /**
   * Write UTF-8 text inside the workspace (Phase G). Replaces the never-implemented
   * `contentArtifactId` form: no producer or provider ever used it, and inline content is
   * what the approval digest and the pull-request change set bind to.
   */
  | { kind: 'file.write'; path: string; content: string }
  | { kind: 'git.checkout'; repositoryUrl: string; ref: string; path: string }
  | { kind: 'git.status'; path: string }
  /** `path` is the workspace-relative project directory (default: workspace root). */
  | { kind: 'playwright.run'; project: string; baseUrl: string; path?: string }
  /**
   * Install the project's locked npm dependencies (`npm ci`, install scripts disabled) from
   * one registry (ADR 0017). `path` is the workspace-relative project directory.
   */
  | { kind: 'dependencies.install'; path: string; registryUrl: string };
```

## ExecutionRequest (97)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L292).

```typescript
export interface ExecutionRequest {
  id: string;
  correlation: RuntimeCorrelation;
  workspaceId: string;
  operation: ExecutionOperation;
  limits: ResourceLimits;
}
```

## ExecutionResult (98)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L300).

```typescript
export interface ExecutionResult {
  requestId: string;
  status: 'SUCCEEDED' | 'FAILED' | 'TIMED_OUT' | 'DENIED';
  exitCode?: number;
  artifactIds: string[];
  durationMs: number;
  error?: ExecutionError;
}
```

## RuntimeSession (99)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L310).

```typescript
export interface RuntimeSession {
  id: string;
  runtimeId: string;
  organizationId: string;
  runId: string;
  state: 'ACTIVE' | 'CLOSED';
  startedAt: Iso8601;
  heartbeatAt: Iso8601;
}
```

## ThreadDetail (100)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L321).

```typescript
export interface ThreadDetail {
  thread: Thread;
  runs: AgentRun[];
}
```

## RunApprovalSummary (101)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L326).

```typescript
export interface RunApprovalSummary {
  id: string;
  action: string;
  risk: ApprovalRisk;
  status: 'PENDING' | 'APPROVED' | 'REJECTED' | 'EXPIRED';
  stepId: string | null;
  createdAt: Iso8601;
  decidedAt?: Iso8601;
  expiresAt?: Iso8601;
}
```

## AgentRunDetail (102)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L337).

```typescript
export interface AgentRunDetail {
  run: AgentRun;
  steps: RunStep[];
  approvals: RunApprovalSummary[];
  artifacts: ArtifactSummary[];
}
```

## AgentEventPage (103)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/execution.ts#L344).

```typescript
export interface AgentEventPage {
  items: AgentEvent[];
  nextAfterSequence: number;
}
```

## Identifier (104)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L1).

```typescript
export type Identifier = string;
```

## UserRole (105)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L20).

```typescript
export type UserRole = 'ADMIN' | 'EMPLOYEE';
```

## Actor (106)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L21).

```typescript
export interface Actor {
  id: string;
  organizationId: string;
  role: UserRole;
}
```

## AccountMembership (107)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L27).

```typescript
export interface AccountMembership {
  organizationId: string;
  organizationName: string;
  role: UserRole;
  employeeId: string;
}
```

## AccountLinkPreview (108)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L34).

```typescript
export interface AccountLinkPreview {
  organizationId: string;
  organizationName: string;
  role: UserRole;
  expiresAt: number;
}
```

## PublicAuthConfig (109)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L41).

```typescript
export type PublicAuthConfig =
  | { mode: 'demo' }
  | { mode: 'password' }
  | {
      mode: 'google';
      workspaceDomain: string;
    };
```

## KeySource (110)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L48).

```typescript
export type KeySource = 'EMPLOYEE_BYOK' | 'ORGANIZATION_MANAGED';
```

## ApprovalStatus (111)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L49).

```typescript
export type ApprovalStatus = 'PENDING' | 'APPROVED' | 'REJECTED';
```

## QaRunStatus (112)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L51).

```typescript
export type QaRunStatus = 'AWAITING_APPROVAL' | 'READY' | 'REJECTED';
```

## Organization (113)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L53).

```typescript
export interface Organization {
  id: Identifier;
  name: string;
  slug: string;
}
```

## Employee (114)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L59).

```typescript
export interface Employee {
  id: Identifier;
  organizationId: Identifier;
  displayName: string;
  email: string;
  role: UserRole;
  team: string;
}
```

## AgentDefinition (115)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L68).

```typescript
export interface AgentDefinition {
  id: Identifier;
  organizationId: Identifier;
  name: string;
  department: string;
  team: string;
  status: 'ACTIVE' | 'DISABLED';
  capabilities: string[];
  employeeId?: Identifier;
}
```

## BlueprintQuestion (116)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L79).

```typescript
export interface BlueprintQuestion {
  id: string;
  label: string;
  type: 'text' | 'url' | 'multiselect';
  required: boolean;
  options?: string[];
}
```

## AgentBlueprint (117)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L87).

```typescript
export interface AgentBlueprint {
  id: string;
  version: string;
  title: string;
  department: string;
  mission: string;
  skills: string[];
  questionnaire: BlueprintQuestion[];
  capabilities: ManifestCapability[];
}
```

## ManifestCapability (118)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L98).

```typescript
export interface ManifestCapability {
  action: string;
  outcome: 'ALLOW' | 'REQUIRE_APPROVAL' | 'DENY';
}
```

## ProvisioningInput (119)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L103).

```typescript
export interface ProvisioningInput {
  blueprintId: string;
  blueprintVersion: string;
  provider: string;
  model: string;
  credentialMode: KeySource;
  answers: Record<string, string | string[]>;
}
```

## ProvisioningRequest (120)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L112).

```typescript
export interface ProvisioningRequest extends ProvisioningInput {
  id: string;
  organizationId: string;
  employeeId: string;
  status: ApprovalStatus;
  capabilities: ManifestCapability[];
  createdAt: string;
  decidedBy?: string;
  decidedAt?: string;
  decisionReason?: string;
  agentId?: string;
}
```

## AdminAgentInput (121)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L125).

```typescript
export interface AdminAgentInput extends ProvisioningInput {
  requestId: string;
  /** Organization installation to inherit INSTALLATION-scoped answers from (Phase B). */
  installationId?: string;
  name: string;
  employeeIds: string[];
}
```

## AgentAssignment (122)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L132).

```typescript
export interface AgentAssignment {
  agentId: string;
  name: string;
  employeeId: string;
  employeeName: string;
  createdBy: string;
  createdAt: string;
}
```

## AgentManifestPayload (123)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L141).

```typescript
export interface AgentManifestPayload {
  apiVersion: 'agents-foundry/v1';
  manifestId: string;
  agentId: string;
  organizationId: string;
  employeeId: string;
  blueprint: { id: string; version: string };
  model: { provider: string; model: string; credentialMode: KeySource };
  answers: Record<string, string | string[]>;
  capabilities: ManifestCapability[];
  conversationSync: 'REQUIRED';
  policyVersion: string;
  issuedAt: string;
}
```

## SignedManifest (124)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L156).

```typescript
export interface SignedManifest<P> {
  payload: P;
  signature: string;
  algorithm: 'Ed25519';
  keyId: string;
}
```

## SignedAgentManifest (125)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L164).

```typescript
export type SignedAgentManifest = SignedManifest<AgentManifestPayload>;
```

## SignedAgentManifestV2 (126)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L165).

```typescript
export type SignedAgentManifestV2 = SignedManifest<AgentManifestV2Payload>;
```

## AnyAgentManifestPayload (127)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L166).

```typescript
export type AnyAgentManifestPayload = AgentManifestPayload | AgentManifestV2Payload;
```

## AnySignedAgentManifest (128)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L167).

```typescript
export type AnySignedAgentManifest = SignedAgentManifest | SignedAgentManifestV2;
```

## ManifestVerificationKey (129)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L169).

```typescript
export interface ManifestVerificationKey {
  keyId: string;
  algorithm: 'Ed25519';
  publicKeySpki: string;
}
```

## LifecycleEvent (130)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L175).

```typescript
export interface LifecycleEvent {
  id: string;
  organizationId: string;
  actorId: string;
  type:
    | 'provisioning.requested'
    | 'provisioning.approved'
    | 'provisioning.rejected'
    | 'agent.manifest.issued'
    | 'organization.created'
    | 'employee.invited'
    | 'employee.activated'
    | 'employee.disabled'
    | 'employee.invitation.reissued'
    | 'employee.password_reset.issued'
    | 'employee.password_reset.completed'
    | 'agent.admin_created'
    | 'agent.assigned';
  subjectId: string;
  occurredAt: string;
  data: Record<string, unknown>;
}
```

## KeyPolicy (131)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L198).

```typescript
export interface KeyPolicy {
  allowedSources: KeySource[];
  defaultSource: KeySource;
  secretStorageRule: string;
}
```

## Conversation (132)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L204).

```typescript
export interface Conversation {
  id: Identifier;
  organizationId: Identifier;
  employeeId: Identifier;
  agentId: Identifier;
  title: string;
  createdAt: string;
  updatedAt: string;
}
```

## ConversationMessage (133)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L214).

```typescript
export interface ConversationMessage {
  id: Identifier;
  conversationId: Identifier;
  author: 'EMPLOYEE' | 'AGENT' | 'SYSTEM';
  content: string;
  createdAt: string;
}
```

## Approval (134)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L222).

```typescript
export interface Approval {
  id: Identifier;
  organizationId: Identifier;
  requestedBy: Identifier;
  action: string;
  resourceType: string;
  resourceId: Identifier;
  risk: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  summary: string;
  status: ActionApprovalStatus;
  decidedBy?: Identifier;
  decidedAt?: string;
  createdAt: string;
  /** After this instant a pending or unused approval can no longer be acted on (Phase D). */
  expiresAt?: string;
  /** Generic run and step this approval pauses, when linked (migration 006). */
  runId?: Identifier;
  stepId?: Identifier;
}
```

## QaRun (135)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L243).

```typescript
export interface QaRun {
  id: Identifier;
  organizationId: Identifier;
  employeeId: Identifier;
  conversationId: Identifier;
  storyKey: string;
  targetUrl: string;
  status: QaRunStatus;
  plan: string[];
  approvalId: Identifier;
  createdAt: string;
}
```

## BootstrapResponse (136)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L256).

```typescript
export interface BootstrapResponse {
  organization: Organization;
  employee: Employee;
  agents: AgentDefinition[];
  keyPolicy: KeyPolicy;
}
```

## ConversationDetail (137)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L263).

```typescript
export interface ConversationDetail extends Conversation {
  messages: ConversationMessage[];
}
```

## QaRunRequest (138)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L267).

```typescript
export interface QaRunRequest {
  employeeId: Identifier;
  conversationId: Identifier;
  storyKey: string;
  targetUrl: string;
  /** Employee guidance for the agent; used by generic-runtime QA runs only. */
  instructions?: string;
}
```

## QaRunMode (139)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L277).

```typescript
export type QaRunMode = 'LEGACY_STATIC_PLAN' | 'GENERIC_RUNTIME';
```

## QaRunResponse (140)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L280).

```typescript
export interface QaRunResponse {
  mode: 'LEGACY_STATIC_PLAN';
  run: QaRun;
  approval: Approval;
  /** Generic run recorded alongside the legacy QA run. Read via /api/execution/v1. */
  agentRun?: { id: Identifier; threadId: Identifier; status: AgentRunStatus };
}
```

## GenericQaRunResponse (141)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L293).

```typescript
export interface GenericQaRunResponse {
  mode: 'GENERIC_RUNTIME';
  agentRun: { id: Identifier; threadId: Identifier; status: AgentRunStatus };
}
```

## QaRunResult (142)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/index.ts#L298).

```typescript
export type QaRunResult = QaRunResponse | GenericQaRunResponse;
```

## JobKind (143)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/jobs.ts#L2).

```typescript
export type JobKind = (typeof jobKinds)[number];
```

## JobRecord (144)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/jobs.ts#L3).

```typescript
export interface JobRecord {
  id: string;
  organizationId: string;
  name: string;
  code: string;
  description: string;
  status: 'active' | 'archived';
  version: number;
  createdAt: string;
  updatedAt: string;
  jobFamilyId?: string;
  disciplineId?: string;
  rank?: number;
  organizationalUnitId?: string;
  roleId?: string;
  jobLevelId?: string;
  reportsToPositionId?: string | null;
  referenceNames?: Record<string, string>;
}
```

## VersionedReference (145)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/manifest-v2.ts#L5).

```typescript
export interface VersionedReference {
  id: string;
  /** Exact version resolved at issuance; constraints are resolved before signing. */
  version: string;
}
```

## ConnectorRequirement (146)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/manifest-v2.ts#L11).

```typescript
export interface ConnectorRequirement {
  id: string;
  /** Capability identifiers such as `issueTracker.read`; never raw provider API scopes. */
  capabilities: string[];
}
```

## AgentManifestV2Payload (147)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/manifest-v2.ts#L17).

```typescript
export interface AgentManifestV2Payload {
  apiVersion: 'agents-foundry/v2';
  kind: 'AgentManifest';
  metadata: {
    manifestId: string;
    agentId: string;
    organizationId: string;
    employeeId: string;
    issuedAt: string;
    /** `digest` pins the exact catalog bundle (Phase B); absent on Phase A manifests. */
    blueprint: VersionedReference & { digest?: string };
    /** Organization installation the agent was created from, when any. */
    installationId?: string;
  };
  identity: { name: string; role: string; department: string };
  persona: { profile: string };
  runtime: { profile: string; isolation: 'sandboxed' | 'local' };
  model: { profile: string; provider: string; model: string; credentialMode: KeySource };
  skills: VersionedReference[];
  tools: string[];
  connectors: ConnectorRequirement[];
  mcp: string[];
  memory: { profile: string };
  knowledge: { sources: string[] };
  policies: { profile: string; policyVersion: string; capabilities: ManifestCapability[] };
  workflows: string[];
  evaluations: { suite: string };
  /** Installation answers resolved for this agent (for example the QA environment URL). */
  configuration: Record<string, string | string[]>;
  conversationSync: 'REQUIRED';
}
```

## ManifestSubject (148)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/manifest.ts#L21).

```typescript
export interface ManifestSubject {
  apiVersion: ManifestApiVersion;
  manifestId: string;
  agentId: string;
  organizationId: string;
  employeeId: string;
  issuedAt: string;
}
```

## QualityRunPoint (149)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/model-quality.ts#L4).

```typescript
export interface QualityRunPoint {
  runId: string;
  runAt: string;
  trials: number;
  /** 0 to 1. */
  passRate: number;
  /** 0 to 1. */
  meanScore: number;
}
```

## QualitySeriesStatus (150)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/model-quality.ts#L14).

```typescript
export type QualitySeriesStatus = 'NEW' | 'STEADY' | 'IMPROVED' | 'REGRESSED';
```

## QualitySeries (151)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/model-quality.ts#L16).

```typescript
export interface QualitySeries {
  provider: string;
  model: string;
  judgeModel: string;
  /** Role version, `<blueprint id>@<version>`. */
  blueprint: string;
  task: string;
  /** Oldest first. */
  runs: QualityRunPoint[];
  latest: QualityRunPoint;
  /** The earlier runs' trials pooled, or null when this is the series' first run. */
  baseline: { runs: number; passRate: number; meanScore: number } | null;
  status: QualitySeriesStatus;
  /** Why a series regressed, such as `pass rate 100% → 33%`. */
  reasons: string[];
}
```

## ModelQualityOverview (152)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/model-quality.ts#L34).

```typescript
export interface ModelQualityOverview {
  /** Results from runs at or after this instant are included. */
  since: string;
  /** When the latest results were imported, or null before any. */
  lastImportedAt: string | null;
  series: QualitySeries[];
}
```

## OrganizationModelBudget (153)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/model-spending.ts#L5).

```typescript
export interface OrganizationModelBudget {
  /** Tokens (input and output) the organization's agents may use per UTC calendar month. */
  monthlyTokenLimit: number | null;
  /** Tokens one run may use. */
  runTokenLimit: number | null;
  /** ISO 4217 code of every price and cost limit. Fixed once the first price is set. */
  currency: string;
  /** Cost the organization's agents may incur per UTC calendar month, in micros. */
  monthlyCostLimitMicros: number | null;
  /** Cost one run may incur, in micros. */
  runCostLimitMicros: number | null;
  /**
   * Percentages (1-99) of the monthly token and cost limits at which administrators are
   * alerted (ADR 0023). Reaching a limit always raises an alert.
   */
  alertThresholdsPercent: number[];
  /** Optimistic concurrency; 0 until the organization first sets a budget. */
  version: number;
  updatedBy: string | null;
  updatedAt: string | null;
}
```

## OrganizationModelBudgetInput (154)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/model-spending.ts#L28).

```typescript
export interface OrganizationModelBudgetInput {
  monthlyTokenLimit: number | null;
  runTokenLimit: number | null;
  currency?: string;
  monthlyCostLimitMicros?: number | null;
  runCostLimitMicros?: number | null;
  alertThresholdsPercent?: number[];
  version: number;
}
```

## ModelBudgetAlert (155)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/model-spending.ts#L42).

```typescript
export interface ModelBudgetAlert {
  id: string;
  /** UTC calendar month, `YYYY-MM`. */
  period: string;
  scope: 'MONTHLY_TOKENS' | 'MONTHLY_COST';
  thresholdPercent: number;
  /** The limit when the alert was raised: tokens, or micros of `currency`. */
  limit: number;
  /** Charged usage when the alert was raised, in the limit's unit. */
  charged: number;
  /** Cost alerts only. */
  currency: string | null;
  createdAt: string;
  acknowledgedBy: string | null;
  acknowledgedAt: string | null;
}
```

## ModelBudgetAlertList (156)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/model-spending.ts#L59).

```typescript
export interface ModelBudgetAlertList {
  period: string;
  alerts: ModelBudgetAlert[];
}
```

## ModelPrice (157)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/model-spending.ts#L65).

```typescript
export interface ModelPrice {
  /** Changes with every price change; pass it back as `expectedPriceId`. */
  priceId: string;
  provider: string;
  model: string;
  currency: string;
  inputMicrosPerMillionTokens: number;
  outputMicrosPerMillionTokens: number;
  setBy: string;
  setAt: string;
}
```

## ModelPriceBook (158)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/model-spending.ts#L77).

```typescript
export interface ModelPriceBook {
  currency: string;
  prices: ModelPrice[];
}
```

## ModelPriceInput (159)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/model-spending.ts#L86).

```typescript
export interface ModelPriceInput {
  provider: string;
  model: string;
  inputMicrosPerMillionTokens: number;
  outputMicrosPerMillionTokens: number;
  expectedPriceId: string | null;
}
```

## ModelPriceRemoval (160)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/model-spending.ts#L95).

```typescript
export interface ModelPriceRemoval {
  provider: string;
  model: string;
  expectedPriceId: string;
}
```

## ModelUsageTotals (161)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/model-spending.ts#L101).

```typescript
export interface ModelUsageTotals {
  /** Settled usage plus unsettled reservations: what counts against a limit. */
  chargedTokens: number;
  /** The same, in micros, for calls made at a price. */
  chargedCostMicros: number;
  calls: number;
  /** Calls made while their model had no price: their cost is unknown and not included. */
  unpricedCalls: number;
}
```

## ModelUsageReport (162)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/model-spending.ts#L111).

```typescript
export interface ModelUsageReport extends ModelUsageTotals {
  /** UTC calendar month, `YYYY-MM`. */
  period: string;
  budget: OrganizationModelBudget;
  /** Provider-reported usage of settled calls. */
  inputTokens: number;
  outputTokens: number;
  /** Calls still reserved: their reserved size counts until they settle. */
  unsettledReservedTokens: number;
  /** Monthly tokens left, or null without a monthly limit. */
  remainingTokens: number | null;
  /** Monthly cost left in micros, or null without a monthly cost limit. */
  remainingCostMicros: number | null;
  byAgent: (ModelUsageTotals & { agentId: string })[];
  byModel: (ModelUsageTotals & { provider: string; model: string })[];
}
```

## UnitType (163)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/organization.ts#L13).

```typescript
export type UnitType = (typeof unitTypes)[number];
```

## OrganizationUnitInput (164)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/organization.ts#L14).

```typescript
export interface OrganizationUnitInput {
  name: string;
  code: string;
  unitType: UnitType;
  parentId: string | null;
  description: string;
}
```

## OrganizationUnit (165)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/organization.ts#L21).

```typescript
export interface OrganizationUnit extends OrganizationUnitInput {
  parentName?: string | null;
  headPositionId: string | null;
  headPositionName: string | null;
  headEmployeeName: string | null;
  id: string;
  organizationId: string;
  status: 'active' | 'archived';
  version: number;
  createdAt: string;
  updatedAt: string;
}
```

## Page (166)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/organization.ts#L33).

```typescript
export interface Page<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
}
```

## UnitMembership (167)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/organization.ts#L39).

```typescript
export interface UnitMembership {
  id: string;
  employeeId: string;
  displayName: string;
  membershipType: 'member' | 'lead' | 'manager' | 'owner' | 'contributor';
  isPrimary: boolean;
  startedAt: string;
  endedAt: string | null;
  version: number;
}
```

## RuntimeEventDecision (168)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/run-lifecycle.ts#L55).

```typescript
export type RuntimeEventDecision =
  | { accepted: true; nextStatus: AgentRunStatus }
  | { accepted: false; code: 'RUN_TERMINAL' | 'ILLEGAL_RUN_TRANSITION' | 'RUN_NOT_RUNNING' };
```

## RuntimeProtocolVersion (169)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/protocol.ts#L16).

```typescript
export type RuntimeProtocolVersion = typeof RUNTIME_PROTOCOL_V1;
```

## RunSubmitCommand (170)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/protocol.ts#L26).

```typescript
export interface RunSubmitCommand extends CommandBase {
  type: 'run.submit';
  run: {
    runId: string;
    threadId: string;
    task: TaskSpec;
    runtimeProfile: string;
    manifest: SignedAgentManifestV2;
    workspace: WorkspaceBinding | null;
    /**
     * The task's workflow resolved by the control plane from the agent's pinned catalog
     * bundle (Phase F). Guidance for the kernel only: every step's action is still decided by
     * the control plane when requested. Absent when the task names no workflow.
     */
    workflow?: WorkflowDefinition;
  };
}
```

## RunResumeCommand (171)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/protocol.ts#L45).

```typescript
export interface RunResumeCommand extends CommandBase {
  type: 'run.resume';
  runId: string;
  approval: { approvalId: string; decision: 'APPROVED' | 'REJECTED'; decidedAt: string };
}
```

## RunCancelCommand (172)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/protocol.ts#L51).

```typescript
export interface RunCancelCommand extends CommandBase {
  type: 'run.cancel';
  runId: string;
  reason: string;
}
```

## RunRecoverCommand (173)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/protocol.ts#L61).

```typescript
export interface RunRecoverCommand extends CommandBase {
  type: 'run.recover';
  runId: string;
  reason: 'LEASE_EXPIRED';
  /** Steps the control plane still holds open. Any the checkpoint does not name are failed. */
  openStepIds: string[];
}
```

## RuntimeCommand (174)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/protocol.ts#L69).

```typescript
export type RuntimeCommand =
  RunSubmitCommand | RunResumeCommand | RunCancelCommand | RunRecoverCommand;
```

## RuntimeEventPayloads (175)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/protocol.ts#L73).

```typescript
export interface RuntimeEventPayloads {
  'run.started': { runtimeSessionId: string; kernel: string };
  'run.paused': { reason: 'APPROVAL_REQUIRED'; actionId: string };
  'run.resumed': { approvalId: string };
  'run.completed': { summary: string; artifactIds: string[] };
  'run.failed': { error: ExecutionError; retryable: boolean };
  'run.cancelled': { reason: string };
  'step.started': { kind: RunStepKind; title: string };
  'step.completed': { outputSummary?: string };
  'step.failed': { error: ExecutionError };
  'agent.message': { content: string };
  'agent.reasoning.started': Record<string, never>;
  'model.requested': { modelProfile: string; capability: string };
  'model.responded': {
    modelProfile: string;
    inputTokens: number;
    outputTokens: number;
    latencyMs: number;
    finishReason: string;
  };
  'tool.requested': {
    toolCallId: string;
    toolId: string;
    toolVersion: string;
    inputDigest: string;
  };
  'tool.started': { toolCallId: string };
  'tool.completed': {
    toolCallId: string;
    outputDigest: string;
    durationMs: number;
    artifactIds: string[];
  };
  'tool.failed': { toolCallId: string; error: ExecutionError; durationMs: number };
  'artifact.created': { artifact: ArtifactRegistration };
}
```

## RuntimeEventEnvelope (176)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/protocol.ts#L110).

```typescript
export type RuntimeEventEnvelope = {
  [K in RuntimeEventType]: {
    protocol: RuntimeProtocolVersion;
    /** Globally unique; redelivery of the same event is idempotent. */
    eventId: string;
    runId: string;
    threadId: string;
    stepId?: string;
    /** Runtime-assigned, contiguous from 1 per run. */
    sequence: number;
    type: K;
    occurredAt: string;
    correlation: RuntimeCorrelation;
    payload: RuntimeEventPayloads[K];
  };
}[RuntimeEventType];
```

## RuntimeLease (177)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L64).

```typescript
export interface RuntimeLease {
  sessionId: string;
  /** Last runtime event sequence the control plane accepted for the run. */
  runtimeSequence: number;
  leaseExpiresAt: string;
}
```

## RuntimeClaimResponse (178)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L72).

```typescript
export interface RuntimeClaimResponse {
  command: RuntimeCommand;
  lease: RuntimeLease;
}
```

## RuntimeActionRequest (179)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L81).

```typescript
export interface RuntimeActionRequest {
  protocol: RuntimeProtocolVersion;
  /** Idempotency key: a retried request returns the original decision. */
  requestId: string;
  correlation: RuntimeCorrelation & { stepId: string; toolCallId: string };
  action: string;
  toolId: string;
  toolVersion: string;
  inputDigest: string;
  /** Human-readable purpose from the runtime. Control-plane-executed actions replace it. */
  summary: string;
  /**
   * The exact action payload, required for actions the control plane executes (Phase D).
   * Its canonical SHA-256 must equal `inputDigest`, which binds any approval to this payload.
   */
  parameters?: Record<string, unknown>;
}
```

## RuntimeActionExecuteRequest (180)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L100).

```typescript
export interface RuntimeActionExecuteRequest {
  protocol: RuntimeProtocolVersion;
  requestId: string;
  correlation: RuntimeCorrelation & { stepId: string; toolCallId: string };
}
```

## RuntimeActionGrantRequest (181)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L110).

```typescript
export type RuntimeActionGrantRequest = RuntimeActionExecuteRequest;
```

## RuntimeActionExecution (182)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L112).

```typescript
export interface RuntimeActionExecution {
  requestId: string;
  status: 'SUCCEEDED' | 'FAILED';
  /** Non-secret identifiers of what was created, for example an issue key and URL. */
  result?: Record<string, string>;
  error?: ExecutionError;
}
```

## RuntimeActionDecision (183)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L120).

```typescript
export type RuntimeActionDecision =
  | { requestId: string; decision: 'ALLOWED'; risk: ApprovalRisk; reason: string }
  | { requestId: string; decision: 'DENIED'; risk: ApprovalRisk; reason: string }
  | {
      requestId: string;
      decision: 'APPROVAL_REQUIRED';
      risk: ApprovalRisk;
      reason: string;
      /** The run is already paused; it resumes only through a `run.resume` command. */
      approvalId: string;
    };
```

## RuntimeModelReservationRequest (184)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L136).

```typescript
export interface RuntimeModelReservationRequest {
  protocol: RuntimeProtocolVersion;
  /** Idempotency key: a retried request returns the original decision. */
  reservationId: string;
  correlation: RuntimeCorrelation;
  provider: string;
  model: string;
  /** Estimated from the prompt's size; the settlement records the provider's count. */
  estimatedInputTokens: number;
  /** The most output the call asks for; the reservation may lower it. */
  maxOutputTokens: number;
}
```

## RuntimeModelReservation (185)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L149).

```typescript
export type RuntimeModelReservation =
  | {
      reservationId: string;
      decision: 'ALLOWED';
      /** The call must not ask for more output than this. */
      maxOutputTokens: number;
    }
  | {
      reservationId: string;
      decision: 'DENIED';
      code: 'MODEL_BUDGET_EXCEEDED';
      reason: string;
    };
```

## RuntimeModelSettlementRequest (186)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L164).

```typescript
export interface RuntimeModelSettlementRequest {
  protocol: RuntimeProtocolVersion;
  reservationId: string;
  correlation: RuntimeCorrelation;
  inputTokens: number;
  outputTokens: number;
}
```

## RuntimeModelSettlement (187)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L172).

```typescript
export interface RuntimeModelSettlement {
  reservationId: string;
  status: 'SETTLED';
}
```

## RuntimeHeartbeatRequest (188)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L181).

```typescript
export interface RuntimeHeartbeatRequest {
  protocol: RuntimeProtocolVersion;
  runIds: string[];
}
```

## RuntimeHeartbeat (189)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L186).

```typescript
export interface RuntimeHeartbeat {
  held: string[];
  lost: string[];
}
```

## RunCheckpointBinding (190)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L192).

```typescript
export interface RunCheckpointBinding {
  manifestId: string;
  /** SHA-256 of the canonical signed manifest payload. */
  manifestDigest: string;
  workflow: string | null;
  /** The step in progress when the checkpoint was taken, if any. */
  stepId: string | null;
  /** The approval the run is waiting for, if it is paused. */
  approvalId: string | null;
  kernelId: string;
  /** The last runtime event sequence emitted before the checkpoint. */
  runtimeSequence: number;
}
```

## RuntimeCheckpointSaveRequest (191)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L211).

```typescript
export interface RuntimeCheckpointSaveRequest {
  protocol: RuntimeProtocolVersion;
  correlation: RuntimeCorrelation;
  sessionId: string;
  version: number;
  binding: RunCheckpointBinding;
  /** SHA-256 of `body`. */
  sha256: string;
  body: string;
}
```

## RuntimeCheckpointAck (192)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L222).

```typescript
export interface RuntimeCheckpointAck {
  runId: string;
  version: number;
}
```

## RuntimeCheckpointLoadRequest (193)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L227).

```typescript
export interface RuntimeCheckpointLoadRequest {
  protocol: RuntimeProtocolVersion;
  correlation: RuntimeCorrelation;
}
```

## RuntimeCheckpointRecord (194)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L233).

```typescript
export interface RuntimeCheckpointRecord {
  runId: string;
  version: number;
  binding: RunCheckpointBinding;
  sha256: string;
  body: string;
}
```

## RuntimeModelCredentialRequest (195)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L245).

```typescript
export interface RuntimeModelCredentialRequest {
  protocol: RuntimeProtocolVersion;
  correlation: RuntimeCorrelation;
  provider: string;
}
```

## RuntimeModelCredential (196)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L252).

```typescript
export interface RuntimeModelCredential {
  provider: string;
  apiKey: string;
}
```

## RuntimeArtifactUploadRequest (197)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L262).

```typescript
export interface RuntimeArtifactUploadRequest {
  protocol: RuntimeProtocolVersion;
  correlation: RuntimeCorrelation & { stepId: string };
  artifact: ArtifactUploadDescriptor;
  content: string;
}
```

## RuntimeEventAck (198)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/runtime/v1/transport.ts#L270).

```typescript
export interface RuntimeEventAck {
  eventId: string;
  /** Control-plane history sequence assigned to the event. */
  sequence: number;
  duplicate: boolean;
}
```

## OrganizationProfile (199)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/tenancy.ts#L1).

```typescript
export interface OrganizationProfile {
  id: string;
  name: string;
  legalName: string;
  code: string;
  slug: string;
  website: string;
  industry: string;
  country: string;
  timezone: string;
  locale: string;
  status: 'active' | 'suspended' | 'disabled';
  version: number;
  updatedAt: string;
}
```

## TenantDomain (200)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/tenancy.ts#L16).

```typescript
export interface TenantDomain {
  id: string;
  organizationId: string;
  domain: string;
  domainType: 'custom_domain' | 'platform_subdomain' | 'internal';
  isPrimary: boolean;
  verificationStatus: 'pending' | 'verified' | 'disabled';
  verificationToken: string | null;
  verifiedAt: string | null;
  version: number;
}
```

## EmploymentRecord (201)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/tenancy.ts#L27).

```typescript
export interface EmploymentRecord {
  id: string;
  organizationId: string;
  userId: string | null;
  displayName: string;
  email: string;
  employeeNumber: string | null;
  employmentType: 'employee' | 'contractor' | 'external';
  employmentStatus: 'active' | 'inactive';
  version: number;
  positionId: string | null;
  positionTitle: string | null;
  unitName: string | null;
  roleName: string | null;
  levelName: string | null;
}
```

## OrganizationMembership (202)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/tenancy.ts#L43).

```typescript
export interface OrganizationMembership {
  id: string;
  userId: string;
  employeeId: string;
  displayName: string;
  email: string;
  securityRole: 'ADMIN' | 'EMPLOYEE';
  membershipStatus: 'pending' | 'active' | 'suspended';
  version: number;
}
```

## SetupStepId (203)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/tenancy.ts#L54).

```typescript
export type SetupStepId =
  'profile' | 'structure' | 'positions' | 'people' | 'assignments' | 'employee_access' | 'domain';
```

## SetupStep (204)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/tenancy.ts#L56).

```typescript
export interface SetupStep {
  id: SetupStepId;
  complete: boolean;
  required: boolean;
}
```

## SetupProgress (205)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/tenancy.ts#L61).

```typescript
export interface SetupProgress {
  completedRequired: number;
  totalRequired: number;
  steps: SetupStep[];
}
```

## WebhookEventType (206)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/webhooks.ts#L28).

```typescript
export type WebhookEventType = 'model.budget.alert' | 'webhook.test';
```

## WebhookEvent (207)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/webhooks.ts#L31).

```typescript
export type WebhookEvent =
  | {
      type: 'model.budget.alert';
      deliveryId: string;
      organizationId: string;
      createdAt: string;
      data: { alert: ModelBudgetAlert };
    }
  | {
      type: 'webhook.test';
      deliveryId: string;
      organizationId: string;
      createdAt: string;
      data: { message: string };
    };
```

## AlertWebhook (208)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/webhooks.ts#L47).

```typescript
export interface AlertWebhook {
  id: string;
  /**
   * The endpoint's origin and a masked path: URLs can carry tokens, so the full URL is never
   * returned after it is set.
   */
  displayUrl: string;
  description: string;
  status: 'ACTIVE' | 'DISABLED';
  version: number;
  createdBy: string;
  createdAt: string;
  updatedBy: string;
  updatedAt: string;
}
```

## AlertWebhookDelivery (209)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/webhooks.ts#L63).

```typescript
export interface AlertWebhookDelivery {
  id: string;
  webhookId: string;
  eventType: WebhookEventType;
  alertId: string | null;
  status: 'PENDING' | 'DELIVERED' | 'FAILED';
  attempts: number;
  nextAttemptAt: string | null;
  lastAttemptAt: string | null;
  /** HTTP status of the last attempt, when a response arrived. */
  lastStatusCode: number | null;
  /** Error code of the last failed attempt, such as `WEBHOOK_TIMEOUT`. */
  lastError: string | null;
  deliveredAt: string | null;
  createdAt: string;
}
```

## AlertWebhookList (210)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/webhooks.ts#L80).

```typescript
export interface AlertWebhookList {
  webhooks: AlertWebhook[];
  /** The most recent deliveries, newest first. */
  deliveries: AlertWebhookDelivery[];
  /** The key deliveries are signed with; receivers pin it. */
  signingKey: { keyId: string; algorithm: 'Ed25519'; publicKeySpki: string };
}
```

## AlertWebhookInput (211)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/webhooks.ts#L89).

```typescript
export interface AlertWebhookInput {
  url: string;
  description: string;
}
```

## AlertWebhookStatusInput (212)

[Source](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/webhooks.ts#L95).

```typescript
export interface AlertWebhookStatusInput {
  status: 'ACTIVE' | 'DISABLED';
  version: number;
}
```

## Related documentation

[API index](README.md) · [Implementation status](../reference/implementation-status.md)
