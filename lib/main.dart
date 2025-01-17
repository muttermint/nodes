import 'package:flutter/material.dart';
import 'game_map.dart';   // Import GameMap and GameMapNode
import 'game_data.dart';  // Import GameData if needed


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

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

Future<void> _initializeGame() async {
  try {
    setState(() {
      isLoading = true;
      error = null;
    });

    final gameMap = GameMap();
    await gameMap.initialize(); // Load nodes from CSV

    if (gameMap.nodes.isEmpty) {
      throw Exception('Game map has no nodes.');
    }

    final startNode = gameMap.getStartNode();

    setState(() {
      currentNode = startNode;
      isLoading = false;
    });
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

  // Get the next node ID and transition
  final nextNodeId = currentNode!.nextNodes[index];
  GameMapNode? nextNode;
  try {
    nextNode = GameMap().getNode(nextNodeId); // Use GameMap's getNode
  } catch (e) {
    setState(() {
      error = 'Game error: Invalid transition to a null node';
      currentNode = GameMap().getDefaultLoseNode(); // Transition to lose node
    });
    return;
  }

  if (nextNode == null || nextNode.hasLoseCondition) {
    setState(() {
      error = 'You have encountered a lose condition.';
      currentNode = GameMap().getDefaultLoseNode(); // Transition to lose node
    });
    return;
  }

  setState(() {
    currentNode = nextNode;
  });
}



void restartGame() async {
  try {
    setState(() {
      resources = 100.0;
      error = null;
    });
    final gameMap = GameMap();  // Create GameMap instance
    await gameMap.initialize();  // Ensure this is called to reload the map
    currentNode = gameMap.getStartNode();  // Get the starting node after initialization
  } catch (e) {
    setState(() {
      error = 'Error restarting the game: $e';
    });
  }
}

Widget _buildImage(String imagePath) {
  // Ensure the imagePath is not empty
  if (imagePath.isEmpty || imagePath == 'image') {
    imagePath = 'default.webp';  // Fallback to default image if no valid path is provided
  }
  print('Loading image: $imagePath');
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
        'assets/images/$imagePath',
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
      appBar: AppBar(title: const Text('Game Over')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: restartGame,
              child: const Text('Restart Game'),
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
      title: const Text('Cossack Adventure'),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Resources: ${resources.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
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
                      const Text(
                        'Situation',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
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
                          const SizedBox(width: 20),
                          _buildImage(currentNode!.image),
                        ],
                      ),
                      if (currentNode!.isEndNode) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
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
                        ElevatedButton(
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
                          child: const Text(
                            'Play Again',
                            style: TextStyle(
                              fontSize: 18,
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
              if (!currentNode!.isEndNode && currentNode!.actionTexts.isNotEmpty) ...[
                const Text(
                  'Your Options:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(
                  currentNode!.actionTexts.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ElevatedButton(
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
                      child: Text(
                        '${currentNode!.actionTexts[index]} (${currentNode!.resourceCosts[index].toStringAsFixed(1)} resources)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
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