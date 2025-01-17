import 'package:flutter/services.dart' show rootBundle;

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

  @override
  String toString() {
    return 'GameNode{nodeId: $nodeId, options: $options, optionText: $optionText}';
  }
}

class GameData {
  static final Map<String, GameNode> _nodes = {};
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('Loading CSV file...');
      final String csvData = await rootBundle.loadString('assets/game_map.csv');
      print('CSV file loaded, length: ${csvData.length}');

      final List<String> lines = csvData.split('\n');
      print('Number of lines: ${lines.length}');

      // Skip header line
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        try {
          final parts = _parseCsvLine(line);
          if (parts.length < 14) {
            print('Skipping line $i: insufficient columns (${parts.length})');
            continue;
          }

          final nodeId = parts[0];
          final options = [parts[1], parts[2], parts[3]]
              .where((option) => option != 'None')
              .toList();
          final optionText = [parts[4], parts[5], parts[6]]
              .where((text) => text != 'No action specified')
              .toList();
          final resources = [
            double.tryParse(parts[7]) ?? 0.0,
            double.tryParse(parts[8]) ?? 0.0,
            double.tryParse(parts[9]) ?? 0.0,
          ].sublist(0, options.length);

          _nodes[nodeId] = GameNode(
            nodeId: nodeId,
            options: options,
            optionText: optionText,
            resources: resources,
            description: parts[10],
            win: parts[11],
            lose: parts[12],
            loseReason: parts[13],
          );
          print('Added node: $nodeId');
        } catch (e) {
          print('Error processing line $i: $e');
        }
      }

      print('Nodes loaded: ${_nodes.length}');
      print('Available nodes: ${_nodes.keys.join(', ')}');

      _isInitialized = true;
    } catch (e, stackTrace) {
      print('Error initializing game data: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static List<String> _parseCsvLine(String line) {
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
