import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../projects/presentation/project_providers.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  bool _showPermissions = false;
  bool _busy = false;

  Future<void> _finish() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    await ref.read(onboardingRepositoryProvider).markComplete();
    if (mounted) {
      context.go(AppRoutes.projects);
    }
  }

  void _showStorageExplanation() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Your projects stay on this device',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              Text(
                'Frames, edits, and audio remain in application-owned storage '
                'until you explicitly export or share them.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showPermissions
          ? AppBar(
              leading: IconButton(
                onPressed: () => setState(() => _showPermissions = false),
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text('Setup'),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.x6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _showPermissions
                    ? _PermissionPrimer(
                        busy: _busy,
                        onContinue: _finish,
                        onSkip: _finish,
                      )
                    : _Welcome(
                        onContinue: () =>
                            setState(() => _showPermissions = true),
                        onStorage: _showStorageExplanation,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onContinue, required this.onStorage});

  final VoidCallback onContinue;
  final VoidCallback onStorage;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey<String>('welcome'),
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.animation, size: 72),
        const SizedBox(height: AppSpacing.x6),
        Text('Stop Motion', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.x4),
        Text(
          'Make your first film, one frame at a time.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.x3),
        const Text(
          'Your projects stay on this device until you export or share them.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.x6),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onContinue,
            child: const Text('Start creating'),
          ),
        ),
        TextButton(
          onPressed: onStorage,
          child: const Text('How your projects are stored'),
        ),
      ],
    );
  }
}

class _PermissionPrimer extends StatelessWidget {
  const _PermissionPrimer({
    required this.busy,
    required this.onContinue,
    required this.onSkip,
  });

  final bool busy;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey<String>('permissions'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _PermissionExplanation(
          icon: Icons.camera_alt_outlined,
          title: 'Camera access',
          message:
              'Requested when you capture frames. Import remains available '
              'without it.',
        ),
        const SizedBox(height: AppSpacing.x6),
        const _PermissionExplanation(
          icon: Icons.mic_none,
          title: 'Microphone access',
          message: 'Requested later, only when you record narration.',
        ),
        const SizedBox(height: AppSpacing.x6),
        FilledButton(
          onPressed: busy ? null : onContinue,
          child: busy
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Continue'),
        ),
        TextButton(
          onPressed: busy ? null : onSkip,
          child: const Text('Not now'),
        ),
      ],
    );
  }
}

class _PermissionExplanation extends StatelessWidget {
  const _PermissionExplanation({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 40),
        const SizedBox(width: AppSpacing.x4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.x1),
              Text(message),
            ],
          ),
        ),
      ],
    );
  }
}
