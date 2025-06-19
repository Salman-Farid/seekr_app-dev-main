import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/image_process_provider.dart';
import 'package:seekr_app/application/settings_provider.dart';
import 'package:seekr_app/domain/image_process/image_process_data.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/screens/camera/widgets/image_process_widget.dart';

class DeviceImageProcessWidget extends HookConsumerWidget {
  final String imagePath;
  final ProcessType processType;
  const DeviceImageProcessWidget(
      {super.key, required this.imagePath, required this.processType});

  @override
  Widget build(BuildContext context, ref) {
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
        ref.watch(settingsProvider.future).then((value) async {
          if (value.playBgMusic) {
            await ref.read(audioRepoProvider).stopBgMusic();
            await ref.read(audioRepoProvider).stopTextToSpeech();

            ref.read(audioRepoProvider).playBgMusic();
          }
        });
      });

      return null;
    }, []);
    return PopScope(
      onPopInvokedWithResult: (v, _) =>
          ref.read(audioRepoProvider).stopBgMusic(),
      child: ref.watch(imageCompressProvider(imagePath)).when(
          data: (data) => ImageProcessWidget(
              fromDevice: true,
              data: ImageProcessData(
                image: data,
                processType: processType,
              )),
          error: (error, _) => Text(
                'Image compress error: $error',
                style: const TextStyle(color: Colors.red),
              ),
          loading: () => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    Text(Words.of(context)!.compressingImage)
                  ],
                ),
              )),
    );
  }
}
