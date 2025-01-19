import 'package:flutter/material.dart';

class SettingsDialog extends StatelessWidget {
  final bool soundEnabled;
  final bool imagesEnabled;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onImagesChanged;

  const SettingsDialog({
    super.key,
    required this.soundEnabled,
    required this.imagesEnabled,
    required this.onSoundChanged,
    required this.onImagesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings),
                SizedBox(width: 8),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.volume_up),
              title: const Text('Sound Effects'),
              trailing: Switch(
                value: soundEnabled,
                onChanged: onSoundChanged,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.image),
              title: const Text('Show Images'),
              trailing: Switch(
                value: imagesEnabled,
                onChanged: onImagesChanged,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: const Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}