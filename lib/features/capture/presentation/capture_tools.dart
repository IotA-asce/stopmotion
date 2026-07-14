import 'package:flutter/material.dart';

import '../../../core/media/camera_capabilities.dart';
import '../domain/capture_frame.dart';
import 'capture_controller.dart';

class CaptureTools extends StatelessWidget {
  const CaptureTools({
    required this.controller,
    required this.state,
    required this.vertical,
    required this.onInterval,
    super.key,
  });

  final CaptureController controller;
  final CaptureViewState state;
  final bool vertical;
  final VoidCallback onInterval;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tools = <Widget>[
      PopupMenuButton<OnionMode>(
        tooltip: 'Onion skin',
        initialValue: state.onionMode,
        onSelected: controller.setOnionMode,
        icon: Icon(
          Icons.layers_outlined,
          color: state.onionMode == OnionMode.off ? null : Colors.tealAccent,
        ),
        itemBuilder: (BuildContext context) => OnionMode.values
            .map(
              (OnionMode mode) => PopupMenuItem<OnionMode>(
                value: mode,
                child: Text(_onionLabel(mode)),
              ),
            )
            .toList(growable: false),
      ),
      PopupMenuButton<CaptureGrid>(
        tooltip: 'Composition grid',
        initialValue: state.grid,
        onSelected: controller.setGrid,
        icon: Icon(
          Icons.grid_3x3_outlined,
          color: state.grid == CaptureGrid.off ? null : Colors.tealAccent,
        ),
        itemBuilder: (BuildContext context) => CaptureGrid.values
            .map(
              (CaptureGrid grid) => PopupMenuItem<CaptureGrid>(
                value: grid,
                child: Text(_gridLabel(grid)),
              ),
            )
            .toList(growable: false),
      ),
      if (state.onionMode != OnionMode.off)
        IconButton(
          onPressed: () => _showOnionOpacity(context),
          tooltip: 'Onion opacity',
          icon: const Icon(Icons.opacity_outlined),
        ),
      if (state.camera.capabilities case final CameraCapabilities capabilities)
        if (capabilities.maximumExposure > capabilities.minimumExposure)
          IconButton(
            onPressed: () => _showExposure(context),
            tooltip: 'Exposure compensation',
            icon: const Icon(Icons.exposure_outlined),
          ),
      PopupMenuButton<int>(
        tooltip: 'Self timer',
        initialValue: state.timerSeconds,
        onSelected: controller.setTimerSeconds,
        icon: Icon(
          Icons.timer_outlined,
          color: state.timerSeconds == 0 ? null : Colors.tealAccent,
        ),
        itemBuilder: (BuildContext context) => const <int>[0, 2, 5, 10]
            .map(
              (int seconds) => PopupMenuItem<int>(
                value: seconds,
                child: Text(seconds == 0 ? 'Timer off' : '$seconds seconds'),
              ),
            )
            .toList(growable: false),
      ),
      IconButton(
        onPressed: onInterval,
        tooltip: state.intervalActive
            ? 'Stop interval capture'
            : 'Interval capture',
        icon: Icon(
          Icons.timelapse,
          color: state.intervalActive ? Colors.redAccent : null,
        ),
      ),
      if (state.camera.capabilities?.supportsFocusLock ?? false)
        IconButton(
          onPressed: controller.toggleLocks,
          tooltip: state.locksEnabled
              ? 'Unlock focus and exposure'
              : 'Lock focus and exposure',
          icon: Icon(
            state.locksEnabled ? Icons.lock : Icons.lock_open,
            color: state.locksEnabled ? Colors.tealAccent : null,
          ),
        ),
    ];
    final Widget controls = vertical
        ? ListView(children: tools)
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(mainAxisSize: MainAxisSize.min, children: tools),
          );
    return IconTheme(
      data: const IconThemeData(color: Colors.white),
      child: controls,
    );
  }

  Future<void> _showOnionOpacity(BuildContext context) async {
    double value = state.onionOpacity;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Onion opacity ${(value * 100).round()}%'),
                Slider(
                  min: 0.1,
                  max: 0.9,
                  divisions: 8,
                  value: value,
                  onChanged: (double next) {
                    setState(() => value = next);
                    controller.setOnionOpacity(next);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showExposure(BuildContext context) async {
    final capabilities = state.camera.capabilities!;
    double value = state.exposure.clamp(
      capabilities.minimumExposure,
      capabilities.maximumExposure,
    );
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Exposure ${value.toStringAsFixed(1)}'),
                Slider(
                  min: capabilities.minimumExposure,
                  max: capabilities.maximumExposure,
                  value: value,
                  onChanged: (double next) {
                    setState(() => value = next);
                    controller.setExposure(next);
                  },
                ),
                TextButton(
                  onPressed: () {
                    setState(() => value = 0);
                    controller.setExposure(0);
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _onionLabel(OnionMode mode) => switch (mode) {
  OnionMode.off => 'Onion skin off',
  OnionMode.previous => 'Previous frame',
  OnionMode.previousTwo => 'Previous two frames',
  OnionMode.difference => 'Difference mode',
};

String _gridLabel(CaptureGrid grid) => switch (grid) {
  CaptureGrid.off => 'Grid off',
  CaptureGrid.thirds => 'Rule of thirds',
  CaptureGrid.square => 'Square',
  CaptureGrid.crosshair => 'Center crosshair',
};
