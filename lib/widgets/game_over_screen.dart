import 'package:flutter/material.dart';

class GameOverScreen extends StatelessWidget {
  final String error;
  final Widget playAgainButton;

  const GameOverScreen({
    super.key,
    required this.error,
    required this.playAgainButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber),
            SizedBox(width: 8),
            Text('Game Over'),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            playAgainButton,
          ],
        ),
      ),
    );
  }
}
