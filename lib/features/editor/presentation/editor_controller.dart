import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../preview/domain/playback_clock.dart';
import '../../projects/data/project_repository.dart';
import '../../projects/domain/project.dart';
import '../data/editor_repository.dart';
import '../domain/frame.dart';
import '../domain/frame_adjustments.dart';
import '../domain/timeline.dart';
import '../domain/timeline_command.dart';

enum AutosaveStatus { idle, saving, saved, failed }

class EditorViewState {
  const EditorViewState({
    this.project,
    this.timeline,
    this.selection,
    this.playheadIndex = 0,
    this.playing = false,
    this.loop = false,
    this.zoom = 1,
    this.autosave = AutosaveStatus.idle,
    this.committedRevision,
    this.errorMessage,
  });

  final Project? project;
  final TimelineSnapshot? timeline;
  final TimelineSelection? selection;
  final int playheadIndex;
  final bool playing;
  final bool loop;
  final double zoom;
  final AutosaveStatus autosave;
  final int? committedRevision;
  final String? errorMessage;

  List<ProjectFrame> get selectedFrames {
    final TimelineSnapshot? current = timeline;
    final TimelineSelection? selected = selection;
    if (current == null || selected == null) {
      return const <ProjectFrame>[];
    }
    return current.frames
        .where((ProjectFrame frame) => selected.contains(frame.id))
        .toList(growable: false);
  }

