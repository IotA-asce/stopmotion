import 'dart:io';

import 'package:file_selector/file_selector.dart';

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
    const XTypeGroup audio = XTypeGroup(
      label: 'audio',
      extensions: <String>['aac', 'flac', 'm4a', 'mp3', 'ogg', 'wav'],
      mimeTypes: <String>['audio/*'],
      uniformTypeIdentifiers: <String>['public.audio'],
    );
    final XFile? selected = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[audio],
    );
    if (selected == null) {
      return null;
    }
    if (selected.path.isEmpty) {
      throw const FormatException('The selected audio file is not readable.');
    }
    return PickedAudio(file: File(selected.path), name: selected.name);
  }
}
