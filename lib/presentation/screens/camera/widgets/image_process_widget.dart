import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/image_process_provider.dart';
import 'package:seekr_app/application/settings_provider.dart';
import 'package:seekr_app/application/translation_provider.dart';
import 'package:seekr_app/domain/image_process/image_process_data.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/screens/camera/widgets/result_text_widget.dart';

class ImageProcessWidget extends HookConsumerWidget {
  final ImageProcessData data;
  final bool fromDevice;
  const ImageProcessWidget(
      {super.key, required this.data, this.fromDevice = false});

  @override
  Widget build(BuildContext context, ref) {
    final provider = imageProcessProvider(data);
    final shouldTranslate = !(data.processType == ProcessType.text &&
        !(data.processType == ProcessType.museum &&
            (data.languageCode == 'zh_CN' ||
                data.languageCode == 'en_US' ||
                data.languageCode == 'zh_HK')));
    final enableTTs = ref.watch(settingsProvider).requireValue.enableTTs;
    final accessibleNavigation = MediaQuery.of(context).accessibleNavigation;

    ref.listen(provider, (previous, next) async {
      if (!next.isLoading) {
        Logger.i("stop bg");
        ref.read(audioRepoProvider).stopBgMusic();
        if (enableTTs && next.hasValue) {
          if (next.value == 'SERVER_BUSY') {
            ref
                .read(audioRepoProvider)
                .playText(text: Words.of(context)!.serverBusy);
          } else {
            Logger.i("translating text");
            final translatedText = await ref.watch(translationProvider(
                    TranslationArg(next.value!, shouldTranslate))
                .future);
            Logger.i("playing tts");
            if (accessibleNavigation) {
              SemanticsService.announce(
                translatedText,
                TextDirection.ltr,
              );
            } else if (enableTTs) {
              ref.read(audioRepoProvider).playText(text: translatedText);
            }
          }
        }
      }
    });

    return ref.watch(provider).when(
        data: (text) {
          if (text == 'SERVER_BUSY') {
            final translatedText = Words.of(context)!.serverBusy;
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Semantics(
                        label: translatedText,
                        sortKey: const OrdinalSortKey(1),
                        child: ResultTextWidget(
                          data: data,
                          fromDevice: fromDevice,
                          translatedText: translatedText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return ref
                .watch(
                    translationProvider(TranslationArg(text, shouldTranslate)))
                .when(
                    data: (translatedText) => SafeArea(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ResultTextWidget(
                                    data: data,
                                    fromDevice: fromDevice,
                                    translatedText: translatedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    error: (error, _) => Text(
                          error.toString(),
                          style: const TextStyle(color: Colors.red),
                        ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()));
          }
        },
        error: (error, _) => Center(
              child: Text(
                'Image process error: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
        loading: () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  Text(Words.of(context)!.processingImage)
                ],
              ),
            ));
  }
}
