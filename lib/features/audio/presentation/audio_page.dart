import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/media/audio_service.dart';
import '../domain/audio_clip.dart';
import '../domain/audio_timeline.dart';
import 'audio_controller.dart';
import 'audio_providers.dart';
import 'audio_waveform.dart';

class AudioPage extends ConsumerStatefulWidget {
  const AudioPage({required this.projectId, super.key});

  final String projectId;

  @override
  ConsumerState<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends ConsumerState<AudioPage>
    with WidgetsBindingObserver {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      final AudioController controller = ref.read(
        audioControllerProvider(widget.projectId),
      );
      controller.handleLifecycle(active: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AudioController controller = ref.watch(
      audioControllerProvider(widget.projectId),
    );
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) {
        final AudioViewState state = controller.state;
        final AudioTimeline? timeline = state.timeline;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Back to editor',
              onPressed: context.pop,
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text('Audio'),
            actions: <Widget>[
              TextButton(onPressed: context.pop, child: const Text('Done')),
            ],
          ),
          body: timeline == null
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final Widget workspace = _workspace(
                      context,
                      controller,
                      state,
                      timeline,
                    );
                    final Widget controls = _controls(
                      context,
                      controller,
                      state,
                      timeline,
                    );
                    if (constraints.maxWidth >= 900) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(flex: 3, child: workspace),
                          const VerticalDivider(width: 1),
                          SizedBox(width: 340, child: controls),
                        ],
                      );
                    }
                    return ListView(
                      children: <Widget>[
                        SizedBox(height: 440, child: workspace),
                        const Divider(height: 1),
                        controls,
                      ],
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _workspace(
    BuildContext context,
    AudioController controller,
    AudioViewState state,
    AudioTimeline timeline,
  ) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ColoredBox(
            color: Colors.black,
            child: const Center(
              child: Icon(
                Icons.movie_outlined,
                color: Colors.white70,
                size: 58,
              ),
            ),
          ),
        ),
        _transport(controller, state, timeline),
        SizedBox(
          height: 190,
          child: _AudioTracks(
            timeline: timeline,
            waveforms: state.waveforms,
            selectedId: _selectedId,
            playheadMilliseconds: state.playheadMilliseconds,
            onSelected: (String id) => setState(() => _selectedId = id),
          ),
        ),
      ],
    );
  }

  Widget _transport(
    AudioController controller,
    AudioViewState state,
    AudioTimeline timeline,
  ) {
    final int maximum = timeline.projectDurationMilliseconds.clamp(1, 1 << 31);
    return SizedBox(
      height: 58,
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Jump to start',
            onPressed: () => controller.seek(0),
            icon: const Icon(Icons.first_page),
          ),
          IconButton(
            tooltip: state.playing ? 'Pause' : 'Play',
            onPressed: controller.togglePlayback,
            icon: Icon(state.playing ? Icons.pause : Icons.play_arrow),
          ),
          IconButton(
            tooltip: state.loop ? 'Disable loop' : 'Enable loop',
            onPressed: controller.toggleLoop,
            isSelected: state.loop,
            icon: const Icon(Icons.repeat),
          ),
          Expanded(
            child: Slider(
              value: state.playheadMilliseconds.clamp(0, maximum).toDouble(),
              max: maximum.toDouble(),
              semanticFormatterCallback: _formatMilliseconds,
              onChanged: (double value) => controller.seek(value.round()),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(_formatMilliseconds(state.playheadMilliseconds)),
          ),
        ],
      ),
    );
  }

  Widget _controls(
    BuildContext context,
    AudioController controller,
    AudioViewState state,
    AudioTimeline timeline,
  ) {
    final AudioClip? selected = _selectedId == null
        ? null
        : timeline.clips.cast<AudioClip?>().firstWhere(
            (AudioClip? clip) => clip?.id == _selectedId,
            orElse: () => null,
          );
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        if (state.errorMessage != null)
          MaterialBanner(
            content: Text(state.errorMessage!),
            actions: <Widget>[
              TextButton(
                onPressed: controller.clearError,
                child: const Text('Dismiss'),
              ),
            ],
          ),
        if (state.permission == MicrophonePermission.denied)
          const ListTile(
            leading: Icon(Icons.mic_off_outlined),
            title: Text('Microphone access denied'),
            subtitle: Text('Imported audio is still available.'),
          ),
        _recordingControls(controller, state),
        ListTile(
          leading: const Icon(Icons.audio_file_outlined),
          title: const Text('Import audio'),
          subtitle: const Text('Music or sound effect'),
          enabled: !state.busy && state.recording == NarrationState.idle,
          onTap: () => controller.importAudio(),
        ),
        const Divider(),
        SwitchListTile(
          secondary: const Icon(Icons.volume_off_outlined),
          title: const Text('Mute project audio'),
          value: timeline.muted,
          onChanged: (_) => controller.toggleMasterMute(),
        ),
        Text('Master volume ${(timeline.masterVolume * 100).round()}%'),
        Slider(
          value: timeline.masterVolume,
          max: 2,
          divisions: 40,
          semanticFormatterCallback: (double value) =>
              '${(value * 100).round()} percent',
          onChangeEnd: controller.setMasterVolume,
          onChanged: controller.previewMasterVolume,
        ),
        const Divider(),
        if (selected == null)
          const ListTile(
            leading: Icon(Icons.touch_app_outlined),
            title: Text('Select an audio clip'),
          )
        else ...<Widget>[
          ListTile(
            title: Text(selected.name),
            subtitle: Text(
              selected.missing
                  ? 'Source missing - muted'
                  : selected.trackType.name,
            ),
            trailing: IconButton(
              tooltip: selected.muted ? 'Unmute clip' : 'Mute clip',
              onPressed: () => controller.updateClip(
                selected.copyWith(muted: !selected.muted),
              ),
              icon: Icon(selected.muted ? Icons.volume_off : Icons.volume_up),
            ),
          ),
          Wrap(
            spacing: 8,
            children: <Widget>[
              TextButton.icon(
                onPressed: () => _editClip(context, controller, selected),
                icon: const Icon(Icons.tune),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: () => controller.splitClip(selected.id),
                icon: const Icon(Icons.content_cut),
                label: const Text('Split'),
              ),
              TextButton.icon(
                onPressed: () => controller.duplicateClip(selected.id),
                icon: const Icon(Icons.copy),
                label: const Text('Duplicate'),
              ),
              TextButton.icon(
                onPressed: () async {
                  await controller.deleteClip(selected.id);
                  setState(() => _selectedId = null);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _recordingControls(AudioController controller, AudioViewState state) {
    return switch (state.recording) {
      NarrationState.idle => ListTile(
        leading: const Icon(Icons.mic_outlined),
        title: const Text('Record narration'),
        subtitle: const Text('Starts after a three-second count-in'),
        enabled: !state.busy,
        onTap: controller.startNarration,
      ),
      NarrationState.countIn => ListTile(
        leading: CircleAvatar(child: Text('${state.countIn}')),
        title: const Text('Get ready'),
        trailing: TextButton(
          onPressed: controller.cancelCountIn,
          child: const Text('Cancel'),
        ),
      ),
      NarrationState.recording || NarrationState.paused => Column(
        children: <Widget>[
          LinearProgressIndicator(value: state.level),
          ListTile(
            leading: IconButton(
              tooltip: state.recording == NarrationState.paused
                  ? 'Resume recording'
                  : 'Pause recording',
              onPressed: state.recording == NarrationState.paused
                  ? controller.resumeRecording
                  : controller.pauseRecording,
              icon: Icon(
                state.recording == NarrationState.paused
                    ? Icons.mic
                    : Icons.pause,
              ),
            ),
            title: Text(_formatMilliseconds(state.elapsed.inMilliseconds)),
            trailing: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: controller.stopRecording,
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
            ),
          ),
        ],
      ),
    };
  }

  Future<void> _editClip(
    BuildContext context,
    AudioController controller,
    AudioClip clip,
  ) async {
    final TextEditingController name = TextEditingController(text: clip.name);
    final TextEditingController position = TextEditingController(
      text: clip.startMilliseconds.toString(),
    );
    final TextEditingController trimStart = TextEditingController(
      text: clip.trimStartMilliseconds.toString(),
    );
    final TextEditingController trimEnd = TextEditingController(
      text: clip.trimEndMilliseconds.toString(),
    );
    final TextEditingController volume = TextEditingController(
      text: (clip.volume * 100).round().toString(),
    );
    final TextEditingController fadeIn = TextEditingController(
      text: clip.fadeInMilliseconds.toString(),
    );
    final TextEditingController fadeOut = TextEditingController(
      text: clip.fadeOutMilliseconds.toString(),
    );
    final AudioClip? result = await showModalBottomSheet<AudioClip>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          children: <Widget>[
            Text(
              'Edit audio clip',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            _numberField(name, 'Name', numeric: false),
            _numberField(position, 'Position (ms)'),
            _numberField(trimStart, 'Trim start (ms)'),
            _numberField(trimEnd, 'Trim end (ms)'),
            _numberField(volume, 'Volume (0-200%)'),
            _numberField(fadeIn, 'Fade in (ms)'),
            _numberField(fadeOut, 'Fade out (ms)'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                try {
                  Navigator.pop(
                    context,
                    clip.copyWith(
                      name: name.text,
                      startMilliseconds: int.parse(position.text),
                      trimStartMilliseconds: int.parse(trimStart.text),
                      trimEndMilliseconds: int.parse(trimEnd.text),
                      volume: int.parse(volume.text) / 100,
                      fadeInMilliseconds: int.parse(fadeIn.text),
                      fadeOutMilliseconds: int.parse(fadeOut.text),
                    ),
                  );
                } on FormatException catch (error) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error.message)));
                }
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
    for (final TextEditingController value in <TextEditingController>[
      name,
      position,
      trimStart,
      trimEnd,
      volume,
      fadeIn,
      fadeOut,
    ]) {
      value.dispose();
    }
    if (result != null) {
      await controller.updateClip(result);
    }
  }

  Widget _numberField(
    TextEditingController controller,
    String label, {
    bool numeric = true,
  }) => TextField(
    controller: controller,
    keyboardType: numeric ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(labelText: label),
  );

  String _formatMilliseconds(num milliseconds) {
    final Duration duration = Duration(milliseconds: milliseconds.round());
    final String minutes = duration.inMinutes.toString().padLeft(2, '0');
    final String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class _AudioTracks extends StatelessWidget {
  const _AudioTracks({
    required this.timeline,
    required this.waveforms,
    required this.selectedId,
    required this.playheadMilliseconds,
    required this.onSelected,
  });

  final AudioTimeline timeline;
  final Map<String, List<double>> waveforms;
  final String? selectedId;
  final int playheadMilliseconds;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final int contentDuration = timeline.clips.fold<int>(
      timeline.projectDurationMilliseconds,
      (int value, AudioClip clip) =>
          value > clip.endMilliseconds ? value : clip.endMilliseconds,
    );
    final int maximum = contentDuration.clamp(1, 1 << 31);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double trackWidth = (constraints.maxWidth - 68).clamp(
          1,
          double.infinity,
        );
        return Stack(
          children: <Widget>[
            Column(
              children: AudioTrackType.values
                  .map((AudioTrackType type) {
                    final List<AudioClip> clips = timeline.clips
                        .where((AudioClip clip) => clip.trackType == type)
                        .toList(growable: false);
                    return SizedBox(
                      height: 58,
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 68, child: Text(type.name)),
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: clips
                                  .map((AudioClip clip) {
                                    final double left =
                                        trackWidth *
                                        clip.startMilliseconds /
                                        maximum;
                                    final double remaining = trackWidth - left;
                                    final double requested =
                                        trackWidth *
                                        clip.durationMilliseconds /
                                        maximum;
                                    final double width = requested
                                        .clamp(1, remaining < 1 ? 1 : remaining)
                                        .toDouble();
                                    return Positioned(
                                      left: left,
                                      top: 6,
                                      width: width,
                                      height: 46,
                                      child: Semantics(
                                        button: true,
                                        selected: selectedId == clip.id,
                                        label: '${clip.name}, ${type.name}',
                                        child: InkWell(
                                          onTap: () => onSelected(clip.id),
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: selectedId == clip.id
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .secondaryContainer
                                                  : Theme.of(context)
                                                        .colorScheme
                                                        .surfaceContainerHighest,
                                              border: Border.all(
                                                color: clip.missing
                                                    ? Theme.of(
                                                        context,
                                                      ).colorScheme.error
                                                    : Theme.of(
                                                        context,
                                                      ).dividerColor,
                                              ),
                                            ),
                                            child: AudioWaveform(
                                              samples:
                                                  waveforms[clip.id] ??
                                                  const <double>[],
                                              color: clip.muted
                                                  ? Theme.of(
                                                      context,
                                                    ).disabledColor
                                                  : Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(growable: false),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
            Positioned(
              left: 68 + trackWidth * playheadMilliseconds / maximum,
              top: 0,
              bottom: 16,
              child: Container(
                width: 2,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        );
      },
    );
  }
}
