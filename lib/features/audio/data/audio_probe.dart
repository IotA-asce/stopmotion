import 'dart:io';

import 'package:just_audio/just_audio.dart';

abstract interface class AudioProbe {
  Future<Duration> duration(File file);
}

class PackageAudioProbe implements AudioProbe {
  const PackageAudioProbe();

  @override
  Future<Duration> duration(File file) async {
    final AudioPlayer player = AudioPlayer();
    try {
      final Duration? duration = await player.setFilePath(file.path);
      if (duration == null || duration <= Duration.zero) {
        throw const FormatException('Audio duration could not be read.');
      }
      return duration;
    } finally {
      await player.dispose();
    }
  }
}
