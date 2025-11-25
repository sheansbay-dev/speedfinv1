// /speedfin/lib/core/services/audio_service.dart

import 'package:just_audio/just_audio.dart';
import 'package:speedfin/utils/app_logger.dart';

class AudioService {
  final _player = AudioPlayer();
  // ශ්‍රව්‍ය ගොනුවේ Path එක
  static const String _alertPath = 'assets/audio/warning.mp3';

  // AudioPlayer instance එක මුලින්ම load කිරීම
  Future<void> init() async {
    try {
      await _player.setAsset(_alertPath);
      logger.i('AudioService: Alert sound loaded successfully.');
    } catch (e) {
      logger.e('AudioService: Error loading audio asset: $e');
    }
  }

  // අනතුරු ඇඟවීමේ ශබ්දය ධාවනය කිරීම
  Future<void> playAlert() async {
    try {
      // ශබ්දය දැනටමත් වාදනය වන්නේ නම්, එය නවතා නැවත ආරම්භ කරන්න
      if (_player.playing) {
        await _player.stop();
      }
      await _player.seek(Duration.zero); // ශබ්දය ආරම්භයේ සිට නැවත වාදනයට
      await _player.play();
    } catch (e) {
      logger.e('AudioService: Error playing audio: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
