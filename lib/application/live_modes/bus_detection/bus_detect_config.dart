import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

class BusDetectConfig extends Equatable {
  final CameraController controller;
  final String busUrl;
  const BusDetectConfig({
    required this.controller,
    required this.busUrl,
  });

  BusDetectConfig copyWith({
    CameraController? controller,
    String? busUrl,
  }) {
    return BusDetectConfig(
      controller: controller ?? this.controller,
      busUrl: busUrl ?? this.busUrl,
    );
  }

  @override
  String toString() =>
      'BusDetectConfig(controller: $controller, busUrl: $busUrl)';

  @override
  List<Object> get props => [controller, busUrl];
}
