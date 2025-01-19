import 'package:flutter/foundation.dart';
import '../game_map.dart';
import 'audio_service.dart';

class GameState extends ChangeNotifier {
  GameMapNode? currentNode;
  double resources = 100.0;
  String? error;
  bool isLoading = true;
  bool _soundEnabled = true;
  bool _imagesEnabled = true;
  final AudioService _audioService = AudioService();

  bool get soundEnabled => _soundEnabled;
  bool get imagesEnabled => _imagesEnabled;

  Future<void> initialize() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await GameMap().initialize();
      currentNode = GameMap().getStartNode();

      isLoading = false;
      notifyListeners();

      await _playNodeSound();
    } catch (e) {
      error = 'Error loading game: $e';
      isLoading = false;
      notifyListeners();
      print('Error initializing game: $e');
    }
  }

  Future<void> _playNodeSound() async {
    if (!_soundEnabled || currentNode == null || !currentNode!.hasSound) return;
    await _audioService.playSound(currentNode!.sound);
  }

  void makeChoice(int index) {
    if (currentNode == null) {
      error = 'Game error: No current node';
      notifyListeners();
      return;
    }

    if (currentNode!.isEndNode) {
      return;
    }

    if (index < 0 || index >= currentNode!.nextNodes.length) {
      error = 'Invalid choice. Game over.';
      currentNode = GameMap().findLoseNode();
      notifyListeners();
      _playNodeSound();
      return;
    }

    resources = (resources - currentNode!.resourceCosts[index])
        .clamp(0.0, double.infinity);

    if (resources <= 0) {
      currentNode = GameMap().findLoseNode();
      notifyListeners();
      _playNodeSound();
      return;
    }

    final nextNodeId = currentNode!.nextNodes[index];
    print('Transitioning to node: $nextNodeId');

    final nextNode = GameMap().getNode(nextNodeId);
    if (nextNode == null) {
      error = 'Game error: Invalid transition';
      currentNode = GameMap().findLoseNode();
      notifyListeners();
      _playNodeSound();
      return;
    }

    currentNode = nextNode;
    notifyListeners();
    _playNodeSound();
  }

  void restartGame() {
    resources = 100.0;
    currentNode = GameMap().getStartNode();
    error = null;
    notifyListeners();
    _playNodeSound();
  }

  void toggleSound(bool enabled) {
    _soundEnabled = enabled;
    _audioService.soundEnabled = enabled;
    notifyListeners();
  }

  void toggleImages(bool enabled) {
    _imagesEnabled = enabled;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
