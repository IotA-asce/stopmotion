import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/features/projects/domain/project.dart';

void main() {
  test('draft validates title and frame rate', () {
    expect(
      () => ProjectDraft(
        title: '  ',
        aspectRatio: ProjectAspectRatio.widescreen,
        resolution: ProjectResolution.fullHd1080,
        framesPerSecond: 12,
        backgroundColorValue: 0,
      ),
      throwsFormatException,
    );
    expect(
      () => ProjectDraft(
        title: 'Film',
        aspectRatio: ProjectAspectRatio.widescreen,
        resolution: ProjectResolution.fullHd1080,
        framesPerSecond: 31,
        backgroundColorValue: 0,
      ),
      throwsFormatException,
    );
  });

  test('duration derives from frame holds and project fps', () {
    final Project project = Project(
      id: 'one',
      title: 'Film',
      aspectRatio: ProjectAspectRatio.widescreen,
      resolution: ProjectResolution.fullHd1080,
      framesPerSecond: 12,
      backgroundColorValue: 0,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      status: ProjectStatus.draft,
      frameCount: 20,
      durationFrames: 24,
      currentRevision: 2,
      lastExportedRevision: 2,
    );

    expect(project.duration, const Duration(seconds: 2));
    expect(project.isCurrentRevisionExported, isTrue);
  });
}
