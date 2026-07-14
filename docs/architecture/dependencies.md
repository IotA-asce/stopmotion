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
| `shared_preferences` | `^2.5.5` | flutter.dev | Small onboarding completion preference | Context7 Flutter packages documentation |
| `uuid` | `^4.5.3` | Dart community | Collision-resistant local entity and journal IDs | Package API and locked resolution |
| `image` | `^4.9.1` | Brendan Duncan | Validated image decoding, EXIF orientation, and bounded JPEG thumbnails | Context7 `/brendan-duncan/image` documentation |

## Development Packages

| Package | Constraint | Purpose |
| --- | --- | --- |
| `build_runner` | `^2.15.1` | Repeatable source generation |
| `drift_dev` | `^2.34.0` | Drift table and database generation |
| `flutter_lints` | `^6.0.0` | Baseline analyzer rules extended by `analysis_options.yaml` |

Phase-specific packages are added only on the branch that implements them. `pubspec.lock` is committed so application builds resolve the tested versions.

## Documentation Note

Context7 was available for implementation queries on 2026-07-14. Package selection used official or high-reputation IDs and separate concept queries. The installed SDK was verified with `flutter --version`; package versions were resolved by `flutter pub add` and locked by Flutter.
