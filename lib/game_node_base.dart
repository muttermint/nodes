import 'package:meta/meta.dart';

class GameNodeError extends Error {
  final String message;
  GameNodeError(this.message);

  @override
  String toString() => 'GameNodeError: $message';
}

class GameNodeBase {
  final int nodeId; // Changed from String to int
  final String description;
  final List<int> nextNodes; // Changed from List<String> to List<int>
  final List<String> actionTexts;
  final List<int> pointsChange;
  final bool isEndNode;

  GameNodeBase({
    required this.nodeId,
    required this.description,
    required this.nextNodes,
    required this.actionTexts,
    required this.pointsChange,
    required this.isEndNode,
  }) {
    if (!isEndNode && pointsChange.length != nextNodes.length) {
      throw ArgumentError('Points changes must match the number of next nodes');
    }
  }

  List<int> get actionPoints => pointsChange;
}
