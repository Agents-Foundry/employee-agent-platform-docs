# Authentication, sessions and browser origins

**Audience:** Security reviewers, operators, developers. **Implementation status:** Partially Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

The server defaults to Google mode; missing Google configuration fails startup. `AUTH_MODE=password` selects database-managed account login. `AUTH_MODE=demo` is an explicit local-only mode and is rejected with `NODE_ENV=production`.

| Mode | Identity source | Limit |
| --- | --- | --- |
| Google | OIDC verified issuer, RS256 signature, audience/authorized party, nonce, hosted-domain and verified email; operator directory maps subject to employee | One configured Workspace domain; native Tauri system-browser/deep-link flow absent |
| Password | Salted scrypt application password and global account membership | No built-in MFA or automatic email recovery |
| Demo | Known local demo headers and seeded records | Publicly forgeable local identity; never a production boundary |

Google uses state/nonce/PKCE with one-use browser-bound transactions (ten-minute expiry). Application sessions use random tokens stored only as hashes, expire after eight hours, and resolve live memberships on each request. Production cookies use `__Host-`, Secure, HttpOnly, Path=/ and SameSite=Lax; localhost development omits Secure and the prefix.

Mutations require an exact configured UI Origin; no Origin, `null` and foreign origins are refused. CORS and SameSite are additional controls, not substitutes for authorization. Sign-out deletes the application session and clears its cookie; it does not sign out of the identity provider globally.

Password hashing is asynchronous scrypt with random salts. Sign-in failures are generic and throttled by source IP and normalized email, with a bounded number of concurrent checks. Limits are process-local; a reverse proxy and multiple instances need appropriate shared edge limits. Browser `x-actor-*` headers have no authority in Google/password mode.

## Operator configuration

All configured app/API authentication URLs must use matching hostnames and schemes. Production requires HTTPS. Google callback path is exactly `/api/auth/callback`; localhost ports may differ for development. Configure the verified Google subject allow-list at `IDENTITY_DIRECTORY_PATH`; no first-user administrator elevation occurs. Directory changes are loaded on restart; use secure offboarding rather than assuming provider suspension instantly revokes a still-valid local session.

Detailed provider setup is preserved at the pinned [Google Workspace source guide](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/docs/google-workspace.md). Its historical production-limit statements must be read with the current secret-broker and RLS implementation matrix.

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/control-plane-api/src/auth.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/auth.ts)
- [apps/control-plane-api/src/passwords.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/passwords.ts)
- [apps/control-plane-api/src/identity-directory.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/identity-directory.ts)
- [apps/control-plane-api/test/auth.spec.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/test/auth.spec.ts)
- [apps/control-plane-api/test/password.spec.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/test/password.spec.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
