import 'game_map.dart'; // Ensure this import is present
import 'package:flutter/services.dart'; // Import to use rootBundle

class GameData {
  static final List<GameMapNode> nodes = []; // List of nodes

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('Loading CSV file...');
      final String csvData = await rootBundle.loadString('assets/game_map.csv');
      print('CSV file loaded, length: ${csvData.length}');

      final List<String> lines = csvData.split('\n');
      print('Number of lines: ${lines.length}');

      // Skip header line and parse each row
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        try {
          final parts = _parseCsvLine(line);
          if (parts.length < 15) {
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

          nodes.add(GameMapNode(
            nodeId: nodeId,
            nextNodes: options,
            actionTexts: optionText,
            resourceCosts: resources,
            description: parts[10],
            image: parts[11].isNotEmpty
                ? parts[11]
                : 'default_image.webp', // Default to 'default_image.webp' if empty
            winCondition: parts[11],
            loseCondition: parts[12],
            loseReason: parts[13],
          ));

          print('Added node: $nodeId');
        } catch (e) {
          print('Error processing line $i: $e');
        }
      }

      print('Nodes loaded: ${nodes.length}');
      nodes.forEach((node) {
        print('Loaded node ID: ${node.nodeId}');
      });

      print('Nodes loaded: ${nodes.length}');
      print('Available nodes: ${nodes.map((e) => e.nodeId).join(', ')}');

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

  static GameMapNode? getNode(String nodeId) {
    // Ensure nodeId is trimmed for comparison
    return nodes.firstWhere((node) => node.nodeId.trim() == nodeId.trim());
  }
}
