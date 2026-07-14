import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/widgets/app_state_views.dart';

class RecoveryPage extends StatelessWidget {
  const RecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recovery')),
      body: AppEmptyView(
        icon: Icons.check_circle_outline,
        title: 'No recovery needed',
        message: 'Your projects are consistent and ready to open.',
        action: FilledButton(
          onPressed: () => context.go(AppRoutes.projects),
          child: const Text('Continue to Projects'),
        ),
      ),
    );
  }
}
