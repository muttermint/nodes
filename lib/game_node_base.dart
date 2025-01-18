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

  /// Safely gets a value from a row with a default
  static String _safeGet(List<String> row, int index, String defaultValue) {
    if (index >= 0 && index < row.length) {
      return row[index].trim();
    }
    return defaultValue;
  }

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
    String sound,
    String winCondition,
    String loseCondition,
    String loseReason,
  }) parseRow(List<String> row, [int rowIndex = 0]) {
    if (row.length < 11) {
      throw GameNodeParseError(
        'Row must have at least 11 columns',
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

    final image = _safeGet(row, 11, '');
    final sound = _safeGet(row, 12, '');
    final winCondition = _safeGet(row, 13, '0');
    final loseCondition = _safeGet(row, 14, '0');
    final loseReason = _safeGet(row, 15, '');
    
    final isEndNode = winCondition == '1' || loseCondition == '1';

    List<String> nextNodes = [];
    List<String> actionTexts = [];
    List<double> resources = [];

    if (!isEndNode) {
      // Parse next nodes
      nextNodes = [
        _safeGet(row, 1, ''),
        _safeGet(row, 2, ''),
        _safeGet(row, 3, '')
      ].where((node) => node.isNotEmpty && node != 'None' && node != '0')
          .toList();
          
      // Parse action texts - must match number of next nodes
      actionTexts = [
        _safeGet(row, 4, ''),
        _safeGet(row, 5, ''),
        _safeGet(row, 6, '')
      ].where((text) => text.isNotEmpty && text != 'None')
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
            final value = _safeGet(row, 7 + i, '0').replaceAll(',', '');
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
      sound: sound,
      winCondition: winCondition,
      loseCondition: loseCondition,
      loseReason: loseReason,
    );
  }
}