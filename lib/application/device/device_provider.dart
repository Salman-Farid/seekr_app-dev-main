import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/background_state_provider.dart';
import 'package:seekr_app/application/device/device_state.dart';
import 'package:seekr_app/application/device/socket_provider.dart';
import 'package:seekr_app/application/device_dio_provider.dart';
import 'package:seekr_app/domain/device/device_action_type.dart';
import 'package:seekr_app/domain/device/i_device_repo.dart';
import 'package:seekr_app/infrastructure/device_repo.dart';
import 'package:seekr_app/infrastructure/fake_device_repo.dart';
import 'package:seekr_app/main.dart';

final showDevImageProcessProvider = AutoDisposeStateProvider<bool>((ref) {
  return false;
});

final deviceRepoProvider = Provider<IDeviceRepo>((ref) {
  if (useFakeDevice) {
    return FakeDeviceRepo(
      controller: ref.read(fakeDeviceEventStreamControllerProvider),
    );
  } else {
    return DeviceRepo(dio: ref.read(deviceDioProvider));
  }
});

final deviceBatteryStatusProvider = FutureProvider<int?>((ref) async {
  final IDeviceRepo deviceRepo = ref.read(deviceRepoProvider);
  return deviceRepo.getBatteryStatus();
});
final fakeDeviceEventStreamControllerProvider =
    Provider<StreamController<DeviceAction>>((ref) {
  final controller = StreamController<DeviceAction>.broadcast();
  ref.onDispose(() => controller.close());
  return controller;
});

final deviceEventStreamProvider =
    AutoDisposeStreamProvider<DeviceAction>((ref) {
  final socket = ref.watch(socketProvider).requireValue;
  return ref.read(deviceRepoProvider).listenButtonPresses(
      socket: socket,
      isResumed: ref.watch(appStateProvider
          .select((value) => value == AppLifecycleState.resumed)));
});

final ensureDeviceCameraModeProvider = FutureProvider<void>((ref) async {
  Logger.i('Switching device to photo mode');
  return ref.read(deviceRepoProvider).initDevice();
});

final devicePhotoProvider = AutoDisposeFutureProvider<File>((ref) async {
  return ref.read(deviceRepoProvider).getPhotoFromDevice();
});

final deviceConnectedProvider = Provider<bool>((ref) {
  return ref.watch(deviceStateProvider.select((p) => p is ConnectedState));
});

final deviceStateProvider =
    NotifierProvider<DeviceNotifier, DeviceState>(DeviceNotifier.new);

class DeviceNotifier extends Notifier<DeviceState> {
  @override
  DeviceState build() {
    init();

    return UncheckedState();
  }

  void init() async {
    final IDeviceRepo deviceRepo = ref.read(deviceRepoProvider);
    final deviceInfo = await deviceRepo.getDeviceInfo();
    state = ConnectedState(deviceInfo: deviceInfo);
    if (state is ConnectedState) {
      final timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        final bool isResumed = ref.watch(appStateProvider
            .select((value) => value == AppLifecycleState.resumed));

        if (isResumed) {
          try {
            final deviceInfo = await deviceRepo.getDeviceInfo();

            state = ConnectedState(deviceInfo: deviceInfo);
          } on DioException catch (e) {
            switch (e.type) {
              case DioExceptionType.connectionTimeout:
                state = DisconnectedState();
              case DioExceptionType.sendTimeout:
                state = DisconnectedState();
              default:
                state = ErrorState(error: e.error.toString());
            }
          } catch (e) {
            state = ErrorState(error: e.toString());
          }
        } else {
          state = DisconnectedState();
        }
      });
      ref.onDispose(() => timer.cancel());
    }
  }

  Future<void> checkManually() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      Logger.i('Checking device connectivity');
      final deviceInfo = await ref.read(deviceRepoProvider).getDeviceInfo();
      Logger.i('Device info while checking connectivity: $deviceInfo');
      state = ConnectedState(deviceInfo: deviceInfo);
    } catch (e) {
      Logger.e('Error checking device connectivity: $e');
      if (state is ConnectedState) {
        state = DisconnectedState();
      }
    }
  }
}
