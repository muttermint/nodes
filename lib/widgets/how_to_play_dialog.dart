import 'package:flutter/material.dart';

class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF3498DB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.help_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'How to Play Cossack Adventure',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        'Objective',
                        'Your main goal is to make strategic decisions that lead your Cossack group to victory while managing points wisely. You will face various scenarios, and your choices will impact the points available to you.',
                      ),
                      _buildSection(
                        'Getting Started',
                        '• Launch the Game: Open the app to start your adventure.\n'
                            '• Initial Choices: You will begin at a starting node where you\'ll be presented with options. Each option has a different consequence on your points.',
                      ),
                      _buildSection(
                        'Game Mechanics',
                        '• Points: Each choice will give or take points from you.\n'
                            '• Decision Points: At each node, you will face multiple choices:\n'
                            '  - Option 1: May have a lower point cost but could be less effective.\n'
                            '  - Option 2: A balanced choice that could provide moderate benefits.\n'
                            '  - Option 3: Often high-risk, high-reward options.',
                      ),
                      _buildSection(
                        'Making Choices',
                        '• Assess the point costs and potential outcomes of each option.\n'
                            '• Click on your chosen option to proceed to the next scenario.\n'
                            '• The game ends when you reach a victory or defeat node.',
                      ),
                      _buildSection(
                        'Winning and Losing',
                        '• Winning: Successfully navigate through nodes with strategic choices.\n'
                            '• Losing: Your points drop to zero or you make choices leading to defeat.',
                      ),
                      _buildSection(
                        'Tips for Success',
                        '• Plan Ahead: Consider the long-term effects of your choices.\n'
                            '• Point Management: Monitor your points carefully.\n'
                            '• Explore Different Paths: Try different options in each playthrough.',
                      ),
                      _buildSection(
                        'Settings',
                        '• Sound Effects: Toggle game sounds on/off in settings.\n'
                            '• Image Display: Choose to show or hide scenario images.',
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            backgroundColor: const Color(0xFF27AE60),
                          ),
                          child: const Text(
                            'Got it!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Color(0xFF34495E),
          ),
        ),
      ],
    );
  }
}
