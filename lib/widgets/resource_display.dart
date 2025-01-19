import 'package:flutter/material.dart';

class ResourceDisplay extends StatelessWidget {
  final int points; // Renamed from resources

  const ResourceDisplay({
    super.key,
    required this.points, // Renamed parameter
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars), // Changed from diamond to stars
          const SizedBox(width: 4),
          Text(
            'Points: $points',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
