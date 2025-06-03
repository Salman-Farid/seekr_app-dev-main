import 'package:seekr_app/domain/settings/settings.dart';

abstract class IAudioRepo {
  Future<void> init(Settings settings);
  Future<void> playText({required String text});
  Future<void> stopTextToSpeech();
  Future<void> playBgMusic();
  Future<void> stopBgMusic();
  Future<void> pauseTts();
  Future<void> speakTts({required String text});
}
