import 'package:flutter/services.dart' show rootBundle; // For reading files
import 'package:csv/csv.dart'; // Import CSV package
import 'game_data.dart'; // Ensure the GameNode class is imported


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

  bool get hasLoseCondition => loseCondition.trim() == '1';
  bool get isEndNode => winCondition == '1' || loseCondition == '1';
  bool get isWinNode => winCondition == '1';

  // Factory method to create a GameMapNode from a CSV row
  factory GameMapNode.fromCsvRow(List<String> row) {
    if (row.length < 15) {
      throw Exception('Insufficient data for node: ${row[0]}');
    }

    List<String> nextNodes = [row[1], row[2], row[3]]
        .where((node) => node.isNotEmpty && node != 'None')
        .toList();

    List<String> actionTexts = [row[4], row[5], row[6]]
        .where((text) => text.isNotEmpty && text != 'None')
        .toList();

    List<double> resourceCosts = [
      double.tryParse(row[7].replaceAll(',', '')) ?? 0.0,
      double.tryParse(row[8].replaceAll(',', '')) ?? 0.0,
      double.tryParse(row[9].replaceAll(',', '')) ?? 0.0,
    ];

    // Log the nodeId for debugging
    print('Parsing node ${row[0]} with nodeId: ${row[0].trim()}');

    return GameMapNode(
      nodeId: row[0].trim(),  // Ensure nodeId is trimmed
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

}



class GameMapError extends Error {
  final String message;
  GameMapError(this.message);
  
  @override
  String toString() => 'GameMapError: $message';
}


class GameMap {
  List<GameMapNode> nodes = [];

  Future<void> initialize() async {
    final csvData = await rootBundle.loadString('assets/game_map.csv');
    List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

    for (var row in rows) {
      try {
        List<String> stringRow = row.map((item) => item.toString()).toList();
        var node = GameMapNode.fromCsvRow(stringRow);
        nodes.add(node);
        print('Loaded node: ${node.nodeId}');
      } catch (e) {
        print('Error parsing row: $row, Error: $e');
      }
    }
  }

  GameMapNode getStartNode() {
    if (nodes.isEmpty) {
      throw Exception('No nodes available. Please initialize the map.');
    }
    return nodes[0]; // Return the first node as the starting node
  }

  GameMapNode getNode(String nodeId) {
    return nodes.firstWhere((node) => node.nodeId == nodeId);
  }

  GameMapNode getDefaultLoseNode() {
    try {
      // Try to find a node with a lose condition
      return nodes.firstWhere((node) => node.hasLoseCondition);
    } catch (e) {
      // Log that no lose node was found and return a default node
      print('No lose condition node found. Returning default.');
      return nodes.isNotEmpty ? nodes.first : GameMapNode(
        nodeId: 'default',  // Provide fallback details
        nextNodes: [],
        actionTexts: [],
        resourceCosts: [],
        description: 'Default lose node. Game Over.',
        image: 'default_image.webp',
        winCondition: '0',
        loseCondition: '1',
        loseReason: 'No valid lose node found.',
      );
    }
  }
}
