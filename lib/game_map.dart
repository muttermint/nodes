import 'package:meta/meta.dart';
import 'csv_parser.dart';
import 'game_node_base.dart';

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

  factory GameMapNode.fromCsvRow(List<String> row) {
    final parsed = GameNodeBase.parseRow(row);

    return GameMapNode(
      nodeId: parsed.nodeId,
      description: parsed.description,
      nextNodes: parsed.nextNodes,
      actionTexts: parsed.actionTexts,
      resources: parsed.resources,
      isEndNode: parsed.isEndNode,
      image: parsed.image,
      sound: parsed.sound,
      winCondition: parsed.winCondition,
      loseCondition: parsed.loseCondition,
      loseReason: parsed.loseReason,
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
  GameMapNode? _defaultLoseNode;
  static const String _csvFilePath = 'assets/game_map.csv';

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final parser = CsvParser(_csvFilePath);
      final List<List<String>> rows = await parser.loadCsv();

      // Skip header row
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        try {
          if (row.length < 15) {
            print(
                'Warning: Invalid row at line $i (insufficient columns): ${row.length} columns');
            continue;
          }

          final node = GameMapNode.fromCsvRow(row);
          _nodes[node.nodeId] = node;

          if (node.isLoseNode) {
            print('Found lose node: ${node.nodeId}');
            if (_defaultLoseNode == null) {
              _defaultLoseNode = node;
            }
          }
        } catch (e) {
          print('Error processing line $i: $e');
        }
      }

      if (_nodes.isEmpty) {
        throw GameMapError('No valid nodes found in game map');
      }

      if (_defaultLoseNode == null) {
        throw GameMapError('No lose node found in game map');
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

    final node = _nodes[nodeId];
    if (node == null) {
      print('Warning: Node $nodeId not found in game map');
      return _defaultLoseNode;
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

  GameMapNode getDefaultLoseNode() {
    if (!_isInitialized) {
      throw GameMapError('GameMap not initialized. Call initialize() first.');
    }

    if (_defaultLoseNode == null) {
      throw GameMapError('No lose node found in game map');
    }

    return _defaultLoseNode!;
  }
}
