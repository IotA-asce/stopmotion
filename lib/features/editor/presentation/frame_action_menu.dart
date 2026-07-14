import 'package:flutter/material.dart';

enum FrameAction { selectAll, copy, paste, duplicate, reverse, hold, delete }

class FrameActionMenu extends StatelessWidget {
  const FrameActionMenu({
    required this.onSelected,
    required this.canPaste,
    super.key,
  });

  final ValueChanged<FrameAction> onSelected;
  final bool canPaste;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FrameAction>(
      tooltip: 'Frame actions',
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<FrameAction>>[
        const PopupMenuItem(
          value: FrameAction.selectAll,
          child: Text('Select all'),
        ),
        const PopupMenuItem(value: FrameAction.copy, child: Text('Copy')),
        PopupMenuItem(
          value: FrameAction.paste,
          enabled: canPaste,
          child: const Text('Paste after playhead'),
        ),
        const PopupMenuItem(
          value: FrameAction.duplicate,
          child: Text('Duplicate'),
        ),
        const PopupMenuItem(
          value: FrameAction.reverse,
          child: Text('Reverse selection'),
        ),
        const PopupMenuItem(
          value: FrameAction.hold,
          child: Text('Set hold duration'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: FrameAction.delete,
          child: Text('Delete selection'),
        ),
      ],
    );
  }
}
