import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/capture_frame.dart';

abstract interface class FramePicker {
  Future<List<CaptureSource>> pickImages();
  Future<List<CaptureSource>> recoverLostImages();
}

class PackageFramePicker implements FramePicker {
  PackageFramePicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<List<CaptureSource>> pickImages() async {
    final List<XFile> files = await _picker.pickMultiImage();
    return files
        .map((XFile file) => CaptureSource(file: File(file.path)))
        .toList(growable: false);
  }

  @override
  Future<List<CaptureSource>> recoverLostImages() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return const <CaptureSource>[];
    }
    if (response.exception case final PlatformException exception) {
      throw FileSystemException(
        exception.message ?? 'The interrupted image import could not resume.',
      );
    }
    return (response.files ?? const <XFile>[])
        .map((XFile file) => CaptureSource(file: File(file.path)))
        .toList(growable: false);
  }
}
