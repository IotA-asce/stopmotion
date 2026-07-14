import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  final Directory output = Directory(
    arguments.isEmpty ? 'build/test-fixtures' : arguments.first,
  );
  await output.create(recursive: true);
  final Map<String, Object> manifest = <String, Object>{
    'schemaVersion': 1,
    'projects': 50,
    'editorFixtureFrames': 500,
    'stressFixtureFrames': 1000,
    'media': 'Generated at runtime; no user media is committed.',
  };
  await File('${output.path}/project-fixtures.json').writeAsString(
    const JsonEncoder.withIndent('  ').convert(manifest),
    flush: true,
  );
}
