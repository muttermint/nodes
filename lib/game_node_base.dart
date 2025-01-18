import 'package:meta/meta.dart';

class GameNodeParseError extends Error {
  final String message;
  final int rowIndex;
  GameNodeParseError(this.message, this.rowIndex);
  
  @override
  String toString() => 'GameNodeParseError: $message (Row: $rowIndex)';
}

abstract class GameNodeBase {
  final String nodeId;
  final String description;
  final List<String> nextNodes;
  final List<String> actionTexts;
  final List<double> resources;
  final bool isEndNode;

  GameNodeBase({
    required this.nodeId,
    required this.description,
    required this.nextNodes,
    required this.actionTexts,
    required this.resources,
    required this.isEndNode,
  }) {
    // Validate that resources match the number of actions
    if (!isEndNode && resources.length != nextNodes.length) {
      throw ArgumentError('Resources count must match the number of next nodes');
    }
  }

  /// Gets the resource costs for each action
  List<double> get resourceCosts => resources;

  /// Parses common fields from a CSV row
  @protected
  static ({
    String nodeId,
    String description,
    List<String> nextNodes,
    List<String> actionTexts,
    List<double> resources,
    bool isEndNode,
    String image,
    String winCondition,
    String loseCondition,
    String loseReason,
  }) parseRow(List<String> row, [int rowIndex = 0]) {
    if (row.length < 15) {
      throw GameNodeParseError(
        'Row must have at least 15 columns',
        rowIndex,
      );
    }

    final nodeId = row[0].trim();
    if (nodeId.isEmpty) {
      throw GameNodeParseError('Node ID cannot be empty', rowIndex);
    }

    final description = row[10].trim();
    if (description.isEmpty) {
      throw GameNodeParseError('Description cannot be empty', rowIndex);
    }

    final image = row[11].trim();
    final winCondition = row[12].trim();
    final loseCondition = row[13].trim();
    final loseReason = row[14].trim();
    final isEndNode = winCondition == '1' || loseCondition == '1';

    List<String> nextNodes = [];
    List<String> actionTexts = [];
    List<double> resources = [];

    if (!isEndNode) {
      // Parse next nodes
      nextNodes = [row[1], row[2], row[3]]
          .where((node) => node.isNotEmpty && node != 'None' && node != '0')
          .toList();
          
      // Parse action texts - must match number of next nodes
      actionTexts = [row[4], row[5], row[6]]
          .where((text) => text.isNotEmpty && text != 'None')
          .toList();
          
      if (actionTexts.length != nextNodes.length) {
        throw GameNodeParseError(
          'Number of action texts (${actionTexts.length}) must match number of next nodes (${nextNodes.length})',
          rowIndex,
        );
      }

      // Parse and validate resources
      try {
        resources = List.generate(
          nextNodes.length,
          (i) {
            final value = row[7 + i].replaceAll(',', '').trim();
            if (value.isEmpty) return 0.0;
            
            final resource = double.tryParse(value);
            if (resource == null) {
              throw GameNodeParseError(
                'Invalid resource value: $value at index $i',
                rowIndex,
              );
            }
            return resource;
          },
        );
      } catch (e) {
        if (e is GameNodeParseError) rethrow;
        throw GameNodeParseError('Error parsing resources: $e', rowIndex);
      }
    }

    return (
      nodeId: nodeId,
      description: description,
      nextNodes: nextNodes,
      actionTexts: actionTexts,
      resources: resources,
      isEndNode: isEndNode,
      image: image,
      winCondition: winCondition,
      loseCondition: loseCondition,
      loseReason: loseReason,
    );
  }
}