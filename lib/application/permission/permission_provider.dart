import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seekr_app/application/permission/permission_state.dart';
import 'package:seekr_app/application/shared_pref_provider.dart';

final permissionProvider =
    AsyncNotifierProvider<PermissionNotifier, PermissionData>(
        PermissionNotifier.new);

class PermissionNotifier extends AsyncNotifier<PermissionData> {
  @override
  FutureOr<PermissionData> build() async {
    if (Platform.isIOS) {
      try {
        var deviceIp = await NetworkInfo().getWifiIP();

        Duration? timeOutDuration = const Duration(milliseconds: 100);
        await Socket.connect(deviceIp, 80, timeout: timeOutDuration);
      } catch (e) {
        Logger.e(e);
      }
    }
    final pref = await ref.read(sharedPreferecesProvider.future);
    // final a = await Permission.camera.status;
    // final b = await Permission.microphone.status;
    // final c = await Permission.manageExternalStorage.status;
    // final d = await Permission.location.status;
    // Logger.d({"a": a, "b": b, "c": c, "d": d});
    final deniedLocation = pref.getBool(PermissionStorageKeys.location);
    final deniedCamera = pref.getBool(PermissionStorageKeys.camera);
    final deniedMic = pref.getBool(PermissionStorageKeys.microphone);
    final deniedStorage = pref.getBool(PermissionStorageKeys.storage);

    final state = PermissionData(
      cameraPerission: await Permission.camera.status.isGranted
          ? PermissionResult.accepted
          : deniedCamera == true
              ? PermissionResult.denied
              : PermissionResult.pending,
      microphonePermission: await Permission.microphone.status.isGranted
          ? PermissionResult.accepted
          : deniedMic == true
              ? PermissionResult.denied
              : PermissionResult.pending,
      storagePermission: (Platform.isIOS ||
              await Permission.manageExternalStorage.status.isGranted)
          ? PermissionResult.accepted
          : deniedStorage == true
              ? PermissionResult.denied
              : PermissionResult.pending,
      locationPermission: await Permission.location.status.isGranted
          ? PermissionResult.accepted
          : deniedLocation == true
              ? PermissionResult.denied
              : PermissionResult.pending,
    );
    return state;
  }

  Future<void> updateState() async {
    final pref = await ref.read(sharedPreferecesProvider.future);
    final deniedLocation = pref.getBool(PermissionStorageKeys.location);
    final deniedCamera = pref.getBool(PermissionStorageKeys.camera);
    final deniedMic = pref.getBool(PermissionStorageKeys.microphone);
    final deniedStorage = pref.getBool(PermissionStorageKeys.storage);
    final data = PermissionData(
      cameraPerission: await Permission.camera.status.isGranted
          ? PermissionResult.accepted
          : deniedCamera == true
              ? PermissionResult.denied
              : PermissionResult.pending,
      microphonePermission: await Permission.microphone.status.isGranted
          ? PermissionResult.accepted
          : deniedMic == true
              ? PermissionResult.denied
              : PermissionResult.pending,
      storagePermission: (Platform.isIOS ||
              await Permission.manageExternalStorage.status.isGranted)
          ? PermissionResult.accepted
          : deniedStorage == true
              ? PermissionResult.denied
              : PermissionResult.pending,
      locationPermission: await Permission.location.status.isGranted
          ? PermissionResult.accepted
          : deniedLocation == true
              ? PermissionResult.denied
              : PermissionResult.pending,
    );

    state = AsyncData(data);
  }

  Future<void> askForCameraPermission() async {
    final pref = await ref.read(sharedPreferecesProvider.future);

    PermissionStatus cameraPermissionStatus = await Permission.camera.request();
    if (cameraPermissionStatus == PermissionStatus.granted) {
      await updateState();
    } else {
      await pref.setBool(PermissionStorageKeys.camera, true);

      // Logger.i('opening settings');
      // await openAppSettings();
      await updateState();
    }
  }

  Future<void> forceAskForCameraPermission() async {
    final pref = await ref.read(sharedPreferecesProvider.future);

    PermissionStatus cameraPermissionStatus = await Permission.camera.request();
    if (cameraPermissionStatus == PermissionStatus.granted) {
      await updateState();
    } else {
      // Logger.i('opening settings');
      await openAppSettings();
      final granted = await Permission.camera.isGranted;
      if (granted) {
        await pref.setBool(PermissionStorageKeys.camera, false);
        await updateState();
      }
    }
  }

  Future<void> forceAskForLocationPermission() async {
    final pref = await ref.read(sharedPreferecesProvider.future);

    final PermissionStatus locationPermissionStatus =
        await Permission.location.request();
    if (locationPermissionStatus == PermissionStatus.granted) {
      await updateState();
    } else {
      await openAppSettings();
      final granted = await Permission.location.isGranted;
      if (granted) {
        await pref.setBool(PermissionStorageKeys.location, false);
        await updateState();
      }
    }
  }

  Future<void> askForMicrophonePermission() async {
    final pref = await ref.read(sharedPreferecesProvider.future);
    PermissionStatus microphonePermissionStatus =
        await Permission.microphone.request();
    if (microphonePermissionStatus == PermissionStatus.granted) {
      await updateState();
    } else {
      await pref.setBool(PermissionStorageKeys.microphone, true);
      // Logger.i('opening settings');
      // await openAppSettings();
      await updateState();
    }
  }

  Future<void> askForLocationPermission() async {
    final pref = await ref.read(sharedPreferecesProvider.future);
    Logger.i(await Permission.location.status);
    PermissionStatus locationPermissionStatus =
        await Permission.location.request();
    Logger.i('done $locationPermissionStatus');
    if (locationPermissionStatus == PermissionStatus.granted) {
      await updateState();
    } else {
      await pref.setBool(PermissionStorageKeys.location, true);
      // Logger.i('opening settings');
      // await openAppSettings();
      await updateState();
    }
  }

  Future<void> askForStoragePermission() async {
    if (!Platform.isIOS) {
      final pref = await ref.read(sharedPreferecesProvider.future);

      final AndroidDeviceInfo androidInfo =
          await DeviceInfoPlugin().androidInfo;
      int sdkInt = androidInfo.version.sdkInt;
      Logger.i('Android SDK version: $sdkInt');
      final isAndroidVersionGreaterThan10 = sdkInt > 29;

      PermissionStatus storagePermissionStatus = isAndroidVersionGreaterThan10
          ? await Permission.manageExternalStorage.request()
          : await Permission.storage.request();
      if (storagePermissionStatus == PermissionStatus.granted) {
        Logger.i('done');
        await updateState();
      } else {
        await pref.setBool(PermissionStorageKeys.storage, true);
        // Logger.i('opening settings');
        // await openAppSettings();
        await updateState();
      }
    }
  }
}
