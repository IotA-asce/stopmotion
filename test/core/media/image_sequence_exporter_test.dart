import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/media/image_sequence_exporter.dart';
import 'package:stop_motion/features/export/domain/export_job.dart';
import 'package:stop_motion/features/export/domain/export_record.dart';

import '../../helpers/export_fixtures.dart';

void main() {
  test('ZIP contains ordered frame and deterministic manifest', () async {
    final Directory root = await Directory.systemTemp.createTemp('sequence_');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });
    final request = await exportRequest(
      root,
      settings: const ExportSettings(
        format: ExportFormat.imageSequence,
        resolution: ExportResolution.hd720,
        imageSequenceFormat: ImageSequenceFormat.png,
      ),
    );

    final result = await const ImageSequenceExporter().export(
      request,
      cancellation: ExportCancellationToken(),
      onProgress: (_) {},
    );
    final Archive archive = ZipDecoder().decodeBytes(
      await result.output.readAsBytes(),
      verify: true,
    );
    final List<String> names = archive.files
        .map((ArchiveFile file) => file.name)
        .toList();
    final ArchiveFile manifest = archive.files.singleWhere(
      (ArchiveFile file) => file.name == 'manifest.json',
    );
    final Map<String, Object?> json =
        jsonDecode(utf8.decode(manifest.content as List<int>))
            as Map<String, Object?>;

    expect(names, <String>['frame_000000.png', 'manifest.json']);
    expect(json['projectTitle'], 'Paper planets');
    expect(json['fps'], 12);
    expect(json['width'], 1280);
    expect(json['height'], 720);
    expect((json['frames'] as List<Object?>).single, <String, Object?>{
      'file': 'frame_000000.png',
      'holdFrames': 3,
    });
    expect(await request.temporaryDirectory.exists(), isFalse);
  });
}
