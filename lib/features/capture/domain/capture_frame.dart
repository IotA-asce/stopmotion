import 'dart:io';

import '../../editor/domain/frame.dart';

class CaptureSource {
  const CaptureSource({required this.file, this.deleteAfterAccept = false});

  final File file;
  final bool deleteAfterAccept;
}

class DeletedFrame {
  const DeletedFrame(this.frame);

  final ProjectFrame frame;
}

enum CaptureGrid { off, thirds, square, crosshair }

enum OnionMode { off, previous, previousTwo, difference }
