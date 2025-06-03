import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/camera/camera_controller_provider.dart';
import 'package:seekr_app/application/settings_provider.dart';
import 'package:seekr_app/domain/image_process/image_process_data.dart';
import 'package:seekr_app/domain/image_process/image_process_page_param.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/screens/camera/image_process_page.dart';

class MuseumProcessingPage extends HookConsumerWidget {
  static const routePath = '/museum-processing';
  static const routeName = 'museum-processing';
  const MuseumProcessingPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final settingsState = ref.watch(settingsProvider).requireValue;
    final controller = ref.watch(cameraControllerProvider).requireValue!;
    final isCameraBusy = useState(false);

    return Scaffold(
      body: Column(
        mainAxisAlignment: settingsState.cameraView
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: double.infinity,
            child: Semantics(
              sortKey: const OrdinalSortKey(2),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      backgroundColor: Colors.blue.shade200,
                      shape: const RoundedRectangleBorder(),
                      foregroundColor: Colors.white,
                      textStyle:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                  onPressed: () {
                    context.pop();
                  },
                  child: Text(Words.of(context)!.goBack)),
            ),
          ),
          if (settingsState.cameraView)
            Expanded(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(
                  controller,
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: Semantics(
              sortKey: const OrdinalSortKey(2),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      backgroundColor: Colors.green.shade200,
                      shape: const RoundedRectangleBorder(),
                      foregroundColor: Colors.white,
                      textStyle:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                  onPressed: () async {
                    if (!isCameraBusy.value) {
                      isCameraBusy.value = true;
                      final image = await controller.takePicture();

                      if (context.mounted) {
                        context.push(ImageProcessPage.routePath,
                            extra: ImageProcessPageParam(
                              imagePath: image.path,
                              processType: ProcessType.museum,
                            ));
                      }
                      isCameraBusy.value = false;
                    }
                  },
                  child: Text(Words.of(context)!.takeAPicture)),
            ),
          ),
        ],
      ),
    );
  }
}
