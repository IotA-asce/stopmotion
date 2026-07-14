import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../export/data/export_handoff.dart';
import 'settings_providers.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) => const _InformationPage(
    title: 'Privacy',
    sections: <_InformationSection>[
      _InformationSection(
        heading: 'Your projects stay on this device',
        body:
            'Stop Motion stores frames, audio, and project metadata locally. Nothing is uploaded by the app.',
      ),
      _InformationSection(
        heading: 'Export and sharing are your choice',
        body:
            'A project leaves the device only when you save or share an export using a system destination you select.',
      ),
      _InformationSection(
        heading: 'Diagnostics',
        body:
            'Diagnostic sharing is optional. Archives exclude project titles, frames, audio, source paths, and other user content.',
      ),
    ],
  );
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) => const _InformationPage(
    title: 'Help and troubleshooting',
    sections: <_InformationSection>[
      _InformationSection(
        heading: 'Capture',
        body:
            'Grant camera access when you open Capture. Use the timer, grid, and onion controls from the capture toolbar.',
      ),
      _InformationSection(
        heading: 'Storage',
        body:
            'Open Storage when capture or import reports low space. Clearing cache never removes project source media or exports.',
      ),
      _InformationSection(
        heading: 'Missing media',
        body:
            'Open Recovery after a source file is missing. Repair preserves valid files; remove missing items only removes database entries for unavailable media.',
      ),
      _InformationSection(
        heading: 'Export',
        body:
            'Export preflight identifies missing sources and low storage. Failed or cancelled exports retain project settings so you can try again.',
      ),
    ],
  );
}

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => _InformationPage(
    title: 'About',
    sections: const <_InformationSection>[
      _InformationSection(
        heading: 'Stop Motion',
        body: 'Version 0.1.0 (build 1)',
      ),
      _InformationSection(
        heading: 'Support',
        body:
            'Report support issues at github.com/IotA-asce/stopmotion/issues.',
      ),
    ],
    actions: <Widget>[
      ListTile(
        leading: const Icon(Icons.bug_report_outlined),
        title: const Text('Export diagnostics'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final FileResult result = await _shareDiagnostics(ref);
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(result.message)));
          }
        },
      ),
      ListTile(
        leading: const Icon(Icons.article_outlined),
        title: const Text('Open source licenses'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            showLicensePage(context: context, applicationName: 'Stop Motion'),
      ),
    ],
  );
}

class FileResult {
  const FileResult(this.message);
  final String message;
}

Future<FileResult> _shareDiagnostics(WidgetRef ref) async {
  try {
    final result = await const SystemExportHandoff().share(
      await ref.read(diagnosticExporterProvider).create(),
    );
    return FileResult(switch (result) {
      ExportHandoffResult.complete => 'Diagnostic archive shared.',
      ExportHandoffResult.dismissed => 'Diagnostic archive is ready to share.',
      ExportHandoffResult.denied => 'Sharing was denied.',
      ExportHandoffResult.unavailable =>
        'No compatible sharing destination is available.',
      ExportHandoffResult.failed =>
        'The diagnostic archive could not be shared.',
    });
  } on Object {
    return const FileResult('The diagnostic archive could not be created.');
  }
}

class _InformationPage extends StatelessWidget {
  const _InformationPage({
    required this.title,
    required this.sections,
    this.actions = const <Widget>[],
  });

  final String title;
  final List<_InformationSection> sections;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        for (final _InformationSection section in sections) ...<Widget>[
          Text(section.heading, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(section.body),
          const SizedBox(height: 24),
        ],
        ...actions,
      ],
    ),
  );
}

class _InformationSection {
  const _InformationSection({required this.heading, required this.body});
  final String heading;
  final String body;
}
