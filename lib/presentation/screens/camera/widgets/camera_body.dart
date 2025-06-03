import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/camera/camera_controller_provider.dart';
import 'package:seekr_app/application/settings_provider.dart';
import 'package:seekr_app/presentation/screens/camera/widgets/camera_buttons.dart';
import 'package:seekr_app/localization/localization_type.dart';

class CameraBody extends HookConsumerWidget {
  const CameraBody({super.key});

  @override
  Widget build(BuildContext context, ref) {
    useEffect(() {
      Future.microtask(() async {
        final settings = await ref.watch(settingsProvider.future);
        ref.read(audioRepoProvider).init(settings);
      });
      return null;
    }, []);
    final settingsState = ref.watch(settingsProvider);
    final controllerState = ref.watch(cameraControllerProvider);
    return controllerState.when(
        data: (controller) => controller != null
            ? settingsState.when(
                data: (settings) => Stack(
                      fit: StackFit.expand,
                      children: [
                        if (settings.cameraView)
                          FittedBox(
                            fit: BoxFit.contain,
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              width: controller.value.previewSize!.height,
                              height: controller.value.previewSize!.width,
                              child: CameraPreview(
                                controller,
                              ),
                            ),
                          ),
                        CameraButtons(
                          controller: controller,
                          cameraView: settings.cameraView,
                        )
                      ],
                    ),
                error: (error, _) => Center(
                      child: Text(error.toString()),
                    ),
                loading: () => const Center(child: CircularProgressIndicator()))
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
            ));
  }
}
