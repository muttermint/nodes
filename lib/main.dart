import 'package:flutter/material.dart';
import 'game_map.dart';
import 'services/firebase_service.dart';
import 'services/audio_service.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/game_body.dart';
import 'widgets/settings_dialog.dart';
import 'widgets/game_over_screen.dart';
import 'widgets/loading_screen.dart';
import 'widgets/how_to_play_dialog.dart';

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
      appBar: CustomAppBar(
        resources: resources,
        onHelpPressed: _showHowToPlayDialog,
        onSettingsPressed: _showSettingsDialog,
      ),
      body: GameBody(
        node: currentNode!,
        imagesEnabled: _imagesEnabled,
        onActionPressed: makeChoice,
        onRestartPressed: restartGame,
      ),
    );
  }
}
