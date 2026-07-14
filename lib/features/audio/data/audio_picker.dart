import 'dart:io';

import 'package:file_picker/file_picker.dart';

class PickedAudio {
  const PickedAudio({required this.file, required this.name});

  final File file;
  final String name;
}

abstract interface class AudioPicker {
  Future<PickedAudio?> pick();
}

class PackageAudioPicker implements AudioPicker {
  const PackageAudioPicker();

  @override
  Future<PickedAudio?> pick() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
      withData: false,
    );
    if (result == null) {
      return null;
    }
    final PlatformFile selected = result.files.single;
    if (selected.path == null) {
      throw const FormatException('The selected audio file is not readable.');
    }
    return PickedAudio(file: File(selected.path!), name: selected.name);
  }
}
