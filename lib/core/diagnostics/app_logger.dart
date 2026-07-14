import 'dart:convert';
import 'dart:io';

import '../filesystem/project_paths.dart';

class DiagnosticLogEntry {
  const DiagnosticLogEntry({
    required this.timestamp,
    required this.category,
    required this.action,
    required this.attributes,
    this.operationId,
  });

  final DateTime timestamp;
  final String category;
  final String action;
  final String? operationId;
  final Map<String, Object?> attributes;

  Map<String, Object?> toJson() => <String, Object?>{
    'timestamp': timestamp.toIso8601String(),
    'category': category,
    'action': action,
    if (operationId != null) 'operationId': operationId,
    'attributes': attributes,
  };
}

class DiagnosticRedactor {
  const DiagnosticRedactor();

  static const Set<String> _allowedKeys = <String>{
    'attempt',
    'availableBytes',
    'capability',
    'count',
    'durationMs',
    'errorType',
    'format',
    'reason',
    'schemaVersion',
    'stage',
    'status',
  };

  Map<String, Object?> redact(Map<String, Object?> attributes) {
    return <String, Object?>{
      for (final MapEntry<String, Object?> entry in attributes.entries)
        entry.key: _allowedKeys.contains(entry.key)
            ? _safeValue(entry.value)
            : '<redacted>',
    };
  }

  Object? _safeValue(Object? value) {
    if (value is num || value is bool || value == null) return value;
    if (value is String) {
      if (value.contains('/') || value.contains('\\') || value.contains(':')) {
        return '<redacted>';
      }
      return value.length > 80 ? value.substring(0, 80) : value;
    }
    return '<redacted>';
  }
}

class AppLogger {
  factory AppLogger({
    required ProjectPaths paths,
    DiagnosticRedactor redactor = const DiagnosticRedactor(),
    DateTime Function()? now,
    int maxEntries = 200,
    int maxBytes = 128 * 1024,
  }) => AppLogger._(paths, redactor, now ?? _utcNow, maxEntries, maxBytes);

  AppLogger._(
    this._paths,
    this._redactor,
    this._now,
    this.maxEntries,
    this.maxBytes,
  );

  final ProjectPaths _paths;
  final DiagnosticRedactor _redactor;
  final DateTime Function() _now;
  final int maxEntries;
  final int maxBytes;

  static DateTime _utcNow() => DateTime.now().toUtc();

  File get _file => File('${_paths.diagnosticsDirectory.path}/events.jsonl');

  Future<void> log({
    required String category,
    required String action,
    String? operationId,
    Map<String, Object?> attributes = const <String, Object?>{},
  }) async {
    final DiagnosticLogEntry entry = DiagnosticLogEntry(
      timestamp: _now(),
      category: category,
      action: action,
      operationId: operationId,
      attributes: _redactor.redact(attributes),
    );
    final List<String> lines = await _lines();
    lines.add(jsonEncode(entry.toJson()));
    while (lines.length > maxEntries || _encodedLength(lines) > maxBytes) {
      lines.removeAt(0);
    }
    await _file.parent.create(recursive: true);
    await _file.writeAsString('${lines.join('\n')}\n', flush: true);
  }

  Future<List<Map<String, Object?>>> read() async {
    final List<Map<String, Object?>> entries = <Map<String, Object?>>[];
    for (final String line in await _lines()) {
      try {
        final Object? parsed = jsonDecode(line);
        if (parsed is Map<Object?, Object?>) {
          entries.add(parsed.cast<String, Object?>());
        }
      } on FormatException {
        // A torn diagnostics line is not useful and is ignored.
      }
    }
    return entries;
  }

  Future<List<String>> _lines() async {
    if (!await _file.exists()) return <String>[];
    return (await _file.readAsLines())
        .where((String line) => line.isNotEmpty)
        .toList();
  }

  int _encodedLength(List<String> lines) =>
      utf8.encode(lines.join('\n')).length;
}
