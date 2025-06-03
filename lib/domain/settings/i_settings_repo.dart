import 'dart:ui';

import 'package:seekr_app/domain/settings/settings.dart';

abstract class ISettingsRepo {
  List<Locale> getLocales();
  List<Locale> geteSelectableLocales();

  Locale getCurrentLocale();
  Locale getDefaultLocale();
  Future<void> changeLocale(Locale locale);
  Future<void> changeLocaleInBackground(Locale locale);
  String getLanguageForLocale(Locale locale);
  String getLangCodeForLocale();
  String getLangCodeForOcr();

 Future<String> translateTextHybrid(
      {required String source, required bool shouldTranslate});

  Future<String> translateText(
      {required String source, required bool shouldTranslate});

  Future<String> translateTextWithDeepl(
      {required String source, required bool shouldTranslate});

  Pitch getPitch();
  VoiceSpeed getVoiceSpeed();
  Future<void> setPitch(Pitch pitch);
  Future<void> setVoiceSpeed(VoiceSpeed speed);

  Settings getCurrentSettings();

  bool getBgMusic();
  Future<void> setBgMusic(bool value);

  bool getTTsStatus();
  Future<void> setTTsStatus(bool value);

  bool getCameraView();
  Future<void> setCameraView(bool value);

  double getTextScale();
  Future<void> setTextScale(double value);
}
