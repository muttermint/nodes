import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;
  String? _currentSound;

  bool get soundEnabled => _soundEnabled;
  set soundEnabled(bool value) => _soundEnabled = value;

  Future<void> playSound(String soundFile) async {
    if (!_soundEnabled || soundFile.isEmpty) return;

    // Don't replay the same sound
    if (_currentSound == soundFile && _audioPlayer.playing) return;

    try {
      // Stop any currently playing sound
      await _audioPlayer.stop();

      _currentSound = soundFile;
      await _audioPlayer.setAsset('assets/sounds/$soundFile');
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing sound: $e');
      _currentSound = null;
    }
  }

  Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
      _currentSound = null;
    } catch (e) {
      print('Error stopping sound: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
