import 'package:audio_plus/audio_plus.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:seekr_app/domain/i_audio_repo.dart';
import 'package:seekr_app/domain/settings/settings.dart';
import 'package:seekr_app/infrastructure/sharedpreferences_service.dart';

class AudioRepo extends IAudioRepo {
  final SharedPreferencesService sharedPreferencesService =
      SharedPreferencesService();

  @override
  Future<void> playBgMusic() async {
    await AudioPlus.play('assets/processing.mp3');
    await AudioPlus.isLooping(true);
    // await audioPlayer.play();
  }

  @override
  Future<void> stopBgMusic() async {
    await AudioPlus.stop();
  }

  @override
  Future<void> init(Settings settings) async {
    List<dynamic> languages = await tts.getLanguages;
    Logger.w(languages);
    Logger.i('initializing language: $settings');
    // await audioPlayer.setAsset('assets/processing.mp3');
    // audioPlayer.setVolume(1);
    final available = await tts.isLanguageAvailable(settings.ttsLangCode);
    Logger.i('langiage available for tts: $available');
    final result = await tts.setLanguage(settings.ttsLangCode);
    Logger.i('tts language result: $result');

    await tts.setPitch(settings.pitch.value());

    await tts.setSpeechRate(settings.speed.value());
    await tts.setVolume(1.0);
  }

  @override
  Future<void> playText({
    required String text,
  }) async {
    await AudioPlus.stop();
    await tts.stop();
    await tts.awaitSpeakCompletion(true);
    await tts.speak(text);
  }

  @override
  Future<void> stopTextToSpeech() => tts.stop();

  @override
  FlutterTts get tts => FlutterTts();
}
