import 'package:meta/meta.dart';
import 'game_node_base.dart';
import 'services/firebase_service.dart';

class GameMapNode extends GameNodeBase {
  final String image;
  final String sound;
  final bool win;
  final bool lose;
  final String loseReason;

  GameMapNode({
    required String nodeId,
    required String description,
    required List<String> nextNodes,
    required List<String> actionTexts,
    required List<double> resources,
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
          resources: resources,
          isEndNode: isEndNode,
        );

  factory GameMapNode.fromFirestore(Map<String, dynamic> data) {
    // Get the next nodes from option1, option2, option3
    final List<String> nextNodes = [
      data['option1']?.toString() ?? '',
      data['option2']?.toString() ?? '',
      data['option3']?.toString() ?? '',
    ].where((node) => node.isNotEmpty && node != '0').toList();

    // Get the action texts from text1, text2, text3
    final List<String> actionTexts = [
      data['text1']?.toString() ?? '',
      data['text2']?.toString() ?? '',
      data['text3']?.toString() ?? '',
    ].where((text) => text.isNotEmpty).toList();

    // Get the resources from resources1, resources2, resources3
    final List<double> resources = [
      data['resources1']?.toString() ?? '0',
      data['resources2']?.toString() ?? '0',
      data['resources3']?.toString() ?? '0',
    ].map((value) => double.tryParse(value) ?? 0.0).toList();

    // Trim resources list to match nextNodes length
    while (resources.length > nextNodes.length) {
      resources.removeLast();
    }

    // A node is an end node if it has no valid next nodes or is explicitly marked as win/lose
    final bool win = data['win'] as bool? ?? false;
    final bool lose = data['lose'] as bool? ?? false;
    final bool isEndNode = win || lose || nextNodes.isEmpty;

    return GameMapNode(
      nodeId: data['nodeID']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      nextNodes: nextNodes,
      actionTexts: actionTexts.take(nextNodes.length).toList(), // Ensure actionTexts matches nextNodes
      resources: resources,
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

  final Map<String, GameMapNode> _nodes = {};
  bool _isInitialized = false;
  GameMapNode? _defaultLoseNode;

  bool get isInitialized => _isInitialized;
  
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final firebaseService = FirebaseService();
      final List<Map<String, dynamic>> nodesData = await firebaseService.fetchNodeMapData();
      
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

  GameMapNode? getNode(String nodeId) {
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
    
    // First try to find the default lose node
    if (_defaultLoseNode != null) {
      return _defaultLoseNode;
    }
    
    // If no default lose node, find the first node marked as lose
    return _nodes.values.firstWhere(
      (node) => node.isLoseNode,
      orElse: () => throw GameMapError('No lose node found in game map'),
    );
  }
}