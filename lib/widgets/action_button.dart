import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final int pointsChange; // Renamed from resourceCost
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.text,
    required this.pointsChange, // Renamed parameter
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final String pointsText =
        pointsChange >= 0 ? '+$pointsChange' : '$pointsChange';
    final Color pointsColor = pointsChange >= 0 ? Colors.green : Colors.red;

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
          '$text ($pointsText points)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
