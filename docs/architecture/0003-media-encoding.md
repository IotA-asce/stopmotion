# ADR 0003: Media Encoding

**Status:** Selected with physical-device and distribution proof required

## Context

Version 1.0 requires H.264/AAC MP4, GIF, and image-sequence export with progress, cancellation, interruption cleanup, and broad playback compatibility.

## Options evaluated

| Option | Compatibility and lifecycle | Maintenance and size | License and policy | Result |
| --- | --- | --- | --- | --- |
| Direct `MediaCodec` / `AVAssetWriter` adapters | Full control, but a second custom audio decoder/mixer and muxer would be required | Largest application-owned native maintenance surface | Platform codecs avoid bundled codec licenses | Rejected for 1.0 delivery risk |
| `flutter_story_encoder` plus custom audio muxing | Hardware H.264 and progress; built-in audio is silent only | Small MIT package, but still requires a custom cross-platform mixer/muxer | MIT | Rejected because it cannot export the editor mix |
| Full FFmpegKit forks | Complete filters, codecs, probing, cancellation, and progress | Large native bundle; maintained fork | Full builds include GPL codecs such as x264/x265 | Rejected because GPL/App Store distribution is not approved |
| `ffmpeg_kit_flutter_new_min` | FFmpeg/FFprobe, AAC, platform H.264 encoders, filter graphs, statistics, and per-session cancellation | Minimal maintained fork, but still increases binary size materially | LGPL-3.0; no GPL external codec libraries in the selected variant | Selected pending legal/distribution evidence |

## Decision

Keep `ExportEngine`, command runner, preflight, and output-validator interfaces package-independent. Use `ffmpeg_kit_flutter_new_min` only behind the platform adapter, select `h264_mediacodec` on Android and `h264_videotoolbox` on iOS, encode AAC with FFmpeg's native encoder, and validate finished media independently through FFprobe. GIF uses the same bounded native process; image sequences stream through the Dart `archive` package.

The application renders one adjusted source frame at a time into a journal-owned temporary directory. FFmpeg consumes a concat timeline with exact hold durations and an audio filter graph containing trims, offsets, fades, clip volume, and master volume. Every terminal path removes temporary data; only a validated final output is recorded as complete.

Selection does not satisfy the physical-device gate by itself. Release approval still requires Android and iOS device outputs plus confirmation that LGPL notices, source offer, relinking requirements, native-binary packaging, and App Store terms are compatible with the chosen distribution process.

## Consequences

- UI and repositories depend only on package-independent export states.
- Full-GPL FFmpeg packages and x264/x265 are prohibited unless product licensing and distribution scope are explicitly changed.
- Android API 29 and iOS 15 exceed the selected package's documented minimums.
- Native build size, physical codec availability, output compatibility, and LGPL distribution obligations remain measured release inputs.
