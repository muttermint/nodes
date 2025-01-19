import 'package:flutter/foundation.dart';
import '../game_map.dart';
import 'audio_service.dart';
import 'firebase_service.dart';

class GameState extends ChangeNotifier {
  GameMapNode? currentNode;
  int points = 100;
  String? error;
  bool isLoading = true;
  bool _soundEnabled = true;
  bool _imagesEnabled = true;
  final AudioService _audioService = AudioService();
  final GameMap _gameMap = GameMap();

  bool get soundEnabled => _soundEnabled;
  bool get imagesEnabled => _imagesEnabled;

  Future<void> initialize() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _gameMap.initialize();
      currentNode = _gameMap.getStartNode();

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
      currentNode = _gameMap.findLoseNode();
      notifyListeners();
      _playNodeSound();
      return;
    }

    points = (points + currentNode!.actionPoints[index]).clamp(0, 999999);

    if (points <= 0) {
      currentNode = _gameMap.findLoseNode();
      notifyListeners();
      _playNodeSound();
      return;
    }

    final nextNodeId = currentNode!.nextNodes[index];
    print('Transitioning to node: $nextNodeId');

    final nextNode = _gameMap.getNode(nextNodeId);
    if (nextNode == null) {
      error = 'Game error: Invalid transition';
      currentNode = _gameMap.findLoseNode();
      notifyListeners();
      _playNodeSound();
      return;
    }

    currentNode = nextNode;
    notifyListeners();
    _playNodeSound();
  }

  void restartGame() {
    points = 100;
    currentNode = _gameMap.getStartNode();
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
