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

Phase-specific packages are added only on the branch that implements them. `pubspec.lock` is committed so application builds resolve the tested versions.

## Documentation Note

Context7 was available for implementation queries on 2026-07-14. Package selection used official or high-reputation IDs and separate concept queries. The installed SDK was verified with `flutter --version`; package versions were resolved by `flutter pub add` and locked by Flutter.
