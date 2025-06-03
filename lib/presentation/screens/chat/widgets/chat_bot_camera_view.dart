import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/camera/camera_controller_provider.dart';
import 'package:seekr_app/application/image_process_provider.dart';
import 'package:seekr_app/application/permission/permission_provider.dart';
import 'package:seekr_app/application/permission/permission_state.dart';
import 'package:seekr_app/application/settings_provider.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/screens/camera/widgets/no_camera_permission_view.dart';

class ChatBotCameraView extends HookConsumerWidget {
  const ChatBotCameraView({
    super.key,
    required this.onImageSelected,
  });

  final void Function(Uint8List) onImageSelected;

  @override
  Widget build(BuildContext context, ref) {
    final permission =
        ref.watch(permissionProvider).requireValue.cameraPerission;
    final settingsState = ref.watch(settingsProvider);
    final controllerState = ref.watch(cameraControllerProvider);

    switch (permission) {
      case PermissionResult.accepted:
        return controllerState.when(
            data: (controller) => controller != null
                ? settingsState.when(
                    data: (settings) => Column(
                          mainAxisAlignment: settings.cameraView
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.center,
                          // fit: StackFit.expand,
                          // alignment: Alignment.center,
                          children: [
                            if (settings.cameraView)
                              CameraPreview(
                                controller,
                              ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 30),
                                      backgroundColor: Colors.green.shade300,
                                      shape: const RoundedRectangleBorder(),
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
                                    final compressedImage = await ref.read(
                                        imageCompressProvider(image.path)
                                            .future);
                                    onImageSelected(
                                        await compressedImage.readAsBytes());
                                  },
                                  child: Text('Take Picture')),
                            ),
                          ],
                        ),
                    error: (error, _) => Center(
                          child: Text(error.toString()),
                        ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()))
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
      default:
        return NoCameraPermissionView();
    }
  }
}
