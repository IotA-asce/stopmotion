import 'dart:async';
import 'dart:io';

import 'package:record/record.dart';

enum MicrophonePermission { notRequested, granted, denied }

abstract interface class AudioRecordingService {
  Stream<double> get levels;

  Future<MicrophonePermission> permission({required bool request});
  Future<void> start(File destination);
  Future<void> pause();
  Future<void> resume();
  Future<File?> stop();
  Future<void> cancel();
  Future<void> dispose();
}

class PackageAudioRecordingService implements AudioRecordingService {
  PackageAudioRecordingService({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  final StreamController<double> _levels = StreamController<double>.broadcast(
    sync: true,
  );
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  File? _destination;

  @override
  Stream<double> get levels => _levels.stream;

  @override
  Future<MicrophonePermission> permission({required bool request}) async {
    final bool granted = await _recorder.hasPermission(request: request);
    if (granted) {
      return MicrophonePermission.granted;
    }
    return request
        ? MicrophonePermission.denied
        : MicrophonePermission.notRequested;
  }

  @override
  Future<void> start(File destination) async {
    _destination = destination;
    await destination.parent.create(recursive: true);
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
        autoGain: true,
        noiseSuppress: true,
      ),
      path: destination.path,
    );
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((Amplitude amplitude) {
          final double normalized = ((amplitude.current + 60) / 60).clamp(0, 1);
          _levels.add(normalized);
        });
  }

  @override
  Future<void> pause() => _recorder.pause();

  @override
  Future<void> resume() => _recorder.resume();

  @override
  Future<File?> stop() async {
    final String? path = await _recorder.stop();
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    if (path != null) {
      return File(path);
    }
    return _destination;
  }

  @override
  Future<void> cancel() async {
    await _recorder.cancel();
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    _destination = null;
  }

  @override
  Future<void> dispose() async {
    await _amplitudeSubscription?.cancel();
    await _recorder.dispose();
    await _levels.close();
  }
}
