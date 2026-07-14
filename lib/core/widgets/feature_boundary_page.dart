import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

class FeatureBoundaryPage extends StatelessWidget {
  const FeatureBoundaryPage({
    required this.title,
    required this.phase,
    this.projectId,
    super.key,
  });

  final String title;
  final int phase;
  final String? projectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x6),
          child: Text(
            // TODO(release-plan): Replace with the complete scheduled workspace.
            '$title workspace is scheduled for Phase $phase.\n'
            'Project: ${projectId ?? 'not available'}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
