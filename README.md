# Stop Motion

Stop Motion is a mobile-first Flutter application for capturing, editing, previewing, exporting, and sharing stop-motion films.

The release contract, progress tracker, and implementation sequencing live in:

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

Phases 1-8 are implemented in software: the Flutter foundation, durable project library, camera workspace, transactional editor, non-destructive image adjustments, synchronized preview, audio workspace, journaled MP4/GIF/image-sequence export, recovery, settings, storage, and diagnostics are available. Phase 9 adds automated accessibility, adaptation, performance, privacy, and release-safety evidence. The app is not yet a public release: physical camera, codec, accessibility, interruption, performance, memory, signed-artifact, and FFmpeg license/distribution gates remain open in `docs/DEVELOPMENT_PHASES.md`.
