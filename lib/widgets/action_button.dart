import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final int resourceCost; // Changed from double to int
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.text,
    required this.resourceCost,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          backgroundColor: const Color(0xFF3498DB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          '$text ($resourceCost resources)', // Removed .toStringAsFixed(1) since we're using integers
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
