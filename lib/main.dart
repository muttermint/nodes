import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'game_map.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;
  bool _imagesEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playNodeSound() async {
    if (!_soundEnabled || currentNode == null || !currentNode!.hasSound) return;

    try {
      await _audioPlayer.setAsset('assets/sounds/${currentNode!.sound}');
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing sound: $e');
    }
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
        currentNode = GameMap().getDefaultLoseNode();
      });
      _playNodeSound();
      return;
    }

    setState(() {
      resources = (resources - currentNode!.resourceCosts[index])
          .clamp(0.0, double.infinity);

      if (resources <= 0) {
        currentNode = GameMap().getDefaultLoseNode();
        _playNodeSound();
        return;
      }

      final nextNodeId = currentNode!.nextNodes[index];
      print('Transitioning to node: $nextNodeId');

      final nextNode = GameMap().getNode(nextNodeId);
      if (nextNode == null) {
        error = 'Game error: Invalid transition';
        currentNode = GameMap().getDefaultLoseNode();
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

  Future<void> _showSettingsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                        value: _soundEnabled,
                        onChanged: (bool value) {
                          setDialogState(() {
                            setState(() {
                              _soundEnabled = value;
                            });
                          });
                        },
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.image),
                      title: const Text('Show Images'),
                      trailing: Switch(
                        value: _imagesEnabled,
                        onChanged: (bool value) {
                          setDialogState(() {
                            setState(() {
                              _imagesEnabled = value;
                            });
                          });
                        },
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
          },
        );
      },
    );
  }

  Widget _buildImage(String imagePath) {
    if (!_imagesEnabled) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 400,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/${imagePath.isNotEmpty ? imagePath : 'default.webp'}',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFF5F5F5),
              child: const Center(
                child: Text(
                  'Image not available',
                  style: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
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
              Text(error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Restart Game'),
                onPressed: restartGame,
              ),
            ],
          ),
        ),
      );
    }

    if (isLoading || currentNode == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.diamond),
                  const SizedBox(width: 4),
                  Text(
                    'Resources: ${resources.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
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
                              _buildImage(currentNode!.image),
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
                          if (currentNode!.loseReason.isNotEmpty &&
                              currentNode!.loseReason != 'Not applicable') ...[
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
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Play Again'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              backgroundColor: const Color(0xFF2ECC71),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: restartGame,
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
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ElevatedButton(
                        child: Text(
                          '${currentNode!.actionTexts[index]} (${currentNode!.resourceCosts[index].toStringAsFixed(1)} resources)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          backgroundColor: const Color(0xFF3498DB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => makeChoice(index),
                      ),
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
