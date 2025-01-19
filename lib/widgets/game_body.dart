import 'package:flutter/material.dart';
import '../game_map.dart';
import 'action_button.dart';
import 'game_image.dart';
import 'fancy_play_again_button.dart';

class GameBody extends StatelessWidget {
  final GameMapNode node;
  final bool imagesEnabled;
  final Function(int) onActionPressed;
  final VoidCallback onRestartPressed;

  const GameBody({
    super.key,
    required this.node,
    required this.imagesEnabled,
    required this.onActionPressed,
    required this.onRestartPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'Situation',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              node.description,
                              style: const TextStyle(
                                fontSize: 18,
                                height: 1.5,
                                color: Color(0xFF34495E),
                              ),
                            ),
                          ),
                          if (imagesEnabled) ...[
                            const SizedBox(width: 20),
                            GameImage(imagePath: node.image),
                          ],
                        ],
                      ),
                      if (node.isEndNode) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              node.isWinNode
                                  ? Icons.emoji_events
                                  : Icons.warning,
                              color: node.isWinNode
                                  ? const Color(0xFF27AE60)
                                  : const Color(0xFFE74C3C),
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              node.isWinNode ? 'Victory!' : 'Defeat',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: node.isWinNode
                                    ? const Color(0xFF27AE60)
                                    : const Color(0xFFE74C3C),
                              ),
                            ),
                          ],
                        ),
                        if (node.loseReason.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            node.loseReason,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF7F8C8D),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Center(
                          child: FancyPlayAgainButton(
                            onPressed: onRestartPressed,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!node.isEndNode && node.actionTexts.isNotEmpty) ...[
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.list_alt, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Your Options:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...List.generate(
                  node.actionTexts.length,
                  (index) => ActionButton(
                    text: node.actionTexts[index],
                    pointsChange:
                        node.actionPoints[index], // Updated to use pointsChange
                    onPressed: () => onActionPressed(index),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
