import 'package:flutter/material.dart';

class ResourceDisplay extends StatelessWidget {
  final int resources; // Changed from double to int

  const ResourceDisplay({
    super.key,
    required this.resources,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.diamond),
          const SizedBox(width: 4),
          Text(
            'Resources: $resources', // Removed .toStringAsFixed(1) since we're using integers
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
