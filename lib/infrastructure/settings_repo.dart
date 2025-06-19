import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:seekr_app/domain/settings/i_settings_repo.dart';
import 'package:seekr_app/domain/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator_plus/translator_plus.dart';

class SettingsRepo extends ISettingsRepo {
  final SharedPreferences _sharedPreferences;
  final GoogleTranslator translator = GoogleTranslator();

  SettingsRepo({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;
  @override
  Future<void> changeLocale(Locale locale) async {
    final languageCode = '${locale.languageCode}_${locale.countryCode}';
    if (Platform.isIOS) {
      const backgroundChannel = MethodChannel('background_channel/ios');
      await backgroundChannel.invokeMethod('setDeviceSettings', languageCode);
    }
    await _sharedPreferences.setString('locale', locale.toLanguageTag());
  }

  @override
  Future<void> changeLocaleInBackground(Locale locale) async {
    final languageCode = '${locale.languageCode}_${locale.countryCode}';
    if (Platform.isIOS) {
      const backgroundChannel = MethodChannel('background_channel/ios');
      await backgroundChannel.invokeMethod('setDeviceSettings', languageCode);
    }
  }

  @override
  Locale getDefaultLocale() {
    Locale defaultLocale = const Locale('en', 'US');
    final String defaultSystemLocale = Platform.localeName;

    List<String> localeParts = defaultSystemLocale.split('_');

    if (localeParts.length == 2) {
      String language = localeParts[0];
      String country = localeParts[1];
      Logger.i("Default__Language = $language");
      Logger.i("Default__Country = $country");

      if (language == 'en') {
        defaultLocale = const Locale('en', 'US');
      } else if (language == 'zh') {
        if (country == 'HK') {
          defaultLocale = const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'HK',
          );
        } else if (language == 'es') {
          defaultLocale = const Locale('es', 'ES');
        } else if (language == 'ja') {
          defaultLocale = const Locale('ja', 'JP');
        } else {
          defaultLocale = const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hans',
            countryCode: 'CN',
          );
        }
      }
    } else if (localeParts.length == 3) {
      String language = localeParts[0];
      String country = localeParts[2];
      Logger.i("Default__Language = $language");
      Logger.i("Default__Country = $country");
      if (language == 'en') {
        defaultLocale = const Locale('en', 'US');
      } else if (language == 'zh') {
        if (country == 'HK') {
          defaultLocale = const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'HK',
          );
        } else {
          defaultLocale = const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hans',
            countryCode: 'CN',
          );
        }
      }
    } else {
      Logger.i("Unexpected locale format: $defaultSystemLocale");
    }

    return defaultLocale;
  }

  @override
  Locale getCurrentLocale() {
    Locale defaultLocale = getDefaultLocale();

    final checkLanguageTag = _sharedPreferences.getString('locale');

    Logger.i("defaultLocal:_____::: $defaultLocale");

    Logger.i("sharedPreferences__local:_____::: $checkLanguageTag");

    final locales = getLocales();
    final savedLanguageTag =
        _sharedPreferences.getString('locale') ?? defaultLocale.toLanguageTag();
    final currentLocale = locales.firstWhere(
        (element) => element.toLanguageTag() == savedLanguageTag,
        orElse: () => locales.first);
    changeLocaleInBackground(currentLocale);
    return currentLocale;
  }

  @override
  List<Locale> getLocales() {
    const locales = [
      Locale('en', 'US'),
      Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
        countryCode: 'HK',
      ),
      Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
        countryCode: 'CN',
      ),
      // Locale.fromSubtags(languageCode: 'zh'),
      Locale('es', 'ES'), // Spanish
      Locale('ja', 'JP'), // Japanese
    ];
    return locales;
  }

  @override
  String getLanguageForLocale(Locale locale) {
    final locales = getLocales();

    if (locale == locales[0]) {
      return 'English';
    } else if (locale == locales[1]) {
      return '繁體';
    } else if (locale == locales[2]) {
      return '简体';
    } else if (locale == locales[3]) {
      return 'Español';
    } else if (locale == locales[4]) {
      return '日本語';
    } else {
      return '简体';
    }
  }

  String getTtsLangCode() {
    final langCode = getLangCodeForLocale();
    if (langCode.toLowerCase().contains('zh')) {
      final language = langCode == 'zh_HK' ? 'zh-HK' : 'zh-CN';
      return language;
    } else {
      return langCode.replaceAll('_', '-');
    }
  }

  @override
  List<Locale> geteSelectableLocales() => getLocales();

  @override
  String getLangCodeForLocale() {
    final locale = getCurrentLocale();
    return '${locale.languageCode}_${locale.countryCode}';
  }

  @override
  Future<String> translateText(
      {required String source, required bool shouldTranslate}) async {
    if (shouldTranslate) {
      final langCode = getLangCodeForLocale();
      if (langCode != 'en_US') {
        final language = langCode.toLowerCase().contains('zh')
            ? langCode == 'zh_HK'
                ? 'zh-tw'
                : 'zh-cn'
            : langCode.split('_').first.toLowerCase();
        Logger.i(
            'Translation language code: $language for langCode: $langCode');
        final translation = await translator.translate(source, to: language);
        return translation.text;
      }
      return source;
    }
    return source;
  }

  @override
  Settings getCurrentSettings() => Settings(
      speed: getVoiceSpeed(),
      pitch: getPitch(),
      locale: getCurrentLocale(),
      ttsLangCode: getTtsLangCode(),
      playBgMusic: getBgMusic(),
      cameraView: getCameraView(),
      enableTTs: getTTsStatus(),
      textScale: getTextScale(),
      repo: this);

  @override
  Pitch getPitch() {
    final pitchStr = _sharedPreferences.getString('pitch');

    return Pitch.values.firstWhere((element) => element.name == pitchStr,
        orElse: () => Pitch.normal);
  }

  @override
  VoiceSpeed getVoiceSpeed() {
    final speedStr = _sharedPreferences.getString('voice_speed');

    return VoiceSpeed.values.firstWhere((element) => element.name == speedStr,
        orElse: () => VoiceSpeed.normal);
  }

  @override
  Future<void> setPitch(Pitch pitch) async {
    await _sharedPreferences.setString('pitch', pitch.name);
  }

  @override
  Future<void> setVoiceSpeed(VoiceSpeed speed) async {
    await _sharedPreferences.setString('voice_speed', speed.name);
  }

  @override
  bool getBgMusic() {
    final bgMusic = _sharedPreferences.getBool('bg-music') ?? true;
    return bgMusic;
  }

  @override
  bool getTTsStatus() {
    final ttsPLayback = _sharedPreferences.getBool('tts-playback') ?? true;
    return ttsPLayback;
  }

  @override
  Future<void> setTTsStatus(bool value) =>
      _sharedPreferences.setBool('tts-playback', value);

  @override
  Future<void> setBgMusic(bool value) =>
      _sharedPreferences.setBool('bg-music', value);

  @override
  bool getCameraView() => _sharedPreferences.getBool('camera-view') ?? true;

  @override
  Future<void> setCameraView(bool value) =>
      _sharedPreferences.setBool('camera-view', value);

  @override
  String getLangCodeForOcr() {
    final locale = getCurrentLocale();
    return locale.languageCode != 'zh'
        ? locale.languageCode
        : '${locale.languageCode}-${locale.scriptCode}';
  }

  @override
  double getTextScale() => _sharedPreferences.getDouble('text-scale') ?? 1;

  @override
  Future<void> setTextScale(double value) =>
      _sharedPreferences.setDouble('text-scale', value);
}
