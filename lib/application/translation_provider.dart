import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/settings_provider.dart';

final translationProvider =
    AutoDisposeFutureProviderFamily<String, TranslationArg>((ref, arg) async {
  final localeRepo = await ref.watch(settingsRepoProvider.future);

  return localeRepo.translateTextHybrid(
      source: arg.source, shouldTranslate: arg.shouldTranslate);
});
