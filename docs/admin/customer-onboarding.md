# Operator provisioning, invitations and recovery

**Audience:** Platform operators, administrators. **Implementation status:** Partially Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

An operator provisions the initial organization; an unauthenticated visitor cannot create one or become the first administrator. In password mode, create a private ignored `.data/new-customer.json` at the platform root with:

```json
{
  "organization": { "name": "Example Company", "slug": "example-company" },
  "admin": { "displayName": "Customer Administrator", "email": "admin@example.com", "team": "Administration" }
}
```

From `apps/control-plane-api`:

```powershell
npx tsx --env-file=../../.env src/create-customer.ts ../../.data/new-customer.json
```

The CLI creates the initial records atomically and prints a one-use activation URL, expiring after 48 hours. Only its token hash is stored. Deliver the URL privately. The fragment token is removed from the browser address bar; activation requires a 15–256 character application password, then a normal sign-in.

Administrators record/invite employees through organization routes, reissue invitations or request administrator-assisted password recovery. Disabled access revokes sessions and pending invitations. The initial member UI cannot disable another administrator or the acting administrator. For operator recovery follow the actual `recover-member.ts` argument/confirmation path; inspect its usage output before executing against a customer deployment.

## Multi-organization accounts

Current global users and organization memberships support existing-account invitation acceptance and workspace switching. Earlier product onboarding text describing globally unique employee emails and absent multi-workspace support is obsolete. Tenant employees remain unique by email within a tenant; global users have their own email uniqueness. Linking requires the private invitation and authenticated account and is not automatic matching by email.

## Implementation Status / Architecture Gap

Invitation and recovery delivery are MANUAL; no transactional email, public reset-email flow, subscription/seat enforcement or purchase-webhook integration is shipped. Google mode uses operator-managed subject mappings and one configured Workspace domain; per-organization optional SSO and a native desktop OAuth deep-link flow are not complete.

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/control-plane-api/src/create-customer.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/create-customer.ts)
- [apps/control-plane-api/src/recover-member.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/recover-member.ts)
- [apps/control-plane-api/src/organization-routes.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/organization-routes.ts)
- [apps/control-plane-api/src/onboarding-types.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/onboarding-types.ts)
- [apps/control-plane-api/test/onboarding.spec.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/test/onboarding.spec.ts)
- [apps/control-plane-api/test/account-linking.spec.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/test/account-linking.spec.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
