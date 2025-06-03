import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

class CameraState extends Equatable {
  final IList<CameraDescription> cameras;
  final int selectedCameraIndex;

  const CameraState({required this.cameras, required this.selectedCameraIndex});

  @override
  List<Object> get props => [cameras, selectedCameraIndex];

  CameraState copyWith({
    IList<CameraDescription>? cameras,
    int? selectedCameraIndex,
  }) {
    return CameraState(
      cameras: cameras ?? this.cameras,
      selectedCameraIndex: selectedCameraIndex ?? this.selectedCameraIndex,
    );
  }
}
