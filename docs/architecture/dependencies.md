# Dependency Record

## Toolchain

| Component | Selected | Reason |
| --- | --- | --- |
| Flutter | 3.44.6 stable | Current stable Homebrew cask on 2026-07-14 |
| Dart | 3.12.2 | Bundled with Flutter 3.44.6 |
| Android minimum | API 29 / Android 10 | Public-release support contract |
| iOS minimum | iOS 15.0 | Public-release support contract |
| Java | 17 | Flutter Android template toolchain |

## Runtime Packages

| Package | Constraint | Owner | Purpose | Decision source |
| --- | --- | --- | --- | --- |
| `flutter_riverpod` | `^3.3.2` | Riverpod | Dependency injection and state ownership | Context7 Riverpod 3.3 docs |
| `go_router` | `^17.3.0` | flutter.dev | URL routing and stateful shell | Context7 and pub.dev |
| `drift` | `^2.34.2` | simonbinder.eu | Typed SQLite schema, transactions, migrations, and watched queries | Context7 Drift documentation |
| `path` | `^1.9.1` | dart.dev | Portable project-owned relative paths | Dart package API and locked resolution |
| `path_provider` | `^2.1.6` | flutter.dev | Application support and disposable cache roots | Context7 Flutter packages documentation |
| `shared_preferences` | `^2.5.5` | flutter.dev | Onboarding completion plus small persistent user settings through `SharedPreferencesAsync` | Context7 Flutter packages documentation |
| `uuid` | `^4.5.3` | Dart community | Collision-resistant local entity and journal IDs | Package API and locked resolution |
| `image` | `^4.9.1` | Brendan Duncan | Validated decoding plus bounded non-destructive crop, transform, color, sharpening, fit/fill, preview, and thumbnail rendering | Context7 `/brendan-duncan/image` 4.9 documentation |
| `camera` | `^0.12.0+2` | flutter.dev | Camera preview, JPEG capture, focus/exposure, zoom, flash, and camera switching behind `CameraService` | Context7 `/websites/pub_dev_packages_camera` documentation |
| `image_picker` | `^1.2.3` | flutter.dev | Single/batch system image selection and Android lost-data recovery | Context7 `/flutter/packages` documentation |
| `permission_handler` | `^12.0.3` | Baseflow | Opens system app settings after camera denial; does not request permissions during onboarding | Context7 `/baseflow/flutter-permission-handler` documentation |
| `wakelock_plus` | `^1.6.1` | Flutter Community | Capture-workspace wake lock with explicit interval start/stop ownership | Context7 `/fluttercommunity/wakelock_plus` documentation |
| `record` | `^7.1.1` | llfbandit | AAC/M4A narration recording, permission request, pause/resume, and amplitude metering behind `AudioRecordingService` | Context7 `/llfbandit/record` documentation |
| `file_selector` | `^1.1.0` | flutter.dev | First-party native audio-file selection returning an `XFile` for immediate application-owned copying | Context7 `/flutter/packages` file_selector documentation |
| `audio_waveforms` | `^2.0.2` | simformsolutions | Native, cancellable waveform extraction with application-bounded sample caching | Context7 `/websites/pub_dev_audio_waveforms` documentation |
| `just_audio` | `^0.10.6` | Ryan Heise | Local audio probing and per-clip playback adapter with position streams, trim sources, seek, and disposal | Context7 `/ryanheise/just_audio` documentation |
| `audio_session` | `^0.2.4` | Ryan Heise | Explicit record/playback audio focus, interruption, and headphone-route handling | Context7 `/ryanheise/audio_session` documentation |
| `archive` | `^4.0.7` | Dart community | Streaming ZIP creation and central-directory validation for image sequences and diagnostics | Package API and locked resolution; Context7 had no exact package record |
| `ffmpeg_kit_flutter_new_min` | `^3.3.2` | antonkarpenko.com | Minimal LGPL FFmpeg/FFprobe adapter for platform H.264, AAC mixing, GIF, progress, cancellation, and independent validation | Context7 FFmpegKit API plus current package documentation; ADR 0003 |
| `share_plus` | `^13.2.0` | flutter.dev community | Android/iOS system share sheet with explicit success, dismissal, and unavailable results | Context7 `/websites/pub_dev_packages_share_plus` documentation |
| `gal` | `^2.3.2` | Midori Design Studio | User-initiated MP4/GIF save to the system media library with on-action permission handling | Context7 `/natsuk4ze/gal` documentation |
| `open_file` | `^4.0.0` | Flutter community | Open completed local exports with a registered system application | Current package documentation and locked resolution |

## Development Packages

| Package | Constraint | Purpose |
| --- | --- | --- |
| `build_runner` | `^2.15.1` | Repeatable source generation |
| `drift_dev` | `^2.34.0` | Drift table and database generation |
| `flutter_lints` | `^6.0.0` | Baseline analyzer rules extended by `analysis_options.yaml` |

Phase-specific packages are added only on the branch that implements them. `pubspec.lock` is committed so application builds resolve the tested versions.

## Documentation Note

Context7 was available for implementation queries on 2026-07-14. Package selection used official or high-reputation IDs and separate concept queries. The installed SDK was verified with `flutter --version`; package versions were resolved by `flutter pub add` and locked by Flutter.
