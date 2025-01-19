import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'game_map.dart';
import 'services/firebase_service.dart';
import 'services/audio_service.dart';
import 'widgets/settings_dialog.dart';
import 'widgets/game_over_screen.dart';
import 'widgets/loading_screen.dart';
import 'widgets/action_button.dart';
import 'widgets/resource_display.dart';
import 'widgets/how_to_play_dialog.dart';
import 'widgets/game_image.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cossack Adventure',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  GameMapNode? currentNode;
  double resources = 100.0;
  String? error;
  bool isLoading = true;
  final AudioService _audioService = AudioService();
  bool _soundEnabled = true;
  bool _imagesEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      await GameMap().initialize();
      final startNode = GameMap().getStartNode();

      setState(() {
        currentNode = startNode;
        isLoading = false;
      });

      _playNodeSound();
    } catch (e) {
      setState(() {
        error = 'Error loading game: $e';
        isLoading = false;
      });
      print('Error in initState: $e');
    }
  }

  Future<void> _playNodeSound() async {
    if (!_soundEnabled || currentNode == null || !currentNode!.hasSound) return;
    await _audioService.playSound(currentNode!.sound);
  }

  void makeChoice(int index) {
    if (currentNode == null) {
      setState(() {
        error = 'Game error: No current node';
      });
      return;
    }

    if (currentNode!.isEndNode) {
      return;
    }

    if (index < 0 || index >= currentNode!.nextNodes.length) {
      setState(() {
        error = 'Invalid choice. Game over.';
        currentNode = GameMap().findLoseNode();
      });
      _playNodeSound();
      return;
    }

    setState(() {
      resources = (resources - currentNode!.resourceCosts[index])
          .clamp(0.0, double.infinity);

      if (resources <= 0) {
        currentNode = GameMap().findLoseNode();
        _playNodeSound();
        return;
      }

      final nextNodeId = currentNode!.nextNodes[index];
      print('Transitioning to node: $nextNodeId');

      final nextNode = GameMap().getNode(nextNodeId);
      if (nextNode == null) {
        error = 'Game error: Invalid transition';
        currentNode = GameMap().findLoseNode();
        _playNodeSound();
        return;
      }
      currentNode = nextNode;
      _playNodeSound();
    });
  }

  void restartGame() {
    setState(() {
      resources = 100.0;
      currentNode = GameMap().getStartNode();
      error = null;
    });
    _playNodeSound();
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return SettingsDialog(
            soundEnabled: _soundEnabled,
            imagesEnabled: _imagesEnabled,
            onSoundChanged: (value) {
              setDialogState(() {
                setState(() {
                  _soundEnabled = value;
                  _audioService.soundEnabled = value;
                });
              });
            },
            onImagesChanged: (value) {
              setDialogState(() {
                setState(() {
                  _imagesEnabled = value;
                });
              });
            },
          );
        },
      ),
    );
  }

  void _showHowToPlayDialog() {
    showDialog(
      context: context,
      builder: (context) => const HowToPlayDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return GameOverScreen(
        error: error!,
        playAgainButton: ElevatedButton(
          onPressed: restartGame,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            backgroundColor: const Color(0xFF27AE60),
          ),
          child: const Text(
            'Play Again',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (isLoading || currentNode == null) {
      return const LoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
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
            onPressed: _showHowToPlayDialog,
            tooltip: 'How to Play',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Container(
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
                                currentNode!.description,
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1.5,
                                  color: Color(0xFF34495E),
                                ),
                              ),
                            ),
                            if (_imagesEnabled) ...[
                              const SizedBox(width: 20),
                              GameImage(imagePath: currentNode!.image),
                            ],
                          ],
                        ),
                        if (currentNode!.isEndNode) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                currentNode!.isWinNode
                                    ? Icons.emoji_events
                                    : Icons.warning,
                                color: currentNode!.isWinNode
                                    ? const Color(0xFF27AE60)
                                    : const Color(0xFFE74C3C),
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                currentNode!.isWinNode ? 'Victory!' : 'Defeat',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: currentNode!.isWinNode
                                      ? const Color(0xFF27AE60)
                                      : const Color(0xFFE74C3C),
                                ),
                              ),
                            ],
                          ),
                          if (currentNode!.loseReason.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              currentNode!.loseReason,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF7F8C8D),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: restartGame,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              backgroundColor: const Color(0xFF27AE60),
                            ),
                            child: const Text(
                              'Play Again',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (!currentNode!.isEndNode &&
                    currentNode!.actionTexts.isNotEmpty) ...[
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
                    currentNode!.actionTexts.length,
                    (index) => ActionButton(
                      text: currentNode!.actionTexts[index],
                      resourceCost: currentNode!.resourceCosts[index],
                      onPressed: () => makeChoice(index),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
