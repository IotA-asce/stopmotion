# Dependency Review

## Runtime review

| Area | Package family | Review result |
| --- | --- | --- |
| State/database | Riverpod, Drift | Local state and SQLite only; no network behavior observed. |
| Media capture/audio | camera, image_picker, record, audio_waveforms, just_audio, audio_session | Runtime permission behavior is user-action scoped; verify final native binary privacy manifests on device. |
| Files/system handoff | path_provider, file_selector, share_plus, gal, open_file, shared_preferences, wakelock_plus | Local storage and system handoff only; review platform plugin releases before 1.0 tagging. |
| Rendering/export | image, archive, ffmpeg_kit_flutter_new_min | FFmpegKit minimal LGPL distribution obligations remain a release blocker until legal/distribution and device codec evidence are recorded. |
| Permissions | permission_handler | Used only for opening platform app settings after user-facing denial. |

## License action

The in-app Flutter license page exposes bundled notices. The diagnostic archive includes a concise dependency notice. Before release, record full license texts, source-offer/relinking analysis for FFmpegKit, native binary inventory, and any store policy decision in the release report.
