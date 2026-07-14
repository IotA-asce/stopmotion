import 'package:flutter/material.dart';

import '../../../core/widgets/app_state_views.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            tooltip: 'Search projects',
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            tooltip: 'Project options',
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: AppEmptyView(
        icon: Icons.movie_creation_outlined,
        title: 'Create your first film',
        message: 'Start a project to capture or import your first frames.',
        action: FilledButton.icon(
          // TODO(phase-2): Open the atomic create-project sheet.
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('New project'),
        ),
      ),
    );
  }
}
