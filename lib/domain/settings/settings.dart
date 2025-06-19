import 'dart:ui';

import 'package:equatable/equatable.dart';

import 'package:seekr_app/domain/settings/i_settings_repo.dart';
import 'package:seekr_app/localization/localization_type.dart';

enum Pitch { high, normal, low }

enum VoiceSpeed { fast, normal, slow }

extension CnvSpeed on VoiceSpeed {
  String label(Words words) {
    switch (this) {
      case VoiceSpeed.fast:
        return words.fast;
      case VoiceSpeed.normal:
        return words.normal;
      case VoiceSpeed.slow:
        return words.slow;
    }
  }

  double value() {
    switch (this) {
      case VoiceSpeed.fast:
        return 0.60;
      case VoiceSpeed.normal:
        return 0.45;
      case VoiceSpeed.slow:
        return 0.30;
    }
  }
}

extension CnvPitch on Pitch {
  String label() {
    switch (this) {
      case Pitch.high:
        return 'High - 高';
      case Pitch.normal:
        return 'Normal - 正常';
      case Pitch.low:
        return 'Low - 低';
    }
  }

  double value() {
    switch (this) {
      case Pitch.high:
        return 1.5;
      case Pitch.normal:
        return 1;
      case Pitch.low:
        return 0.5;
    }
  }
}

class Settings extends Equatable {
  final VoiceSpeed speed;
  final Pitch pitch;
  final Locale locale;
  final String ttsLangCode;
  final ISettingsRepo repo;
  final bool playBgMusic;
  final bool cameraView;
  final bool enableTTs;
  final double textScale;

  const Settings({
    required this.speed,
    required this.pitch,
    required this.locale,
    required this.ttsLangCode,
    required this.repo,
    required this.playBgMusic,
    required this.cameraView,
    required this.enableTTs,
    required this.textScale,
  });

  Settings copyWith({
    VoiceSpeed? speed,
    Pitch? pitch,
    Locale? locale,
    String? ttsLangCode,
    ISettingsRepo? repo,
    bool? playBgMusic,
    bool? cameraView,
    bool? enableTTs,
    double? textScale,
  }) {
    return Settings(
        speed: speed ?? this.speed,
        pitch: pitch ?? this.pitch,
        locale: locale ?? this.locale,
        ttsLangCode: ttsLangCode ?? this.ttsLangCode,
        repo: repo ?? this.repo,
        playBgMusic: playBgMusic ?? this.playBgMusic,
        enableTTs: enableTTs ?? this.enableTTs,
        textScale: textScale ?? this.textScale,
        cameraView: cameraView ?? this.cameraView);
  }

  @override
  String toString() {
    return 'Settings(speed: $speed, pitch: $pitch, locale: $locale, ttsLangCode: $ttsLangCode, repo: $repo, playBgMusic: $playBgMusic)';
  }

  @override
  List<Object> get props {
    return [
      speed,
      pitch,
      locale,
      ttsLangCode,
      repo,
      playBgMusic,
      cameraView,
      textScale,
      enableTTs
    ];
  }
}
