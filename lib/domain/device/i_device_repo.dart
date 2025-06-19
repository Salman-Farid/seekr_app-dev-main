import 'dart:io';

import 'package:seekr_app/domain/device/device_action_type.dart';
import 'package:seekr_app/domain/device/device_info.dart';

abstract class IDeviceRepo {
  Future<Socket> socketConnect();
  Stream<DeviceAction> listenButtonPresses(
      {required Socket socket, required bool isResumed});
  Future<DeviceInfo> getDeviceInfo();
  Future<void> switchDeviceToPhotoMode();
  Future<void> switchDeviceToVideoMode();
  Future<void> initDevice();

  Future<File> getPhotoFromDevice();
  Future<File> getPhotoFromFakeDevice();

  Future<void> deleteAllPhotos();
  Future<void> setWifiName(String name);

  Future<int?> getBatteryStatus();

  Future<void> switchToHighResMode();
  Future<void> switchToVGAResMode();
}
