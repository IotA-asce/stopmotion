import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/core/media/export_engine.dart';
import 'package:stop_motion/features/export/domain/export_job.dart';

import '../../helpers/export_fixtures.dart';

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('export_preflight_');
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('preflight blocks empty and missing frame sources', () async {
    final ExportPreflightService service = ExportPreflightService(
      availableStorage: (Directory _) async => 1024 * 1024 * 1024,
    );
    final ExportPreflight empty = await service.inspect(
      await exportRequest(root, withFrame: false),
    );
    final request = await exportRequest(root);
    await File(
      '${root.path}/${request.timeline.frames.first.relativeSourcePath}',
    ).delete();
    final ExportPreflight missing = await service.inspect(request);

    expect(empty.canExport, isFalse);
    expect(empty.issues.single.code, ExportIssueCode.noFrames);
    expect(missing.canExport, isFalse);
    expect(missing.issues.single.frameId, 'frame-1');
  });

  test('preflight estimates output and blocks insufficient storage', () async {
    final request = await exportRequest(root);
    final ExportPreflightService service = ExportPreflightService(
      availableStorage: (Directory _) async => 1,
    );

    final ExportPreflight result = await service.inspect(request);

    expect(result.estimatedBytes, greaterThan(0));
    expect(
      result.issues.map((ExportIssue issue) => issue.code),
      contains(ExportIssueCode.insufficientStorage),
    );
  });

  test('cancellation token invokes listeners once and throws', () {
    final ExportCancellationToken token = ExportCancellationToken();
    var calls = 0;
    token.onCancel(() => calls++);

    token
      ..cancel()
      ..cancel();

    expect(calls, 1);
    expect(token.throwIfCancelled, throwsA(isA<ExportCancelled>()));
  });
}
