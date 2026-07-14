# Privacy Review

## Observed data handling

- Projects, source frames, imported audio, metadata, cache, exports, and operation journals remain in app-owned local storage.
- The app contains no application network client or analytics SDK. Android debug/profile Internet permissions are template-only; the release manifest has no Internet permission.
- Camera and microphone access are requested only when their capture/recording interactions are used. Photo-library access on iOS is limited to user-initiated import/save flows.
- A user can explicitly share an export or optional redacted diagnostic ZIP through the operating system.
- Diagnostic ZIP files contain build/platform/schema data, a bounded allowlisted log, and dependency notices. They exclude project titles, frame/audio content, media names, source paths, and secrets.

## Store declaration inputs

| Data category | Collected by app | Leaves device without user action | Purpose |
| --- | --- | --- | --- |
| Photos/video and audio | No | No | Created/imported locally for user projects |
| Project metadata | No | No | Local editing and recovery |
| Diagnostics | No | No | Optional user-initiated support sharing |
| Identifiers/analytics | No | No | Not implemented |

## Required release re-check

Verify actual signed Android/iOS builds, all transitive dependencies, store SDK reports, and support/share destinations before submitting store privacy answers.
