import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/desktop_service.dart';

class DesktopWindowControls extends StatelessWidget {
  const DesktopWindowControls({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show on desktop platforms
    if (kIsWeb ||
        !(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Minimize button
        _WindowButton(
          icon: Icons.remove,
          onPressed: () => DesktopService().minimizeWindow(),
          tooltip: 'Minimize',
        ),

        // Maximize/Restore button
        _WindowButton(
          icon: Icons.crop_square,
          onPressed: () => DesktopService().maximizeWindow(),
          tooltip: 'Maximize',
        ),

        // Close button
        _WindowButton(
          icon: Icons.close,
          onPressed: () => DesktopService().closeWindow(),
          tooltip: 'Close',
          isCloseButton: true,
        ),
      ],
    );
  }
}

class _WindowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isCloseButton;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            width: 46,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Icon(
              icon,
              size: 16,
              color: isCloseButton
                  ? Colors.red
                  : Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      ),
    );
  }
}
