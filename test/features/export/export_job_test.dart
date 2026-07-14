import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/features/export/domain/export_job.dart';
import 'package:stop_motion/features/export/domain/export_record.dart';
import 'package:stop_motion/features/projects/domain/project.dart';

import '../../helpers/export_fixtures.dart';

void main() {
  test('export settings serialize and validate deterministically', () {
    const ExportSettings settings = ExportSettings(
      format: ExportFormat.imageSequence,
      resolution: ExportResolution.hd720,
      quality: ExportQuality.high,
      gifMaximumDimension: 320,
      gifLoopMode: GifLoopMode.count,
      gifLoopCount: 4,
      imageSequenceFormat: ImageSequenceFormat.jpeg,
      framesPerSecond: 24,
    );

    final ExportSettings decoded = ExportSettings.decode(settings.encode());

    expect(decoded.toJson(), settings.toJson());
    expect(decoded.encode(), settings.encode());
    expect(decoded.validate, returnsNormally);
  });

  test('invalid transparency and GIF limits are rejected', () {
    expect(
      const ExportSettings(
        format: ExportFormat.movie,
        transparentBackground: true,
      ).validate,
      throwsFormatException,
    );
    expect(
      const ExportSettings(gifMaximumDimension: 120).validate,
      throwsFormatException,
    );
  });

  test('dimensions preserve portrait and landscape canvases', () {
    final ExportDimensions landscape = ExportDimensions.forProject(
      exportProject(),
      const ExportSettings(resolution: ExportResolution.hd720),
    );
    final ExportDimensions portrait = ExportDimensions.forProject(
      exportProject(ratio: ProjectAspectRatio.portrait),
      const ExportSettings(resolution: ExportResolution.hd720),
    );

    expect((landscape.width, landscape.height), (1280, 720));
    expect((portrait.width, portrait.height), (720, 1280));
  });
}
