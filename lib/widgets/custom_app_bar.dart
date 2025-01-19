import 'package:flutter/material.dart';
import 'resource_display.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int resources; // Changed from double to int
  final VoidCallback onHelpPressed;
  final VoidCallback onSettingsPressed;

  const CustomAppBar({
    super.key,
    required this.resources,
    required this.onHelpPressed,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.castle),
          SizedBox(width: 8),
          Text('Cossack Adventure'),
        ],
      ),
      actions: [
        Center(
          child: ResourceDisplay(resources: resources),
        ),
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: onHelpPressed,
          tooltip: 'How to Play',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: onSettingsPressed,
          tooltip: 'Settings',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
