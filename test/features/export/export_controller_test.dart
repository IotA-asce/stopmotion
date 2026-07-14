import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/features/export/data/export_handoff.dart';
import 'package:stop_motion/features/export/data/export_repository.dart';
import 'package:stop_motion/features/export/domain/export_job.dart';
import 'package:stop_motion/features/export/domain/export_record.dart';
import 'package:stop_motion/features/export/presentation/export_controller.dart';

import '../../helpers/export_fixtures.dart';

class _FakeGateway implements ExportGateway {
  _FakeGateway(this.request);

  final ExportRequest request;
  bool waitForCancellation = false;

  @override
  Future<ExportRequest> createRequest(
    String projectId,
    ExportSettings settings, {
    String? id,
  }) async => request;

  @override
  Future<ExportSettings?> previousSuccessfulSettings(String projectId) async =>
      const ExportSettings(format: ExportFormat.gif, gifMaximumDimension: 320);

  @override
  Future<ExportPreflight> preflight(
    String projectId,
    ExportSettings settings,
  ) async => ExportPreflight(
    issues: const <ExportIssue>[],
    estimatedBytes: 1000,
    dimensions: const ExportDimensions(320, 180),
    duration: const Duration(seconds: 1),
  );

  @override
  Future<ExportResult> run(
    ExportRequest request, {
    required ExportCancellationToken cancellation,
    required void Function(ExportProgress progress) onProgress,
  }) async {
    onProgress(
      const ExportProgress(
        stage: ExportStage.rendering,
        fraction: 0.5,
        elapsed: Duration(milliseconds: 10),
      ),
    );
    if (waitForCancellation) {
      while (!cancellation.isCancelled) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      throw const ExportCancelled();
    }
    await request.output.parent.create(recursive: true);
    await request.output.writeAsBytes(<int>[1, 2, 3]);
    return ExportResult(
      output: request.output,
      bytes: 3,
      duration: const Duration(seconds: 1),
    );
  }
}

class _FakeHandoff implements ExportHandoff {
  ExportHandoffResult result = ExportHandoffResult.complete;

  @override
  Future<ExportHandoffResult> open(File file) async => result;

  @override
  Future<ExportHandoffResult> save(
    File file,
    ExportFormat format, {
    Rect? origin,
  }) async => result;

  @override
  Future<ExportHandoffResult> share(File file, {Rect? origin}) async => result;
}

void main() {
  late Directory root;
  late _FakeGateway gateway;
  late _FakeHandoff handoff;
  late ExportController controller;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('export_controller_');
    gateway = _FakeGateway(await exportRequest(root));
    handoff = _FakeHandoff();
    controller = ExportController(
      projectId: 'project-1',
      repository: gateway,
      handoff: handoff,
    );
  });

  tearDown(() async {
    controller.dispose();
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('loads previous successful settings and completes export', () async {
    await controller.initialize();

    expect(controller.state.status, ExportViewStatus.ready);
    expect(controller.state.settings.format, ExportFormat.gif);

    await controller.export();

    expect(controller.state.status, ExportViewStatus.complete);
    expect(controller.state.output, isNotNull);
    expect(controller.state.progress?.fraction, 1);
  });

  test('share dismissal remains a successful completed export', () async {
    await controller.initialize();
    await controller.export();
    handoff.result = ExportHandoffResult.dismissed;

    await controller.share();

    expect(controller.state.status, ExportViewStatus.complete);
    expect(controller.state.handoffMessage, contains('ready to share'));
  });

  test('cancel transitions without retaining output', () async {
    gateway.waitForCancellation = true;
    await controller.initialize();
    final Future<void> running = controller.export();
    await Future<void>.delayed(const Duration(milliseconds: 5));

    controller.cancel();
    await running;

    expect(controller.state.status, ExportViewStatus.cancelled);
    expect(controller.state.output, isNull);
  });
}
