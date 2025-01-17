import 'package:flutter/services.dart';

class GameMapNode {
  final String nodeId;
  final List<String> nextNodes;
  final List<String> actionTexts;
  final List<double> resourceCosts;
  final String description;
  final String image;
  final String winCondition;
  final String loseCondition;
  final String loseReason;

  GameMapNode({
    required this.nodeId,
    required this.nextNodes,
    required this.actionTexts,
    required this.resourceCosts,
    required this.description,
    required this.image,
    required this.winCondition,
    required this.loseCondition,
    required this.loseReason,
  });

  factory GameMapNode.fromCsvRow(List<String> row) {
    bool isEndNode = row[12] == '1' || row[13] == '1';
    print(
        'Node ${row[0]} has lose condition: ${row[13]}'); // Log lose condition

    // For end nodes, we ensure lists are empty
    List<String> nextNodes = [];
    List<String> actionTexts = [];
    List<double> resourceCosts = [];

    // Only process actions for non-end nodes
    if (!isEndNode) {
      nextNodes = [row[1], row[2], row[3]]
          .where((node) => node.isNotEmpty && node != 'None')
          .toList();

      actionTexts = [row[4], row[5], row[6]]
          .where((text) => text.isNotEmpty && text != 'None')
          .toList();

      resourceCosts = List.generate(nextNodes.length,
          (i) => double.tryParse(row[7 + i].replaceAll(',', '')) ?? 0.0);
    }

    return GameMapNode(
      nodeId: row[0],
      nextNodes: nextNodes,
      actionTexts: actionTexts,
      resourceCosts: resourceCosts,
      description: row[10],
      image: row[11].trim(),
      winCondition: row[12].trim(),
      loseCondition: row[13].trim(),
      loseReason: row[14].trim(),
    );
  }

  bool get isEndNode => winCondition == '1' || loseCondition == '1';
  bool get isWinNode => winCondition == '1';
  bool get isLoseNode => loseCondition == '1';

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

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final String csvData = await rootBundle.loadString('assets/game_map.csv');
      final List<String> lines = csvData.split('\n');

      // Skip header line
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        try {
          final List<String> row = _parseCsvLine(line);
          if (row.length < 15) {
            print(
                'Warning: Invalid row at line $i (insufficient columns): ${row.length} columns');
            continue;
          }

          final node = GameMapNode.fromCsvRow(row);
          _nodes[node.nodeId] = node;

          // Log if it's a lose node
          if (node.isLoseNode) {
            print('Found lose node: ${node.nodeId}');
          }

          // Store the first lose node we find as the default
          if (node.isLoseNode && _defaultLoseNode == null) {
            _defaultLoseNode = node;
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

  List<String> _parseCsvLine(String line) {
    List<String> result = [];
    bool inQuotes = false;
    StringBuffer currentField = StringBuffer();

    for (int i = 0; i < line.length; i++) {
      if (line[i] == '"') {
        inQuotes = !inQuotes;
      } else if (line[i] == ',' && !inQuotes) {
        result.add(currentField.toString().trim());
        currentField.clear();
      } else {
        currentField.write(line[i]);
      }
    }
    result.add(currentField.toString().trim());
    return result;
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

    final startNode = _nodes['1']; // Start with node ID '1'
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
