import 'game_node_base.dart';
import 'services/firebase_service.dart';

class GameMapNode extends GameNodeBase {
  final String image;
  final String sound;
  final bool win;
  final bool lose;
  final String loseReason;

  GameMapNode({
    required int nodeId, // Changed from String to int
    required String description,
    required List<int> nextNodes,
    required List<String> actionTexts,
    required List<int> pointsChange,
    required bool isEndNode,
    required this.image,
    required this.sound,
    required this.win,
    required this.lose,
    required this.loseReason,
  }) : super(
          nodeId: nodeId,
          description: description,
          nextNodes: nextNodes,
          actionTexts: actionTexts,
          pointsChange: pointsChange,
          isEndNode: isEndNode,
        );

  factory GameMapNode.fromFirestore(Map<String, dynamic> data) {
    final List<int> nextNodes = [
      int.tryParse(data['option1']?.toString() ?? '0') ?? 0,
      int.tryParse(data['option2']?.toString() ?? '0') ?? 0,
      int.tryParse(data['option3']?.toString() ?? '0') ?? 0,
    ].where((node) => node > 0).toList();

    final List<String> actionTexts = [
      data['text1']?.toString() ?? '',
      data['text2']?.toString() ?? '',
      data['text3']?.toString() ?? '',
    ].where((text) => text.isNotEmpty).toList();

    final List<int> pointsChange = [
      int.tryParse(data['resources1']?.toString() ?? '0') ?? 0,
      int.tryParse(data['resources2']?.toString() ?? '0') ?? 0,
      int.tryParse(data['resources3']?.toString() ?? '0') ?? 0,
    ];

    while (pointsChange.length > nextNodes.length) {
      pointsChange.removeLast();
    }

    final bool win = data['win'] as bool? ?? false;
    final bool lose = data['lose'] as bool? ?? false;
    final bool isEndNode = win || lose || nextNodes.isEmpty;

    // Parse nodeId as int
    final int nodeId = int.tryParse(data['nodeID']?.toString() ?? '0') ?? 0;
    if (nodeId <= 0) {
      throw GameMapError('Invalid nodeId: $nodeId');
    }

    return GameMapNode(
      nodeId: nodeId,
      description: data['description']?.toString() ?? '',
      nextNodes: nextNodes,
      actionTexts: actionTexts.take(nextNodes.length).toList(),
      pointsChange: pointsChange,
      isEndNode: isEndNode,
      image: data['image']?.toString() ?? '',
      sound: data['sound']?.toString() ?? '',
      win: win,
      lose: lose,
      loseReason: data['loseReason']?.toString() ?? '',
    );
  }

  bool get isWinNode => win;
  bool get isLoseNode => lose;
  bool get hasSound => sound.isNotEmpty;

  @override
  String toString() {
    return 'GameMapNode{nodeId: $nodeId, nextNodes: $nextNodes, actionTexts: $actionTexts, isEndNode: $isEndNode}';
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

  final Map<int, GameMapNode> _nodes =
      {}; // Changed from Map<String, GameMapNode>
  bool _isInitialized = false;
  GameMapNode? _defaultLoseNode;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final firebaseService = FirebaseService();
      final List<Map<String, dynamic>> nodesData =
          await firebaseService.fetchNodeMapData();

      for (final data in nodesData) {
        try {
          final node = GameMapNode.fromFirestore(data);
          _nodes[node.nodeId] = node;

          if (node.isLoseNode) {
            print('Found lose node: ${node.nodeId}');
            if (_defaultLoseNode == null) {
              _defaultLoseNode = node;
            }
          }
        } catch (e) {
          print('Error processing node data: $e');
        }
      }

      if (_nodes.isEmpty) {
        throw GameMapError('No valid nodes found in game map');
      }

      _isInitialized = true;
      print('Game map initialized with ${_nodes.length} nodes');
    } catch (e) {
      print('Error initializing game map: $e');
      rethrow;
    }
  }

  GameMapNode? getNode(int nodeId) {
    // Changed from String to int
    if (!_isInitialized) {
      throw GameMapError('GameMap not initialized. Call initialize() first.');
    }

    final node = _nodes[nodeId];
    if (node == null) {
      print('Warning: Node $nodeId not found in game map');
      return findLoseNode();
    }

    return node;
  }

  GameMapNode getStartNode() {
    if (!_isInitialized) {
      throw GameMapError('GameMap not initialized. Call initialize() first.');
    }

    final startNode = _nodes[1]; // Changed from '1' to 1
    if (startNode == null) {
      throw GameMapError('Start node (ID: 1) not found in game map');
    }

    return startNode;
  }

  GameMapNode? findLoseNode() {
    if (!_isInitialized) {
      throw GameMapError('GameMap not initialized. Call initialize() first.');
    }

    if (_defaultLoseNode != null) {
      return _defaultLoseNode;
    }

    return _nodes.values.firstWhere(
      (node) => node.isLoseNode,
      orElse: () => throw GameMapError('No lose node found in game map'),
    );
  }
}
