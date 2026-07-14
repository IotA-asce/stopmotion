import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:stop_motion/features/audio/domain/audio_clip.dart';
import 'package:stop_motion/features/audio/domain/audio_timeline.dart';
import 'package:stop_motion/features/editor/domain/frame.dart';
import 'package:stop_motion/features/editor/domain/timeline.dart';
import 'package:stop_motion/features/export/domain/export_job.dart';
import 'package:stop_motion/features/projects/domain/project.dart';

Project exportProject({
  ProjectAspectRatio ratio = ProjectAspectRatio.widescreen,
}) {
  final DateTime now = DateTime.utc(2026, 7, 15);
  return Project(
    id: 'project-1',
    title: 'Paper planets',
    aspectRatio: ratio,
    resolution: ProjectResolution.hd720,
    framesPerSecond: 12,
    backgroundColorValue: 0xff202020,
    createdAt: now,
    updatedAt: now,
    status: ProjectStatus.draft,
    frameCount: 1,
    durationFrames: 3,
    currentRevision: 4,
  );
}

Future<ExportRequest> exportRequest(
  Directory root, {
  ExportSettings settings = const ExportSettings(),
  bool withFrame = true,
  bool withAudio = false,
}) async {
  const String frameRelative = 'projects/project-1/frames/frame-1.jpg';
  if (withFrame) {
    final File frame = File(p.join(root.path, frameRelative));
    await frame.parent.create(recursive: true);
    final img.Image source = img.Image(width: 24, height: 16);
    img.fill(source, color: img.ColorRgb8(40, 180, 90));
    await frame.writeAsBytes(img.encodeJpg(source));
  }
  const String audioRelative = 'projects/project-1/audio/voice.m4a';
  if (withAudio) {
    final File audio = File(p.join(root.path, audioRelative));
    await audio.parent.create(recursive: true);
    await audio.writeAsBytes(<int>[1, 2, 3]);
  }
  final ProjectFrame frame = ProjectFrame(
    id: 'frame-1',
    projectId: 'project-1',
    relativeSourcePath: frameRelative,
    position: 0,
    holdFrames: 3,
    createdAt: DateTime.utc(2026, 7, 15),
    sourceWidth: 24,
    sourceHeight: 16,
    missing: false,
  );
  return ExportRequest(
    id: 'export-1',
    project: exportProject(),
    timeline: TimelineSnapshot(
      frames: withFrame ? <ProjectFrame>[frame] : <ProjectFrame>[],
      fps: 12,
    ),
    audio: AudioTimeline(
      projectId: 'project-1',
      projectDurationMilliseconds: 250,
      clips: withAudio
          ? <AudioClip>[
              AudioClip(
                id: 'audio-1',
                projectId: 'project-1',
                relativeSourcePath: audioRelative,
                name: 'Voice',
                trackType: AudioTrackType.narration,
                startMilliseconds: 40,
                trimStartMilliseconds: 100,
                trimEndMilliseconds: 300,
                volume: 0.8,
                fadeInMilliseconds: 20,
                fadeOutMilliseconds: 30,
                muted: false,
              ),
            ]
          : const <AudioClip>[],
      masterVolume: 0.7,
    ),
    settings: settings,
    projectRoot: root,
    temporaryDirectory: Directory(p.join(root.path, 'tmp', 'export-1')),
    output: File(
      p.join(root.path, 'exports', switch (settings.format) {
        _ when settings.format.name == 'movie' => 'result.mp4',
        _ when settings.format.name == 'gif' => 'result.gif',
        _ => 'result.zip',
      }),
    ),
  );
}
