import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../domain/project.dart';
import 'project_providers.dart';

class CreateProjectPage extends ConsumerStatefulWidget {
  const CreateProjectPage({this.onCreated, super.key});

  final ValueChanged<Project>? onCreated;

  @override
  ConsumerState<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends ConsumerState<CreateProjectPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _customFpsController = TextEditingController(
    text: '12',
  );
  ProjectAspectRatio _aspectRatio = ProjectAspectRatio.widescreen;
  ProjectResolution _resolution = ProjectResolution.fullHd1080;
  int _framesPerSecond = 12;
  bool _customFramesPerSecond = false;
  int _backgroundColor = 0xFF000000;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultTitle();
  }

  Future<void> _loadDefaultTitle() async {
    final String title = await ref
        .read(projectRepositoryProvider)
        .nextUntitledName();
    if (mounted && _titleController.text.isEmpty) {
      _titleController.text = title;
      _titleController.selection = TextSelection.collapsed(
        offset: title.length,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _customFpsController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_busy || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _busy = true);
    try {
      final Project project = await ref
          .read(projectActionsProvider)
          .create(
            ProjectDraft(
              title: _titleController.text,
              aspectRatio: _aspectRatio,
              resolution: _resolution,
              framesPerSecond: _framesPerSecond,
              backgroundColorValue: _backgroundColor,
            ),
          );
      if (mounted) {
        if (widget.onCreated case final ValueChanged<Project> onCreated) {
          onCreated(project);
        } else {
          context.go(AppRoutes.capture(project.id));
        }
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create project: $error')),
        );
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _busy ? null : () => context.pop(),
          tooltip: 'Cancel',
          icon: const Icon(Icons.close),
        ),
        title: const Text('New project'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.x4),
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                autofocus: true,
                maxLength: 120,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) =>
                    value == null || value.trim().isEmpty
                    ? 'Enter a project title.'
                    : null,
              ),
              const SizedBox(height: AppSpacing.x4),
              const _FieldLabel('Aspect ratio'),
              SegmentedButton<ProjectAspectRatio>(
                segments: ProjectAspectRatio.values
                    .map(
                      (ProjectAspectRatio value) =>
                          ButtonSegment<ProjectAspectRatio>(
                            value: value,
                            label: Text(value.label),
                          ),
                    )
                    .toList(growable: false),
                selected: <ProjectAspectRatio>{_aspectRatio},
                onSelectionChanged: (Set<ProjectAspectRatio> values) {
                  setState(() => _aspectRatio = values.single);
                },
              ),
              const SizedBox(height: AppSpacing.x6),
              const _FieldLabel('Frame rate'),
              DropdownButtonFormField<int>(
                initialValue: _customFramesPerSecond ? -1 : _framesPerSecond,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const <int>[6, 8, 10, 12, 15, 24, -1]
                    .map(
                      (int value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text(value == -1 ? 'Custom' : '$value fps'),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      _customFramesPerSecond = value == -1;
                      if (value != -1) {
                        _framesPerSecond = value;
                      }
                    });
                  }
                },
              ),
              if (_customFramesPerSecond) ...<Widget>[
                const SizedBox(height: AppSpacing.x3),
                TextFormField(
                  controller: _customFpsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Custom frame rate',
                    suffixText: 'fps',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (!_customFramesPerSecond) {
                      return null;
                    }
                    final int? fps = int.tryParse(value ?? '');
                    return fps == null || fps < 1 || fps > 30
                        ? 'Enter a value from 1 to 30.'
                        : null;
                  },
                  onChanged: (String value) {
                    final int? fps = int.tryParse(value);
                    if (fps != null) {
                      _framesPerSecond = fps;
                    }
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.x6),
              const _FieldLabel('Resolution'),
              SegmentedButton<ProjectResolution>(
                segments: ProjectResolution.values
                    .map(
                      (ProjectResolution value) =>
                          ButtonSegment<ProjectResolution>(
                            value: value,
                            label: Text(value.label),
                          ),
                    )
                    .toList(growable: false),
                selected: <ProjectResolution>{_resolution},
                onSelectionChanged: (Set<ProjectResolution> values) {
                  setState(() => _resolution = values.single);
                },
              ),
              const SizedBox(height: AppSpacing.x6),
              const _FieldLabel('Background'),
              Wrap(
                spacing: AppSpacing.x3,
                children: <int>[0xFF000000, 0xFFFFFFFF, 0xFF087E6B]
                    .map(
                      (int color) => _ColorChoice(
                        color: Color(color),
                        selected: color == _backgroundColor,
                        onTap: () => setState(() => _backgroundColor = color),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: AppSpacing.x6),
              FilledButton(
                onPressed: _busy ? null : _create,
                child: _busy
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x2),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Background ${color.toARGB32().toRadixString(16)}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Container(
          width: AppSpacing.touchTarget,
          height: AppSpacing.touchTarget,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
              width: selected ? 3 : 1,
            ),
          ),
          child: selected
              ? Icon(
                  Icons.check,
                  color: color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}