  EditorViewState copyWith({
    Project? project,
    TimelineSnapshot? timeline,
    TimelineSelection? selection,
    int? playheadIndex,
    bool? playing,
    bool? loop,
    double? zoom,
    AutosaveStatus? autosave,
    int? committedRevision,
    String? errorMessage,
    bool clearError = false,
  }) => EditorViewState(
    project: project ?? this.project,
    timeline: timeline ?? this.timeline,
    selection: selection ?? this.selection,
    playheadIndex: playheadIndex ?? this.playheadIndex,
    playing: playing ?? this.playing,
    loop: loop ?? this.loop,
    zoom: zoom ?? this.zoom,
    autosave: autosave ?? this.autosave,
    committedRevision: committedRevision ?? this.committedRevision,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

class EditorController extends ChangeNotifier {
  EditorController({
    required String projectId,
    required EditorRepository repository,
    required ProjectRepository projects,
    PlaybackClock? clock,
  }) : this._(projectId, repository, projects, clock ?? PlaybackClock());

  EditorController._(
    this.projectId,
    this._repository,
    this._projects,
    this._clock,
  );

  final String projectId;
  final EditorRepository _repository;
  final ProjectRepository _projects;
  final PlaybackClock _clock;
  final List<_HistoryEntry> _undo = <_HistoryEntry>[];
  final List<_HistoryEntry> _redo = <_HistoryEntry>[];
  List<ProjectFrame> _clipboard = const <ProjectFrame>[];
  Timer? _ticker;
  bool _disposed = false;
  EditorViewState _state = const EditorViewState();

  EditorViewState get state => _state;
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;
  bool get canPaste => _clipboard.isNotEmpty;

  Future<void> initialize() async {
    try {
      final (Project?, TimelineSnapshot) loaded = await (
        _projects.getProject(projectId),
        _repository.loadTimeline(projectId),
      ).wait;
      final Project? project = loaded.$1;
      if (project == null) {
        throw StateError('Project no longer exists.');
      }
      _update(
        _state.copyWith(
          project: project,
          timeline: loaded.$2,
          selection: loaded.$2.frames.isEmpty
              ? TimelineSelection.empty()
              : TimelineSelection.empty().single(loaded.$2.frames.first.id),
          committedRevision: project.currentRevision,
          autosave: AutosaveStatus.saved,
          clearError: true,
        ),
      );
    } on Object catch (error) {
      _update(_state.copyWith(errorMessage: 'Editor could not open: $error'));
    }
  }

  void select(String id, {bool toggle = false, bool range = false}) {
    final TimelineSnapshot? timeline = _state.timeline;
    if (timeline == null) {
      return;
    }
    final TimelineSelection current =
        _state.selection ?? TimelineSelection.empty();
    final TimelineSelection selection = range
        ? current.range(timeline.frames, id)
        : toggle
        ? current.toggle(id)
        : current.single(id);
    final int index = timeline.frames.indexWhere(
      (ProjectFrame frame) => frame.id == id,
    );
    _clock.seek(timeline.elapsedAtFrame(index));
    _update(
      _state.copyWith(
        selection: selection,
        playheadIndex: index.clamp(0, timeline.frames.length - 1),
      ),
    );
  }

  void selectAll() {
    final TimelineSnapshot? timeline = _state.timeline;
    if (timeline != null) {
      _update(
        _state.copyWith(
          selection: TimelineSelection.empty().all(timeline.frames),
        ),
      );
    }
  }

  Future<void> duplicateSelection() =>
      _apply(DuplicateFramesCommand(_state.selection?.ids ?? const <String>{}));

  Future<void> deleteSelection() =>
      _apply(DeleteFramesCommand(_state.selection?.ids ?? const <String>{}));

  Future<void> reverseSelection() =>
      _apply(ReverseFramesCommand(_state.selection?.ids ?? const <String>{}));

  void copySelection() {
    _clipboard = _state.selectedFrames;
    notifyListeners();
  }

  Future<void> paste() =>
      _apply(PasteFramesCommand(_clipboard, _state.playheadIndex + 1));

  Future<void> setHold(int holdFrames) => _apply(
    SetFrameHoldCommand(_state.selection?.ids ?? const <String>{}, holdFrames),
  );

  Future<void> setFps(int fps) => _apply(SetFramesPerSecondCommand(fps));

  Future<void> applyAdjustments({
    required String frameId,
    required FrameAdjustments adjustments,
    required AdjustmentScope scope,
  }) => _apply(
    UpdateFrameAdjustmentsCommand(
      targetFrameId: frameId,
      selectionIds: _state.selection?.ids ?? <String>{frameId},
      adjustments: adjustments,
      scope: scope,
    ),
  );

  Future<void> reorder(int oldIndex, int newIndex) async {
    final TimelineSnapshot? timeline = _state.timeline;
    if (timeline == null ||
        oldIndex < 0 ||
        oldIndex >= timeline.frames.length) {
      return;
    }
    final String dragged = timeline.frames[oldIndex].id;
    final Set<String> ids = _state.selection?.contains(dragged) == true
        ? _state.selection!.ids
        : <String>{dragged};
    await _apply(ReorderFramesCommand(ids, newIndex));
  }

  Future<void> undo() async {
    if (_undo.isEmpty) {
      return;
    }
    final _HistoryEntry entry = _undo.removeLast();
    if (await _persist(entry.before)) {
      _redo.add(entry);
    } else {
      _undo.add(entry);
    }
  }

  Future<void> redo() async {
    if (_redo.isEmpty) {
      return;
    }
    final _HistoryEntry entry = _redo.removeLast();
    if (await _persist(entry.after)) {
      _undo.add(entry);
    } else {
      _redo.add(entry);
    }
  }

  void togglePlayback() {
    final TimelineSnapshot? timeline = _state.timeline;
    if (timeline == null || timeline.isEmpty) {
      return;
    }
    if (_state.playing) {
      _clock.pause(timeline.duration);
      _ticker?.cancel();
      _update(_state.copyWith(playing: false));
      return;
    }
    if (_clock.position(timeline.duration) >= timeline.duration) {
      _clock.seek(Duration.zero);
    }
    _clock.play();
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
    _update(_state.copyWith(playing: true));
  }

  void toggleLoop() {
    _clock.loop = !_state.loop;
    _update(_state.copyWith(loop: _clock.loop));
  }

  void jumpTo(int index) {
    final TimelineSnapshot? timeline = _state.timeline;
    if (timeline == null || timeline.isEmpty) {
      return;
    }
    final int bounded = index.clamp(0, timeline.frames.length - 1);
    _clock.seek(timeline.elapsedAtFrame(bounded));
    _update(_state.copyWith(playheadIndex: bounded));
  }

  void seekFraction(double fraction) {
    final TimelineSnapshot? timeline = _state.timeline;
    if (timeline == null) {
      return;
    }
    _clock.seek(
      Duration(
        microseconds: (timeline.duration.inMicroseconds * fraction.clamp(0, 1))
            .round(),
      ),
    );
    _tick();
  }

  void setZoom(double zoom) =>
      _update(_state.copyWith(zoom: zoom.clamp(0.75, 2.5)));

  Future<void> rename(String title) async {
    await _projects.renameProject(projectId, title);
    final Project? project = await _projects.getProject(projectId);
    if (project != null) {
      _update(_state.copyWith(project: project));
    }
  }

  Future<void> _apply(TimelineCommand command) async {
    final TimelineSnapshot? before = _state.timeline;
    if (before == null || _state.autosave == AutosaveStatus.saving) {
      return;
    }
    try {
      final TimelineSnapshot after = command.apply(before);
      if (await _persist(after)) {
        _undo.add(_HistoryEntry(before, after));
        _redo.clear();
      }
    } on Object catch (error) {
      _update(
        _state.copyWith(
          autosave: AutosaveStatus.failed,
          errorMessage: 'Edit was not saved: $error',
        ),
      );
    }
  }

  Future<bool> _persist(TimelineSnapshot timeline) async {
    _update(_state.copyWith(autosave: AutosaveStatus.saving, clearError: true));
    try {
      final EditorCommitResult result = await _repository.saveTimeline(
        projectId,
        timeline,
      );
      final int playhead = result.timeline.frames.isEmpty
          ? 0
          : _state.playheadIndex.clamp(0, result.timeline.frames.length - 1);
      _update(
        _state.copyWith(
          timeline: result.timeline,
          selection: (_state.selection ?? TimelineSelection.empty()).retain(
            result.timeline.frames,
          ),
          playheadIndex: playhead,
          committedRevision: result.revision,
          autosave: AutosaveStatus.saved,
        ),
      );
      return true;
    } on Object catch (error) {
      _update(
        _state.copyWith(
          autosave: AutosaveStatus.failed,
          errorMessage: 'Edit was not saved: $error',
        ),
      );
      return false;
    }
  }

  void _tick() {
    final TimelineSnapshot? timeline = _state.timeline;
    if (timeline == null || timeline.isEmpty) {
      return;
    }
    final Duration position = _clock.position(timeline.duration);
    final bool ended = !_state.loop && position >= timeline.duration;
    if (ended) {
      _ticker?.cancel();
      _clock.pause(timeline.duration);
    }
    _update(
      _state.copyWith(
        playheadIndex: timeline.frameIndexAt(position),
        playing: ended ? false : _state.playing,
      ),
    );
  }

  void _update(EditorViewState state) {
    if (_disposed) {
      return;
    }
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    super.dispose();
  }
}

class _HistoryEntry {
  const _HistoryEntry(this.before, this.after);

  final TimelineSnapshot before;
  final TimelineSnapshot after;
}
