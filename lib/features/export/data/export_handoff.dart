import 'dart:io';
import 'dart:ui';

import 'package:gal/gal.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../domain/export_record.dart';

enum ExportHandoffResult { complete, dismissed, denied, unavailable, failed }

abstract interface class ExportHandoff {
  Future<ExportHandoffResult> share(File file, {Rect? origin});
  Future<ExportHandoffResult> save(
    File file,
    ExportFormat format, {
    Rect? origin,
  });
  Future<ExportHandoffResult> open(File file);
}

class SystemExportHandoff implements ExportHandoff {
  const SystemExportHandoff();

  @override
  Future<ExportHandoffResult> share(File file, {Rect? origin}) async {
    try {
      final ShareResult result = await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[XFile(file.path, mimeType: _mime(file))],
          fileNameOverrides: <String>[p.basename(file.path)],
          title: 'Stop Motion export',
          sharePositionOrigin: origin,
        ),
      );
      return switch (result.status) {
        ShareResultStatus.success => ExportHandoffResult.complete,
        ShareResultStatus.dismissed => ExportHandoffResult.dismissed,
        ShareResultStatus.unavailable => ExportHandoffResult.unavailable,
      };
    } on Object {
      return ExportHandoffResult.failed;
    }
  }

  @override
  Future<ExportHandoffResult> save(
    File file,
    ExportFormat format, {
    Rect? origin,
  }) async {
    if (format == ExportFormat.imageSequence) {
      return share(file, origin: origin);
    }
    try {
      bool allowed = await Gal.hasAccess();
      if (!allowed) allowed = await Gal.requestAccess();
      if (!allowed) return ExportHandoffResult.denied;
      if (format == ExportFormat.movie) {
        await Gal.putVideo(file.path);
      } else {
        await Gal.putImage(file.path);
      }
      return ExportHandoffResult.complete;
    } on GalException catch (error) {
      return error.type == GalExceptionType.accessDenied
          ? ExportHandoffResult.denied
          : ExportHandoffResult.failed;
    } on Object {
      return ExportHandoffResult.failed;
    }
  }

  @override
  Future<ExportHandoffResult> open(File file) async {
    final OpenResult result = await OpenFile.open(file.path, type: _mime(file));
    return switch (result.type) {
      ResultType.done => ExportHandoffResult.complete,
      ResultType.permissionDenied => ExportHandoffResult.denied,
      ResultType.noAppToOpen => ExportHandoffResult.unavailable,
      ResultType.fileNotFound || ResultType.error => ExportHandoffResult.failed,
    };
  }

  static String _mime(File file) =>
      switch (p.extension(file.path).toLowerCase()) {
        '.mp4' => 'video/mp4',
        '.gif' => 'image/gif',
        '.zip' => 'application/zip',
        _ => 'application/octet-stream',
      };
}
