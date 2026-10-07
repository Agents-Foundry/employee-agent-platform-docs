# Code Reviewer: end-to-end use case

**Audience:** Employees, administrators, QA and implementers. **Implementation status:** Implemented role package; generic runtime is opt-in and UI coverage is partial.

**Prerequisites:** An active employee assignment, verified V2 manifest, organization-managed Anthropic configuration, generic-runtime flags, registered workloads and execution service. Jira/repository/QA connections must match the selected questionnaire and intended task.

## Scenario and boundary

Review a proposed change against a work item. Read the repository, install locked dependencies, run permitted checks and produce a findings artifact. This role does not have code-editor or draft-PR actions in its manifest. Its output is a review report rather than an automatically published GitHub review or a merge decision. Dependency installation and checks execute repository code, so read-oriented review still requires sandbox controls.

The exact blueprint is `engineering.code-reviewer@1.0.0`. Review proposed changes against their work items, run the project checks in an isolated workspace, and report defects, risks and missing tests to a human reviewer.

Catalog workflow steps guide the native model loop. They are not a deterministic workflow scheduler or executable skill engine; tool calls can vary. Authorization, lease checks, input scope and approvals are enforced independently at every action.

## Prepare the assignment

Install/select this exact catalog version and complete the scoped questionnaire. Choose only connectors with real adapters: Jira and GitHub draft-PR actions are implemented; repository checkout also supports scoped Bitbucket credentials. Azure DevOps/Linear/GitLab selections or an MCP ID do not install an adapter.

| Questionnaire field | Scope | Type | Required |
| --- | --- | --- | --- |
| `projectName` | AGENT | text | Yes |
| `repositoryUrl` | AGENT | url | Yes |
| `projectScripts` | AGENT | text | No |
| `packageRegistryUrl` | AGENT | url | No |
| `issueTracker` | INSTALLATION | multiselect | Yes |
| `sourceControl` | INSTALLATION | multiselect | Yes |

Tools pinned by the bundle: `repository@1.0.0`, `build@1.0.0`, `dependencies@1.0.0`, `issue-tracker@1.0.0`, `artifact@1.0.0`. The runtime registers execution-backed tools only when its execution service is configured.

## Guided work and policy gates

### Review change (review-change@1.0.0)

Review a proposed change against its work item: read it, run the project checks, and report findings without changing anything.

| Step | Skill reference | Requested action | Default policy |
| --- | --- | --- | --- |
| Read the work item | `change-scoping` | `jira.read` | ALLOW |
| Check out and read the change | `code-review` | `repository.read` | ALLOW |
| Install locked dependencies | `code-review` | `workspace.dependencies.install` | ALLOW |
| Run lint and tests | `code-review` | `workspace.command` | ALLOW |
| Write the review report | `review-reporting` | Model guidance / reporting | No independent action grant |

Tenant overrides can only tighten these outcomes. The current lease, manifest action set, tool version and repository/URL/project scope must also pass. Approval pauses the run in WAITING_FOR_APPROVAL; an eligible same-tenant administrator who is not the requester approves the exact payload. The control plane requeues work; a changed payload or expired approval is not silently permitted.

## Trace the participating components

| Stage | Responsible component | Evidence to inspect |
| --- | --- | --- |
| Assignment/configuration | Admin API, catalog resolver, manifest signer | Bundle/version/digest, employee ownership, issued manifest |
| Start work | Employee execution API, central run service | Thread, task, QUEUED run and command |
| Context/model | Agent host, native kernel, model gateway | Run events, spending reservation/settlement; no raw-secret logs |
| Read or write connector | Runtime tool → Action Gateway | Input digest, policy result, connection scope, approval/dispatch result |
| Repository/files/commands/browser | Granted execution runtime | Verified grant, workspace scope, operation status and evidence |
| Pause/resume | Control-plane approval and runtime command | Approval expiry/actor, run status/requeue, resumed event |
| Report and retain | Artifact tool/service and run persistence | Artifact checksum/size/retention, terminal event and audit records |

## Acceptance and failure checks

Verify the intended employee owns the run; out-of-scope repositories/URLs fail; no external write occurs before approval; required evidence is retained; and terminal status agrees with operation results. A test failure should be reported as evidence rather than converted to a success. Read [test strategy](../qa/test-strategy.md) and the role's scripted evaluation suite before a live-provider qualification.

If a connector dispatch is uncertain, reconcile APPLIED/NOT_APPLIED before issuing a replacement. Do not blindly retry an unknown Jira issue or PR creation. If a workspace is lost, preserve state and diagnose instead of pretending an empty recreated directory contains earlier changes. See [troubleshooting](../operations/troubleshooting.md).

## Source provenance

Verified against `d2bc8d7fa3fc185cc4f487bdaa1f11611844763f`: [catalog role](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/catalog/src/blueprints/code-reviewer.ts), [workflow definitions](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/catalog/src/workflows.ts), [policy engine](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/policy-engine/src/index.ts), [scripted evaluations](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/catalog/src/evaluations.ts), [native kernel](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/agent-runtime/src/kernel/native-kernel.ts).

## Related documentation

[Role index](README.md) · [Manifest](../agents/manifest-v2.md) · [Employee guide](../employee/workspace.md) · [Policy/approvals](../admin/policies-and-approvals.md)
