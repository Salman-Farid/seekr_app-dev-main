import 'dart:async';

import 'package:camera/camera.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/camera/camera_state.dart';

final cameraProvider =
    AsyncNotifierProvider<CameraNotifier, CameraState>(CameraNotifier.new);

class CameraNotifier extends AsyncNotifier<CameraState> {
  @override
  FutureOr<CameraState> build() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('No cameras available');
    }
    return CameraState(
      cameras: cameras.lock,
      selectedCameraIndex: 0,
    );
  }

  void selectCamera(int index) {
    state = state.map(
      data: (data) =>
          AsyncData(data.value.copyWith(selectedCameraIndex: index)),
      error: (error) => error,
      loading: (loading) => loading,
    );
  }
}
