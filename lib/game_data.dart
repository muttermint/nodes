import 'csv_parser.dart';

class GameNode {
  final String nodeId;
  final List<String> options;
  final List<String> optionText;
  final List<double> resources;
  final String description;
  final String win;
  final String lose;
  final String loseReason;

  GameNode({
    required this.nodeId,
    required this.options,
    required this.optionText,
    required this.resources,
    required this.description,
    required this.win,
    required this.lose,
    required this.loseReason,
  });

  factory GameNode.fromCsvRow(List<String> row) {
    bool isEndNode = row[12] == '1' || row[13] == '1';

    List<String> options = [];
    List<String> optionText = [];
    List<double> resources = [];

    if (!isEndNode) {
      options = [row[1], row[2], row[3]]
          .where((option) => option.isNotEmpty && option != 'None')
          .toList();

      optionText = [row[4], row[5], row[6]]
          .where((text) => text.isNotEmpty && text != 'None')
          .toList();

      resources = List.generate(options.length,
          (i) => double.tryParse(row[7 + i].replaceAll(',', '')) ?? 0.0);
    }

    return GameNode(
      nodeId: row[0],
      options: options,
      optionText: optionText,
      resources: resources,
      description: row[10],
      win: row[12],
      lose: row[13],
      loseReason: row[14],
    );
  }

  @override
  String toString() {
    return 'GameNode{nodeId: $nodeId, options: $options, optionText: $optionText}';
  }
}

class GameData {
  static final Map<String, GameNode> _nodes = {};
  static bool _isInitialized = false;
  static const String _csvFilePath = 'assets/game_map.csv';

  static Future<void> initialize() async {
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

          final node = GameNode.fromCsvRow(row);
          _nodes[node.nodeId] = node;
        } catch (e) {
          print('Error processing line $i: $e');
        }
      }

      _isInitialized = true;
      print('Game data initialized with ${_nodes.length} nodes');
    } catch (e) {
      print('Error initializing game data: $e');
      rethrow;
    }
  }

  static GameNode? getNode(String nodeId) {
    if (!_isInitialized) {
      print('Warning: Attempting to get node before initialization');
      return null;
    }
    final node = _nodes[nodeId];
    if (node == null) {
      print('Node not found: $nodeId');
      print('Available nodes: ${_nodes.keys.join(', ')}');
    }
    return node;
  }
}
