import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;
  set soundEnabled(bool value) => _soundEnabled = value;

  Future<void> playSound(String soundFile) async {
    if (!_soundEnabled || soundFile.isEmpty) return;

    try {
      await _audioPlayer.setAsset('assets/sounds/$soundFile');
      // Check if the audio player is already playing before playing again
      if (!_audioPlayer.playing) {
        await _audioPlayer.play();
      }
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
