# Desktop shell build and distribution boundary

**Audience:** Desktop developers, operators. **Implementation status:** Partially Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

The employee application is Angular within a Tauri 2 shell. The Rust entrypoint builds the default Tauri application; it is not an embedded agent kernel, credential broker or executable tool host.

From the platform root, after installing Node/npm and Rust/Tauri system dependencies:

```bash
npm run tauri:dev
npm run tauri:build
```

The Tauri config starts the employee Angular development server and uses its local web preview; its frontend build points to the generated employee application. The config's CSP and default capability describe the actual webview permissions. Native build requires the appropriate Windows/Rust build toolchain.

## Implementation Status / Architecture Gap

Bundle activation is disabled in the supplied config. No signed installer release, updater feed or automated native distribution pipeline is shipped. Google login through a system-browser callback/deep-link is not implemented; the browser preview supports the OIDC path. No OS model-key storage integration or desktop-local BYOK runtime is present. Do not document imaginary deep links, installation packages or native secret-store APIs.

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/employee-desktop/src-tauri/Cargo.toml](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/employee-desktop/src-tauri/Cargo.toml)
- [apps/employee-desktop/src-tauri/tauri.conf.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/employee-desktop/src-tauri/tauri.conf.json)
- [apps/employee-desktop/src-tauri/capabilities/default.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/employee-desktop/src-tauri/capabilities/default.json)
- [apps/employee-desktop/src-tauri/src/lib.rs](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/employee-desktop/src-tauri/src/lib.rs)
- [package.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/package.json)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
