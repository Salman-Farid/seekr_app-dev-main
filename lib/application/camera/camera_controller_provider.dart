import 'package:camera/camera.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/camera/camera_provider.dart';

final cameraResolutionProvider = StateProvider<ResolutionPreset>((ref) {
  return ResolutionPreset.medium;
});

final cameraControllerProvider = FutureProvider<CameraController?>((ref) async {
  final state = await ref.watch(cameraProvider.future);

  final controller = state.cameras.isNotEmpty
      ? CameraController(
          state.cameras[state.selectedCameraIndex], ResolutionPreset.medium,
          enableAudio: false)
      : null;

  await controller?.initialize();
  return controller;
});

final textCameraControllerProvider =
    AutoDisposeFutureProvider<CameraController?>((ref) async {
  final state = await ref.watch(cameraProvider.future);

  final controller = state.cameras.isNotEmpty
      ? CameraController(
          state.cameras[state.selectedCameraIndex], ResolutionPreset.high,
          enableAudio: false)
      : null;

  await controller?.initialize();

  return controller;
});
