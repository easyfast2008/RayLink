# Repository Guidelines

## Project Structure & Module Organization
The SwiftUI app lives in `RayLink/` and follows MVVM-C. `App/` hosts `RayLinkApp.swift` and bootstraps navigation. `Core/` keeps shared services and VPN plumbing; add reusable types here first. Place flows under `Features/` (`Home`, `ServerList`, `Settings`, `Import`). Extend styling via `Design/` instead of inline modifiers. `NetworkExtension/` and `RayLinkTunnel/` house tunnel targets and must match entitlements. Generated frameworks stay in `Frameworks/`; assets and previews live in `Resources/` and `Preview Content/`.

## Build, Test, and Development Commands
- `./build_xray.sh` builds the mock Xray framework (Go ≥1.21 + gomobile) for simulator VPN stubs.
- `./prepare_build.sh` cleans DerivedData, runs `verify_build.sh`, then opens `RayLink.xcodeproj`.
- `xcodebuild -scheme RayLink -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build` for headless CI builds.
- `xcodebuild -scheme RayLink -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test` once the XCTest target exists.

## Coding Style & Naming Conventions
Stick to Swift 5.9, four-space indentation, PascalCase types, camelCase members. Surface shared models via `Core/` (see `RayLink/Core/RayLinkTypes.swift`) and extract shared views into `Design/Components` using `AppTheme`. Register services through `DependencyContainer` with protocol-first APIs. Comment only when behavior is non-obvious; keep the `// Global types imported via RayLinkTypes` hint.

## Testing Guidelines
Add a `RayLinkTests` target and mirror feature folders. Name methods `testFeature_WhenState_ExpectResult` and rely on XCTest assertions. Use `Core/VPN/MockVPNManager.swift` so tunnels stay virtual. Future UI checks can live in `RayLinkUITests`. Run `xcodebuild -scheme RayLink -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test` locally and attach coverage notes for networking or parsing work.

## Commit & Pull Request Guidelines
Use Conventional Commit prefixes with short scopes, e.g. `feat(import): add clash yaml parser`. Keep commits atomic and include manual verification notes when touching build scripts or entitlements. PRs should link issues or `design_document.md`, summarize risk, and list required scripts (such as `build_xray.sh`). Provide before/after screenshots for UI changes; `main_page.jpg` is the reference layout.

## Security & Configuration Tips
Never commit team IDs, provisioning profiles, or subscription secrets. Mirror `RayLinkTunnel` edits in `.entitlements` and verify on a clean simulator. Keep real server URLs outside the repo and redact logs before sharing. When enabling production VPN support, follow `BUILD_INSTRUCTIONS.md` and exclude the mock framework from release targets.
