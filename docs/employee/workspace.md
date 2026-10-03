# Employee workspace and onboarding

**Audience:** Employees, support teams. **Implementation status:** Partially Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

The employee workspace is an Angular application with a Tauri desktop shell. Its working journey is sign-in, select an assigned agent, verify the signed manifest, start or resume the relevant conversation, submit a QA task and review recorded outcomes. Conversations stay bound to the agent used to create them.

Provisioning lets an employee request a blueprint with questionnaire answers and model preferences. An administrator approves or rejects with a reason. Approval issues an employee-owned signed manifest. Selecting **Verify and use agent** verifies signature and subject before updating the selection; a failed verification must not be bypassed.

The web preview runs on port 4300. The native shell does not contain a desktop-local agent runtime or employee BYOK execution engine. Model preferences in a provisioning form do not guarantee that the selected provider has a live runtime adapter.

## Generic runs and evidence

The generic API can create a run for an assigned v2 agent, query its own event pages and cancel its own run. The current employee UI focuses on the QA conversation path rather than a complete generic-run console. Artifact download requires a same-session retrieval API call; there is no full download control yet. Use the [run API](../api/execution.md) and [artifact guide](../operations/artifacts.md) where the UI is incomplete.

## Safe expectations

An approval request is a pause, not completion. Rejection or expiry prevents that approved path from executing. A terminal failure can still have an external write with unknown outcome; ask an administrator to reconcile rather than re-running it. No measured universal onboarding duration is established by source code or tests.

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/employee-desktop/src/app/app.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/employee-desktop/src/app/app.ts)
- [apps/employee-desktop/src/app/app.html](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/employee-desktop/src/app/app.html)
- [apps/employee-desktop/src/app/verify-manifest.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/employee-desktop/src/app/verify-manifest.ts)
- [apps/control-plane-api/src/execution/execution-routes.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/execution/execution-routes.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
