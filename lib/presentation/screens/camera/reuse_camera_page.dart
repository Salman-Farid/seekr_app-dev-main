import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/camera/camera_controller_provider.dart';
import 'package:seekr_app/application/settings_provider.dart';
import 'package:seekr_app/domain/image_process/image_process_data.dart';
import 'package:seekr_app/domain/image_process/image_process_page_param.dart';
import 'package:seekr_app/localization/localization_type.dart';

import 'image_process_page.dart';

class ReuseCameraPage extends HookConsumerWidget {
  static const routeName = 'reuse-camera';
  static const routePath = '/reuse-camera';
  final ProcessType processType;
  const ReuseCameraPage(this.processType, {super.key});

  @override
  Widget build(BuildContext context, ref) {
    final controllerState = ref.watch(cameraControllerProvider);

    useEffect(() {
      ref.read(audioRepoProvider).stopTextToSpeech();
      return null;
    });

    return Scaffold(
        body: controllerState.when(
            data: (controller) => controller != null
                ? ref.watch(settingsProvider).when(
                    data: (settings) => Stack(
                          fit: StackFit.expand,
                          children: [
                            if (settings.cameraView)
                              FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: controller.value.previewSize!.height,
                                  height: controller.value.previewSize!.width,
                                  child: CameraPreview(
                                    controller,
                                  ),
                                ),
                              ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 30),
                                            backgroundColor:
                                                Colors.deepPurple.shade200,
                                            shape:
                                                const RoundedRectangleBorder(),
                                            foregroundColor: Colors.white,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                )),
                                        onPressed: () async {
                                          final image =
                                              await controller.takePicture();

                                          if (context.mounted) {
                                            context.replace(
                                                ImageProcessPage.routePath,
                                                extra: ImageProcessPageParam(
                                                  imagePath: image.path,
                                                  processType: processType,
                                                ));
                                          }
                                        },
                                        child: Text(
                                            Words.of(context)!.reuseFeature)),
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 30),
                                            backgroundColor:
                                                Colors.blue.shade200,
                                            shape:
                                                const RoundedRectangleBorder(),
                                            foregroundColor: Colors.white,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                )),
                                        onPressed: () {
                                          context.pop();
                                        },
                                        child: Text(Words.of(context)!.goBack)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                    error: (error, _) => Center(
                          child: Text(error.toString()),
                        ),
                    loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ))
                : Center(
                    child: Text(
                      Words.of(context)!.noCameraDetected,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
            error: (error, _) => Center(
                  child: Text(error.toString()),
                ),
            loading: () => const Center(
                  child: CircularProgressIndicator(),
                )));
  }
}
