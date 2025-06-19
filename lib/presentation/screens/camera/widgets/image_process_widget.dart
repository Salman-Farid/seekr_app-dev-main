import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/device/device_provider.dart';
import 'package:seekr_app/application/image_process_provider.dart';
import 'package:seekr_app/application/settings_provider.dart';
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

    ref.listen(provider, (previous, next) {
      if (!next.isLoading) {
        Logger.i("stop bg");
        ref.read(audioRepoProvider).stopBgMusic();
      }
    });

    return ref.watch(provider).when(
        data: (text) => ref
            .watch(translationProvider(
                TranslationArg(text, data.processType != ProcessType.text)))
            .when(
                data: (translatedText) => SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Semantics(
                                sortKey: const OrdinalSortKey(2),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 30),
                                        backgroundColor: Colors.blue.shade200,
                                        shape: const RoundedRectangleBorder(),
                                        foregroundColor: Colors.white,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            )),
                                    onPressed: () {
                                      if (fromDevice) {
                                        ref
                                            .read(showDevImageProcessProvider
                                                .notifier)
                                            .state = false;
                                      } else {
                                        context.pop();
                                      }
                                    },
                                    child: Text(Words.of(context)!.goBack)),
                              ),
                            ),
                            Expanded(
                              child: Semantics(
                                label: translatedText,
                                sortKey: const OrdinalSortKey(1),
                                child: ResultTextWidget(
                                    fromDevice: fromDevice,
                                    translatedText: translatedText,
                                    type: data.processType),
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
                    const Center(child: CircularProgressIndicator())),
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
