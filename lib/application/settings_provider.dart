import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/shared_pref_provider.dart';
import 'package:seekr_app/domain/settings/i_settings_repo.dart';
import 'package:seekr_app/domain/settings/settings.dart';
import 'package:seekr_app/infrastructure/settings_repo.dart';

final localizationRepoProvider = FutureProvider<ISettingsRepo>((ref) async {
  final sharedPref = await ref.watch(sharedPreferecesProvider.future);
  return SettingsRepo(sharedPreferences: sharedPref);
});

final settingsProvider = AsyncNotifierProvider<LocalizationNotifier, Settings>(
    LocalizationNotifier.new);

class LocalizationNotifier extends AsyncNotifier<Settings> {
  @override
  FutureOr<Settings> build() async {
    if (!kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    }
    final localeRepo = await ref.watch(localizationRepoProvider.future);
    return localeRepo.getCurrentSettings();
  }

  Future<void> changeLocace(Locale locale) async {
    final localeRepo = await ref.watch(localizationRepoProvider.future);
    await localeRepo.changeLocale(locale);
    state = AsyncData(localeRepo.getCurrentSettings());
  }

  Future<void> changePitch(Pitch pitch) async {
    final localeRepo = await ref.watch(localizationRepoProvider.future);
    await localeRepo.setPitch(pitch);
    state = AsyncData(localeRepo.getCurrentSettings());
  }

  Future<void> changeVoiceSpeed(VoiceSpeed speed) async {
    final localeRepo = await ref.watch(localizationRepoProvider.future);
    await localeRepo.setVoiceSpeed(speed);
    if (Platform.isIOS) {
      const backgroundChannel = MethodChannel('background_channel/ios');
      await backgroundChannel.invokeMethod('setVoiceSpeed', speed.name);
    }
    state = AsyncData(localeRepo.getCurrentSettings());
  }

  Future<void> changeBgMusic(bool value) async {
    final localeRepo = await ref.watch(localizationRepoProvider.future);
    await localeRepo.setBgMusic(value);
    if (Platform.isIOS) {
      const backgroundChannel = MethodChannel('background_channel/ios');
      await backgroundChannel.invokeMethod('setProcessSound', value);
    }
    state = AsyncData(localeRepo.getCurrentSettings());
  }

  Future<void> changeTTsStatus(bool value) async {
    final localeRepo = await ref.watch(localizationRepoProvider.future);
    await localeRepo.setTTsStatus(value);
    state = AsyncData(localeRepo.getCurrentSettings());
  }

  Future<void> changeCameraView(bool value) async {
    final localeRepo = await ref.watch(localizationRepoProvider.future);
    await localeRepo.setCameraView(value);
    state = AsyncData(localeRepo.getCurrentSettings());
  }

  Future<void> changeTextScale(double value) async {
    final localeRepo = await ref.watch(localizationRepoProvider.future);
    await localeRepo.setTextScale(value);
    state = AsyncData(localeRepo.getCurrentSettings());
  }
}

final translationProvider =
    AutoDisposeFutureProviderFamily<String, TranslationArg>((ref, arg) async {
  final localeRepo = await ref.watch(localizationRepoProvider.future);

  return localeRepo.translateText(
      source: arg.source, shouldTranslate: arg.shouldTranslate);
});


// if (Platform.isIOS) {
//       const backgroundChannel = MethodChannel('background_channel/ios');
//       await _channel.invokeMethod('setUserId', userId); (this one is String)
//        await _channel.invokeMethod('setAccessToken', accessToken); (this one is String)
//        await _channel.invokeMethod('setSessionId', sessionId); (this one is String)
//        await _channel.invokeMethod('setUserDetails', userDetails); (This one will be dictonary)


//     }