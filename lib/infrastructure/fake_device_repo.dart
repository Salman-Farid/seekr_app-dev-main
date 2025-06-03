import 'dart:async';
import 'dart:io';

import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seekr_app/application/device/mock_socket.dart';
import 'package:seekr_app/domain/device/device_action_type.dart';
import 'package:seekr_app/domain/device/device_info.dart';
import 'package:seekr_app/domain/device/i_device_repo.dart';

class FakeDeviceRepo extends IDeviceRepo {
  final StreamController<DeviceAction> controller;

  FakeDeviceRepo({required this.controller});
  @override
  Future<void> deleteAllPhotos() {
    return Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<int?> getBatteryStatus() {
    return Future.delayed(const Duration(seconds: 1), () => 100);
  }

  @override
  Future<DeviceInfo> getDeviceInfo() {
    return Future.delayed(const Duration(seconds: 1), () {
      return DeviceInfo.example();
    });
  }

  @override
  Future<File> getPhotoFromDevice() async {
    final path =
        '/data/user/0/com.vidilabs.seekr/cache/5aa57b3b-2f10-4860-9a85-92b7470e2cca/1000000018.jpg';
    Logger.i('Picked image: $path');
    final file = File(path);
    final newFile = await file.copy(
        '${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    return newFile;
    // final picker = ImagePicker();
    // return picker.pickImage(source: ImageSource.gallery).then((value) async {
    //   if (value != null) {
    //     Logger.i('Picked image: ${value.path}');
    //     final file = File(value.path);
    //     final newFile = await file.copy(
    //         '${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    //     return newFile;
    //   } else {
    //     throw Exception('No image selected');
    //   }
    // });
  }

  @override
  Future<void> initDevice() {
    return Future.delayed(const Duration(seconds: 1));
  }

  @override
  Stream<DeviceAction> listenButtonPresses(
      {required Socket socket, required bool isResumed}) {
    return controller.stream;
  }

  @override
  Future<void> setWifiName(String name) {
    return Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<Socket> socketConnect() {
    return Future.delayed(const Duration(seconds: 1), () {
      return MockSocket.connect('local', 123);
    });
  }

  @override
  Future<void> switchDeviceToPhotoMode() {
    return Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> switchDeviceToVideoMode() {
    return Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> switchToHighResMode() {
    return Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> switchToVGAResMode() {
    return Future.delayed(const Duration(seconds: 1));
  }
}
