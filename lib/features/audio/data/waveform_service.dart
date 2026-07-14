import 'dart:collection';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';

class WaveformCancellation {
  bool _cancelled = false;

  bool get cancelled => _cancelled;
  void cancel() => _cancelled = true;
}

abstract interface class WaveformExtractor {
  Future<List<double>> extract(File file, int samples);
  Future<void> cancel();
}

class PackageWaveformExtractor implements WaveformExtractor {
  final WaveformExtractionController _controller =
      WaveformExtractionController();

  @override
  Future<List<double>> extract(File file, int samples) =>
      _controller.extractWaveformData(path: file.path, noOfSamples: samples);

  @override
  Future<void> cancel() => _controller.stopWaveformExtraction();
}

class WaveformService {
  WaveformService({
    required WaveformExtractor extractor,
    int maximumSamples = 12000,
  }) : this._(extractor, maximumSamples);

  WaveformService._(this._extractor, this.maximumSamples);

  final WaveformExtractor _extractor;
  final int maximumSamples;
  final LinkedHashMap<String, List<double>> _cache =
      LinkedHashMap<String, List<double>>();
  int _samplesUsed = 0;

  int get samplesUsed => _samplesUsed;

  Future<List<double>> read({
    required File file,
    required int samples,
    WaveformCancellation? cancellation,
  }) async {
    if (samples < 1 || samples > 2000) {
      throw ArgumentError.value(samples, 'samples');
    }
    final FileStat stat = await file.stat();
    final String key =
        '${file.path}|${stat.size}|${stat.modified.microsecondsSinceEpoch}|$samples';
    final List<double>? cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached;
      return List<double>.unmodifiable(cached);
    }
    if (cancellation?.cancelled ?? false) {
      throw const WaveformCancelled();
    }
    final List<double> waveform = await _extractor.extract(file, samples);
    if (cancellation?.cancelled ?? false) {
      await _extractor.cancel();
      throw const WaveformCancelled();
    }
    final List<double> bounded = waveform
        .take(samples)
        .map((double value) => value.abs().clamp(0, 1).toDouble())
        .toList(growable: false);
    _cache[key] = bounded;
    _samplesUsed += bounded.length;
    while (_samplesUsed > maximumSamples && _cache.length > 1) {
      _samplesUsed -= _cache.remove(_cache.keys.first)!.length;
    }
    return List<double>.unmodifiable(bounded);
  }

  Future<void> cancel() => _extractor.cancel();

  void clear() {
    _cache.clear();
    _samplesUsed = 0;
  }
}

class WaveformCancelled implements Exception {
  const WaveformCancelled();
}
