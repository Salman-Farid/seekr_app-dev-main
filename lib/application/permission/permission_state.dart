import 'dart:io';

import 'package:equatable/equatable.dart';

enum PermissionResult { accepted, denied, pending }

class PermissionData extends Equatable {
  final PermissionResult cameraPerission;
  final PermissionResult microphonePermission;
  final PermissionResult storagePermission;
  final PermissionResult locationPermission;
  const PermissionData({
    required this.cameraPerission,
    required this.microphonePermission,
    required this.storagePermission,
    required this.locationPermission,
  });

  PermissionData copyWith({
    PermissionResult? cameraPerission,
    PermissionResult? microphonePermission,
    PermissionResult? storagePermission,
    PermissionResult? locationPermission,
  }) {
    return PermissionData(
      cameraPerission: cameraPerission ?? this.cameraPerission,
      microphonePermission: microphonePermission ?? this.microphonePermission,
      storagePermission: storagePermission ?? this.storagePermission,
      locationPermission: locationPermission ?? this.locationPermission,
    );
  }

  bool get hasAllPermission =>
      cameraPerission != PermissionResult.pending &&
      microphonePermission != PermissionResult.pending &&
      (Platform.isIOS || storagePermission != PermissionResult.pending) &&
      locationPermission != PermissionResult.pending;

  @override
  String toString() {
    return 'PermissionData(cameraPerission: $cameraPerission, microphonePermission: $microphonePermission, storagePermission: $storagePermission, locationPermission: $locationPermission)';
  }

  @override
  List<Object> get props => [
        cameraPerission,
        microphonePermission,
        storagePermission,
        locationPermission
      ];
}

class PermissionStorageKeys {
  PermissionStorageKeys._();
  static String camera = 'denied_camera_permission';
  static String location = 'denied_location_permission';
  static String storage = 'denied_storage_permission';
  static String microphone = 'denied_microphone_permission';
}
