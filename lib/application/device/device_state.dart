import 'package:equatable/equatable.dart';

import 'package:seekr_app/domain/device/device_info.dart';

sealed class DeviceState {
  bool get isFake => this == ConnectedState(deviceInfo: DeviceInfo.example());
}

class UncheckedState extends DeviceState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ConnectedState extends DeviceState with EquatableMixin {
  final DeviceInfo deviceInfo;

  ConnectedState({
    required this.deviceInfo,
  });

  @override
  List<Object> get props => [deviceInfo];

  ConnectedState copyWith({
    DeviceInfo? deviceInfo,
  }) {
    return ConnectedState(
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  @override
  String toString() => 'ConnectedState(deviceInfo: $deviceInfo)';
}

class DisconnectedState extends DeviceState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ErrorState extends DeviceState with EquatableMixin {
  final String error;

  ErrorState({
    required this.error,
  });

  @override
  List<Object> get props => [error];

  ErrorState copyWith({
    String? error,
  }) {
    return ErrorState(
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'error': error,
    };
  }

  factory ErrorState.fromMap(Map<String, dynamic> map) {
    return ErrorState(
      error: map['error'] ?? '',
    );
  }

  @override
  String toString() => 'ErrorState(error: $error)';
}
