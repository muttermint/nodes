import 'package:meta/meta.dart';

class GameNodeError extends Error {
  final String message;
  GameNodeError(this.message);

  @override
  String toString() => 'GameNodeError: $message';
}

class GameNodeBase {
  final String nodeId;
  final String description;
  final List<String> nextNodes;
  final List<String> actionTexts;
  final List<int> resources; // Changed from List<double> to List<int>
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
      throw ArgumentError(
          'Resources count must match the number of next nodes');
    }
  }

  /// Gets the resource costs for each action
  List<int> get resourceCosts => resources; // Changed return type to List<int>
}
