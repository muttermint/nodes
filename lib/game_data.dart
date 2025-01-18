import 'csv_parser.dart';
import 'game_node_base.dart';

class GameNode extends GameNodeBase {
  final String win;
  final String lose;
  final String loseReason;

  GameNode({
    required super.nodeId,
    required super.description,
    required super.nextNodes,
    required super.actionTexts,
    required super.resources,
    required super.isEndNode,
    required this.win,
    required this.lose,
    required this.loseReason,
  });

  factory GameNode.fromCsvRow(List<String> row) {
    final parsed = GameNodeBase.parseRow(row);
    
    return GameNode(
      nodeId: parsed.nodeId,
      description: parsed.description,
      nextNodes: parsed.nextNodes,
      actionTexts: parsed.actionTexts,
      resources: parsed.resources,
      isEndNode: parsed.isEndNode,
      win: parsed.winCondition,
      lose: parsed.loseCondition,
      loseReason: parsed.loseReason,
    );
  }

  @override
  String toString() {
    return 'GameNode{nodeId: $nodeId, nextNodes: $nextNodes, actionTexts: $actionTexts}';
  }
}