# Stop Motion

An offline-first Flutter app for planning, capturing, editing, previewing, and exporting stop-motion films on Android and iOS.

Stop Motion is designed as a focused creative workbench: projects stay on the device, accepted frames are persisted before they appear in the timeline, edits are non-destructive, and exports can be shared without requiring an account or network connection.

> **Project status:** Development preview. The core product is implemented and covered by automated tests, but the first public release remains blocked on physical-device validation, production signing, and release compliance checks. See [release readiness](#release-readiness) for details.

## Capabilities

- Create local projects with configurable aspect ratio, frame rate, and export resolution.
- Capture frames through the device camera with onion skin, grid overlays, focus and exposure controls, timers, interval capture, and duplicate-tap protection.
- Import image sequences into project-owned storage so picker permissions and temporary files cannot break a project later.
- Arrange frames in a virtualized timeline with multi-select, reordering, duplicate, reverse, hold, undo, and redo.
- Apply non-destructive crop, transform, fit/fill, color, and sharpening adjustments.
- Preview at project timing with fullscreen transport, scrubbing, looping, and retained workspace state.
- Record or import audio, edit clips on a timeline, generate waveforms, and mix audio into preview and export.
- Export MP4, GIF, or PNG/JPEG image-sequence ZIPs with preflight validation, progress, cancellation, cleanup, and recovery.
- Recover interrupted capture, import, duplicate, delete, migration, and export operations without silently discarding valid work.
- Manage storage, accessibility preferences, privacy information, help, and redacted diagnostics from Settings.

The complete first-release behavior, navigation, visual system, and quality requirements are defined in [the product contract](docs/FINAL_STATE.md).

## Platform Support

| Platform | Minimum version | Identifier |
| --- | --- | --- |
| Android | Android 10 (API 29) | `com.iotaasce.stopmotion` |
| iOS | iOS 15 | `com.iotaasce.stopmotion` |

Phones are the primary target. The editor adapts to portrait, landscape, and wider tablet layouts.

## Architecture

The app is built around local ownership and recoverable operations:

- Flutter and Material 3 provide the application shell and adaptive interface.
- Riverpod owns dependency injection and screen state; GoRouter provides restored workspace navigation.
- Drift and SQLite store projects, timelines, settings, and operation journals transactionally.
- Project media is copied into application-owned storage and accepted through atomic file operations.
- Camera, audio, image, and export packages sit behind testable service contracts.

Architecture decisions and dependency rationale are available in [the architecture records](docs/architecture) and [dependency record](docs/architecture/dependencies.md).

## Getting Started

### Prerequisites

- [Flutter 3.44.6](https://docs.flutter.dev/get-started/install) on the stable channel. The repository version is pinned in [`.fvmrc`](.fvmrc).
- Dart 3.12.2, included with the required Flutter SDK.
- Android Studio and an Android 10+ device or emulator for Android development.
- Xcode and an iOS 15+ simulator or device for iOS development on macOS.

### Run locally

```bash
git clone https://github.com/IotA-asce/stopmotion.git
cd stopmotion
flutter pub get
flutter run
```

Use the device selector in your Flutter tooling to choose an Android or iOS target. Camera, microphone, media-library, codec, lifecycle, and storage behavior require testing on physical devices before release.

## Verification

Run these checks before opening a pull request:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
bash tool/release_safety_check.sh
```

Continuous integration runs formatting, analysis, tests, an Android debug build, and an iOS no-codesign build for pushes and pull requests. See [the validation workflow](.github/workflows/validate.yml).

## Android Tester Builds

Tags matching `V*` produce GitHub prereleases with separate, signature-verified release-mode APKs and a `SHA256SUMS.txt` file:

| Artifact | Intended target |
| --- | --- |
| `arm64-v8a` | Most physical Android phones and tablets |
| `armeabi-v7a` | Older 32-bit Android devices |
| `x86_64` | Android emulators and rare Intel devices |

Download builds from [GitHub Releases](https://github.com/IotA-asce/stopmotion/releases). These artifacts are test-signed for evaluation only and are not production Play Store releases.

## Privacy And Data

Stop Motion has no account system, crash reporting, automatic uploads, or automatic network transfer. Projects and media remain local unless a user explicitly imports, saves, opens, or shares a file through the operating system.

The release safety and data-handling approach is documented in [data safety](docs/release/data-safety.md). Diagnostic exports are designed to exclude project content, project names, media names, private paths, and secrets.

## Documentation

- [First public release product contract](docs/FINAL_STATE.md)
- [Development phase checklist](docs/DEVELOPMENT_PHASES.md)
- [Detailed implementation plan](docs/plans/2026-07-14-first-public-release.md)
- [Architecture decisions](docs/architecture)
- [Accessibility test plan](docs/test-plans/accessibility.md)
- [Performance test plan](docs/test-plans/performance.md)
- [Device matrix](docs/release/device-matrix.md)
- [Privacy review](docs/release/privacy-review.md)

## Contributing

Keep changes narrowly scoped and follow the repository workflow:

1. Create a dedicated branch from `main`.
2. Update the product contract and phase checklist when approved product scope or release behavior changes.
3. Run the verification commands above for the area you changed.
4. Commit only validated work, merge it into `main`, and push the result.

Repository-specific conventions are in [`AGENTS.md`](AGENTS.md).

## Release Readiness

The automated implementation is extensive, but Stop Motion is not yet a public 1.0 release. Remaining gates include physical-device camera and codec validation, TalkBack and VoiceOver journeys, accessibility and adaptive-layout checks, performance and memory measurements, interruption and low-storage drills, signed Android/iOS artifacts, and FFmpeg distribution and licensing review.

The tracked checklist and evidence are maintained in [the development phases](docs/DEVELOPMENT_PHASES.md).
