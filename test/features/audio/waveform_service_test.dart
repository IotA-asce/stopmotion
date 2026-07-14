import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stop_motion/features/audio/data/waveform_service.dart';

void main() {
  late Directory root;
  late File source;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('waveform_test_');
    source = await File('${root.path}/audio.m4a').writeAsBytes(<int>[1, 2, 3]);
  });

  tearDown(() => root.delete(recursive: true));

  test('bounds samples, caches results, and evicts old entries', () async {
    final _FakeExtractor extractor = _FakeExtractor();
    final WaveformService service = WaveformService(
      extractor: extractor,
      maximumSamples: 5,
    );

    final List<double> first = await service.read(file: source, samples: 4);
    final List<double> cached = await service.read(file: source, samples: 4);
    final File second = await File(
      '${root.path}/second.m4a',
    ).writeAsBytes(<int>[4, 5]);
    await service.read(file: second, samples: 4);

    expect(first, <double>[1, 0.5, 0, 1]);
    expect(cached, first);
    expect(extractor.calls, 2);
    expect(service.samplesUsed, lessThanOrEqualTo(5));
  });

  test('cancellation prevents extraction and reports a typed result', () async {
    final WaveformService service = WaveformService(
      extractor: _FakeExtractor(),
    );
    final WaveformCancellation cancellation = WaveformCancellation()..cancel();

    expect(
      service.read(file: source, samples: 4, cancellation: cancellation),
      throwsA(isA<WaveformCancelled>()),
    );
  });
}

class _FakeExtractor implements WaveformExtractor {
  int calls = 0;

  @override
  Future<void> cancel() async {}

  @override
  Future<List<double>> extract(File file, int samples) async {
    calls++;
    return <double>[-2, -0.5, 0, 2];
  }
}
