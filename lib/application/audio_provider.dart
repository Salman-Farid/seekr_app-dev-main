import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:seekr_app/domain/i_audio_repo.dart';
import 'package:seekr_app/infrastructure/audio_repo.dart';

final audioRepoProvider = Provider<IAudioRepo>((ref) {
  final tts = FlutterTts();
  const backgroundChannel = MethodChannel('background_channel/ios');

  tts.setStartHandler(() async {
    Logger.i('TTS started');
    if (Platform.isIOS) {
      await backgroundChannel.invokeMethod('setAudioPlayingStatus', true);
    }
  });
  tts.setCompletionHandler(() {
    Logger.i('TTS completed');
    if (Platform.isIOS) {
      backgroundChannel.invokeMethod('setAudioPlayingStatus', false);
    }
  });
  tts.setErrorHandler((msg) {
    Logger.e('TTS error: $msg');
    if (Platform.isIOS) {
      backgroundChannel.invokeMethod('setAudioPlayingStatus', false);
    }
  });
  tts.setCancelHandler(() {
    Logger.i('TTS cancelled');
    if (Platform.isIOS) {
      backgroundChannel.invokeMethod('setAudioPlayingStatus', false);
    }
  });
  tts.setPauseHandler(() {
    Logger.i('TTS paused');
    if (Platform.isIOS) {
      backgroundChannel.invokeMethod('setAudioPlayingStatus', false);
    }
  });
  return AudioRepo(
    tts: tts,
  );
});

class TranslationArg extends Equatable {
  final String source;
  final bool shouldTranslate;

  const TranslationArg(this.source, this.shouldTranslate);

  @override
  List<Object> get props => [source, shouldTranslate];
}
