import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seekr_app/domain/device/device_action_type.dart';
import 'package:seekr_app/domain/device/device_info.dart';
import 'package:seekr_app/domain/device/i_device_repo.dart';
import 'package:xml/xml.dart';

class DeviceRepo extends IDeviceRepo {
  final Dio dio;

  DeviceRepo({required this.dio});

  @override
  Future<File> getPhotoFromDevice() async {
    await Future.delayed(const Duration(seconds: 1));
    final client = Client();
    final response = await dio.get('/DCIM/Photo');
    final document = parse(response.data);
    final elements = document.getElementsByTagName('b');
    final fileName = elements.last.text;
    Logger.i(elements.map((e) => e.text).join(',\n'));
    Logger.w(fileName);
    final downloadResponse = await client
        .get(Uri.parse('http://192.168.1.254/DCIM/Photo/$fileName'));
    final fileNameWithoutExt = fileName.split('.').first;
    final path =
        "${(await getTemporaryDirectory()).path}/$fileNameWithoutExt.jpg";

    final File file = File(path);
    final raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(downloadResponse.bodyBytes);
    await raf.close();

    client.close();
    await dio.get('/DCIM/Photo/$fileName?del=1');
    return file;
  }

  @override
  Stream<DeviceAction> listenButtonPresses(
          {required Socket socket, required bool isResumed}) =>
      socket.map((event) {
        final time = DateTime.now();
        if (isResumed) {
          String newEvent = utf8.decode(event);
          final doc = XmlDocument.parse(newEvent);
          final deviceCommand = DeviceActionObject.fromXml(doc);
          Logger.i(deviceCommand);

          if (deviceCommand.status == 1003) {
            return DeviceAction(
                action: DeviceActionType.switchToPreviousMode, time: time);
          } else if (deviceCommand.status == 1005) {
            return DeviceAction(
                action: DeviceActionType.switchToNextMode, time: time);
          } else if (deviceCommand.cmd == 3020 &&
              deviceCommand.status == 1001) {
            return DeviceAction(
                action: DeviceActionType.capturePhoto, time: time);
          } else if (deviceCommand.cmd == 3020 &&
              deviceCommand.status == 1006) {
            return DeviceAction(action: DeviceActionType.longPress, time: time);
          } else {
            return DeviceAction(action: DeviceActionType.idle, time: time);
          }
        } else {
          return DeviceAction(action: DeviceActionType.idle, time: time);
        }
      });

  @override
  Future<Socket> socketConnect() async {
    final socket = await Socket.connect('192.168.1.254', 3333);
    return socket;
  }

  @override
  Future<void> switchDeviceToPhotoMode() async {
    await dio.get('/?custom=1&cmd=3001&par=0');
  }

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    final response = await dio.get('/?custom=1&cmd=3012');
    final document = XmlDocument.parse(response.data);
    final functionElement = document.findAllElements('Function').first;

    final brand =
        functionElement.findAllElements('String').elementAt(4).innerText;
    final model =
        functionElement.findAllElements('String').elementAt(1).innerText;
    final version =
        functionElement.findAllElements('String').elementAt(2).innerText;
    return DeviceInfo(brand: brand, model: model, version: version);
  }

  @override
  Future<void> deleteAllPhotos() async {
    Logger.i('Deleting all photos');
    final response = await dio.get('/DCIM/Photo');
    final document = parse(response.data);
    final elements = document.getElementsByTagName('b');
    final fileNames = elements.map((e) => e.text).toList();
    for (final fileName in fileNames) {
      await dio.get('/DCIM/Photo/$fileName?del=1');
    }
  }

  @override
  Future<void> initDevice() async {
    final response = await dio.get('/?custom=1&cmd=3016');

    final document = XmlDocument.parse(response.data);
    final functionElement = document.findAllElements('Function').first;

    final status = functionElement.getElement('Status')?.innerText;
    final statusCode = int.parse(status!);
    if (statusCode == 1) {
      await switchDeviceToPhotoMode();
    }
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm:ss').format(now);
    Logger.i(timeStr);
    await dio.get(
        '/?custom=1&cmd=3005&str=${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}');
    await dio.get('/?custom=1&cmd=3006&str=$timeStr');
  }

  @override
  Future<void> switchDeviceToVideoMode() async {
    await dio.get('/?custom=1&cmd=3001&par=1');
  }

  @override
  Future<void> setWifiName(String name) async {
    await dio.get('/?custom=1&cmd=3003&str=$name');

    await Future.delayed(const Duration(seconds: 1));
    await dio.get(
      '/?custom=1&cmd=3007&par=4',
    );
  }

  @override
  Future<int?> getBatteryStatus() async {
    final response = await dio.get('/?custom=1&cmd=3019');
    final document = XmlDocument.parse(response.data);
    final functionElement = document.findAllElements('Function').first;
    final status = functionElement.getElement('Value')?.innerText;
    final statusCode = int.tryParse(status!);
    Logger.i('Battery status: $statusCode');
    return statusCode;
  }

  @override
  Future<void> switchToHighResMode() async {
    await dio.get('/?custom=1&cmd=1002&par=3');
  }

  @override
  Future<void> switchToVGAResMode() async {
    await dio.get('/?custom=1&cmd=1002&par=6');
  }

  @override
  Future<File> getPhotoFromFakeDevice() {
    final picker = ImagePicker();
    return picker.pickImage(source: ImageSource.gallery).then((value) async {
      if (value != null) {
        final file = File(value.path);
        final newFile = await file.copy(
            '${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        return newFile;
      } else {
        throw Exception('No image selected');
      }
    });
  }
}
