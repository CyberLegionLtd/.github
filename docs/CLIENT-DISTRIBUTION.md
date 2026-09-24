# Shipping a product as mobile apps and browser extensions

Every CyberLegion product (CLP, ONE, spoke, solution or app) is shipped to
phones and browsers by the same shared **client hosts**. A product repository
never contains mobile or extension code. It supplies one small **client
descriptor** per host and calls a reusable workflow from this repository.

```text
your repo                         shared, owned by CLP
─────────                         ────────────────────
distribution/clients/mobile.json ─┐
                                  ├─> clp-client-mobile.yml    ─> clp-client-host-mobile    ─> .apk/.aab, iOS app
distribution/clients/extension.json┘
                                  └─> clp-client-extension.yml ─> clp-client-host-extension ─> Chrome/Edge/Firefox/Safari
```

The host renders your product's existing web application from its own origin.
Your application keeps its own API, SDK, identity and CLP execution path. The
host adds device integration only.

| Host | Repository | Platforms | Foundation |
|---|---|---|---|
| `mobile` | `clp-client-host-mobile` | `ios`, `android` | Capacitor over the CLP React presentation layer ([ADR-0002](https://github.com/CyberLegionLtd/clp-clients/blob/dev/docs/adr/ADR-0002-capacitor-mobile-host-foundation.md)) |
| `extension` | `clp-client-host-extension` | `chrome`, `edge`, `firefox`, `safari` | Manifest V3 |
| `desktop` | `clp-client-host-desktop` | `windows`, `macos`, `linux` | Tauri v2 (descriptor supplied at start-up; no reusable build workflow yet) |

## 1. Add a descriptor

The contract is `@cyberlegionltd/clp-client-core` (`resolveClientDescriptor`).
Resolution fails closed, so a descriptor the host cannot honour stops the build
with a diagnostic instead of shipping something different.

`distribution/clients/mobile.json`:

```json
{
  "appId": "example.field-app",
  "host": "mobile",
  "entry": "https://app.example.com/",
  "sdk": "example-sdk",
  "theme": "example",
  "shell": "app-shell",
  "permissions": ["camera", "notifications"],
  "deepLinkScheme": "exampleapp"
}
```

`distribution/clients/extension.json`:

```json
{
  "appId": "example.field-app",
  "host": "extension",
  "entry": "https://app.example.com/",
  "permissions": ["side-panel"]
}
```

Rules both hosts enforce:

- `entry` must be `https` and must not embed credentials. Navigation is confined
  to that origin.
- `permissions` must be ones the host supports, or packaging fails:
  - mobile: `notifications`, `camera`, `microphone`, `location`, `biometrics`, `photos`
  - extension: `notifications`, `side-panel` (Chromium and Firefox only)
- `deepLinkScheme` is supported by mobile only. The extension host refuses it.

## 2. Add the workflow

In your repository, open **Actions → New workflow** and choose **CLP mobile
apps** or **CLP browser extensions** under "By CyberLegionLtd". Or add it by
hand:

```yaml
jobs:
  mobile:
    uses: CyberLegionLtd/.github/.github/workflows/clp-client-mobile.yml@v1
    with:
      descriptor: distribution/clients/mobile.json
      bundle-id: co.uk.cyberlegion.example.app   # optional
      display-name: Example                      # optional
    secrets: inherit

  extension:
    uses: CyberLegionLtd/.github/.github/workflows/clp-client-extension.yml@v1
    with:
      descriptor: distribution/clients/extension.json
      version: 1.0.0
      platforms: chrome,edge,firefox,safari
    secrets: inherit
```

## 3. Secrets

| Secret | Needed for | Notes |
|---|---|---|
| `CLP_HOSTS_READ_TOKEN` | all builds | `contents:read` on `clp-client-host-mobile`, `clp-client-host-extension`, `clp-registry` and `base-registry`. Set it once as an organisation secret. |
| `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` | signed Android release | Without them the workflow builds an unsigned debug APK. |

## What you get

| Workflow | Artifact |
|---|---|
| mobile, android | `clp-client-android`: debug APK, or a signed AAB/APK when a keystore is supplied |
| mobile, ios | `clp-client-ios-simulator`: unsigned simulator build |
| extension | `clp-client-extensions`: one store-ready zip per browser |
| extension, safari | `clp-client-extension-safari-macos`: unsigned macOS app containing the extension |

## Not done yet

- **iOS and Safari signing and store upload.** These need an Apple Developer
  team, certificates and provisioning profiles, which are not provisioned yet.
- **Store publishing** (Play Console, App Store Connect, Chrome Web Store, AMO,
  Edge Add-ons). The workflows stop at artifacts.
- **Host status.** `mobile` and `extension` stay `logical` in the `clp-clients`
  registry until they pass conformance against a real CLP environment.
