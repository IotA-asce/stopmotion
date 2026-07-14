# Stop Motion

Stop Motion is a mobile-first Flutter application for capturing, editing, previewing, exporting, and sharing stop-motion films.

The repository is being rebuilt from a release specification before implementation begins. Product scope and implementation sequencing will live in:

- `docs/FINAL_STATE.md`
- `docs/DEVELOPMENT_PHASES.md`
- `docs/plans/2026-07-14-first-public-release.md`

## Development

The repository pins Flutter 3.44.6 and Dart 3.12.2. Install that Flutter version, then run:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter run
```

Android uses application ID `com.iotaasce.stopmotion` with Android 10 as the minimum. iOS uses bundle ID `com.iotaasce.stopmotion` with iOS 15 as the minimum.

## Status

Phases 1-7 are implemented in software: the Flutter foundation, durable project library, camera workspace, transactional editor, non-destructive image adjustments, synchronized preview, audio workspace, and journaled MP4/GIF/image-sequence export with system handoff are available. Physical camera, export-codec, interruption, and baseline-device memory evidence remain open in `docs/DEVELOPMENT_PHASES.md` until the device gates run.
