import 'package:flutter_tts/flutter_tts.dart';
import 'package:seekr_app/domain/settings/settings.dart';

abstract class IAudioRepo {
  FlutterTts get tts;
  Future<void> init(Settings settings);
  Future<void> playText({required String text});
  Future<void> stopTextToSpeech();
  Future<void> playBgMusic();
  Future<void> stopBgMusic();
}
