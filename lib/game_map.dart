import 'package:meta/meta.dart';
import 'game_node_base.dart';
import 'services/firebase_service.dart';

class GameMapNode extends GameNodeBase {
  final String image;
  final String sound;
  final String winCondition;
  final String loseCondition;
  final String loseReason;

  GameMapNode({
    required super.nodeId,
    required super.description,
    required super.nextNodes,
    required super.actionTexts,
    required super.resources,
    required super.isEndNode,
    required this.image,
    required this.sound,
    required this.winCondition,
    required this.loseCondition,
    required this.loseReason,
  });

  factory GameMapNode.fromFirebase(Map<String, dynamic> data) {
    final List<String> nextNodes = [];
    final List<String> actionTexts = [];
    final List<double> resources = [];

    // Parse next nodes, action texts, and resources
    for (int i = 1; i <= 3; i++) {
      final nextNode = data['option$i']?.toString() ?? '';
      final actionText = data['text$i']?.toString() ?? '';
      final resource =
          double.tryParse(data['resources$i']?.toString() ?? '0') ?? 0.0;

      if (nextNode.isNotEmpty && nextNode != '0') {
        nextNodes.add(nextNode);
        actionTexts.add(actionText);
        resources.add(resource);
      }
    }

    final isEndNode = data['win'] == '1' || data['lose'] == '1';

    return GameMapNode(
      nodeId: data['nodeID']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      nextNodes: nextNodes,
      actionTexts: actionTexts,
      resources: resources,
      isEndNode: isEndNode,
      image: data['image']?.toString() ?? '',
      sound: data['sound']?.toString() ?? '',
      winCondition: data['win']?.toString() ?? '0',
      loseCondition: data['lose']?.toString() ?? '0',
      loseReason: data['loseReason']?.toString() ?? '',
    );
  }

  bool get isWinNode => winCondition == '1';
  bool get isLoseNode => loseCondition == '1';
  bool get hasSound => sound.isNotEmpty;

  @override
  String toString() {
    return 'GameMapNode{nodeId: $nodeId, nextNodes: $nextNodes, actionTexts: $actionTexts}';
  }
}

class GameMapError extends Error {
  final String message;
  GameMapError(this.message);

  @override
  String toString() => 'GameMapError: $message';
}

class GameMap {
  static final GameMap _instance = GameMap._internal();
  factory GameMap() => _instance;
  GameMap._internal();

  final Map<String, GameMapNode> _nodes = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase service
      final firebaseService = FirebaseService();
      await firebaseService.initialize();

      // Fetch node data from Firebase
      final nodeData = await firebaseService.fetchNodeMapData();

      // Process each node
      for (final data in nodeData) {
        try {
          final node = GameMapNode.fromFirebase(data);
          _nodes[node.nodeId] = node;
        } catch (e) {
          print('Error processing node data: $e');
        }
      }

      if (_nodes.isEmpty) {
        throw GameMapError('No valid nodes found in game map');
      }

      _isInitialized = true;
      print('Game map initialized with ${_nodes.length} nodes');
    } catch (e, stackTrace) {
      print('Error initializing game map: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  GameMapNode? getNode(String nodeId) {
    if (!_isInitialized) {
      throw GameMapError('GameMap not initialized. Call initialize() first.');
    }
    return _nodes[nodeId];
  }

  GameMapNode getStartNode() {
    if (!_isInitialized) {
      throw GameMapError('GameMap not initialized. Call initialize() first.');
    }

    final startNode = _nodes['1'];
    if (startNode == null) {
      throw GameMapError('Start node (ID: 1) not found in game map');
    }

    return startNode;
  }

  GameMapNode? findLoseNode() {
    if (!_isInitialized) {
      throw GameMapError('GameMap not initialized. Call initialize() first.');
    }

    // Find the first node marked as a lose node
    return _nodes.values.firstWhere(
      (node) => node.isLoseNode,
      orElse: () => throw GameMapError('No lose node found in game map'),
    );
  }
}
