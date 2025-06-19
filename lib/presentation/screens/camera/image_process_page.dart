import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/image_process_provider.dart';
import 'package:seekr_app/application/settings_provider.dart';
import 'package:seekr_app/application/talker_provider.dart';
import 'package:seekr_app/domain/image_process/image_process_data.dart';
import 'package:seekr_app/domain/image_process/image_process_page_param.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/screens/camera/widgets/image_process_widget.dart';

class ImageProcessPage extends HookConsumerWidget {
  static const routeName = 'image-process';
  static const routePath = '/image-process';

  final ImageProcessPageParam param;
  const ImageProcessPage({
    super.key,
    required this.param,
  });

  @override
  Widget build(BuildContext context, ref) {
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
        ref.watch(settingsProvider.future).then((value) {
          if (value.playBgMusic) {
            Logger.i("playing bg");
            ref.read(audioRepoProvider).playBgMusic();

            ref.read(eventLogFuncProvider(param.processType)).call();
          }
        });
      });

      return null;
    }, []);
    return PopScope(
      onPopInvokedWithResult: (v, _) =>
          ref.read(audioRepoProvider).stopBgMusic(),
      child: Scaffold(
        body: ref.watch(imageCompressProvider(param.imagePath)).when(
            data: (data) => ImageProcessWidget(
                    data: ImageProcessData(
                  image: data,
                  processType: param.processType,
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
      ),
    );
  }
}
