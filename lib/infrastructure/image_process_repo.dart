import 'dart:convert';
import 'dart:io';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart';
import 'package:image/image.dart' as img;
import "package:path/path.dart";
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:seekr_app/domain/image_process/detection_result.dart';

import 'package:seekr_app/domain/image_process/i_image_process_repo.dart';
import 'package:seekr_app/domain/image_process/image_process_data.dart';
import 'package:seekr_app/domain/image_process/ocr.dart';

class ImageProcessRepo extends IImageProcessRepo {
  final Client client;
  final MethodChannel channel;
  ImageProcessRepo(
      {required this.client,
      this.channel = const MethodChannel('background_channel/ios')});
  @override
  Future<File> compressImage(String imagePath) async {
    final result = await FlutterImageCompress.compressWithFile(
      imagePath,
      quality: 50,
    );
    // await image.delete();

    final File temp = File(
        "${(await path.getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg");
    await temp.writeAsBytes(result!.toList());

    return temp;
  }

  @override
  Future<String> processImageRepo(ImageProcessData data) async {
    try {
      final size = data.image.lengthSync();
      final kb = size / 1024;
      final mb = kb / 1024;
      Logger.i('image size: $kb kb, $mb mb');
      final multipartFile = await MultipartFile.fromPath(
          'file', data.image.path,
          filename: basename(data.image.path));

      Logger.i('sending image');
      final request =
          MultipartRequest('POST', Uri.parse(getServerUrl(data.processType)))
            ..headers['Accept-Charset'] = 'UTF-8'
            ..headers['Accept-Language'] = data.languageCode
            ..files.add(
              multipartFile,
            );
      final response = await client.send(request);
      final byteString = await response.stream.bytesToString();
      Logger.i(byteString);
      Logger.i(jsonDecode(byteString));
      return jsonDecode(byteString);
    } catch (e) {
      Logger.e(e);
      return 'Nothing detected';
    }
  }

  Future<String> processText(ImageProcessData dt) async {
    // final fileName = basename(image.path);
    // final imageRef = storage.ref('text-to-speech/$fileName');
    // await imageRef.putFile(image);
    // final url = imageRef.getDownloadURL();
    // final language = dt.languageCode == 'en_US'
    //     ? 'en'
    //     :dt.languageCode == 'en_US';
    try {
      // print image size in kb and mb
      final size = dt.image.lengthSync();
      final kb = size / 1024;
      final mb = kb / 1024;
      Logger.i('image size: $kb kb, $mb mb');
      Logger.i('sending text');
      final uri = Uri.https('vidiazure.cognitiveservices.azure.com',
          '/computervision/imageanalysis:analyze', {
        'features': 'read',
        'model-version': 'latest',
        'language': dt.languageCode,
        'gender-neutral-caption': 'false',
        'api-version': '2023-10-01'
      });
      Logger.i('sending text ${uri.toString()}');
      final bytes = dt.image.readAsBytesSync();

      final request = Request("POST", uri)
        ..headers['Ocp-Apim-Subscription-Key'] =
            "b7e373dc1615410d86a06639e8e87b43"
        ..headers['Content-Type'] = "application/octet-stream"
        ..bodyBytes = bytes;

      final response = await Response.fromStream(await request.send());
      // final ok = utf8.decode(codeUnits)
      // final response = await client.post(uri,
      //     headers: {
      //       'Ocp-Apim-Subscription-Key': 'b7e373dc1615410d86a06639e8e87b43',
      //       'Content-Type': 'application/octet-stream'
      //     },
      //     : bytes);
      Logger.json(response.body);

      final data = jsonDecode(response.body);
      final blocks = OcrBlocks.fromMap(data['readResult']);
      final text = blocks.blocks
          .map((e) => e.lines.map((e) => e.text).join(' '))
          .join(' ');
      return text;
    } catch (e) {
      Logger.e(e);
      return 'No text detected';
    }
  }

  String getServerUrl(ProcessType type) {
    switch (type) {
      case ProcessType.text:
        return 'https://textdetection.com.ngrok.app';
      case ProcessType.object:
        return 'https://yolov3-flask1-wx2bjo7cia-uc.a.run.app/debug';
      case ProcessType.scene:
        return 'https://image-792768179921.us-central1.run.app';
      case ProcessType.bus:
        return 'https://busdetection-wx2bjo7cia-uc.a.run.app/video';
      case ProcessType.depth:
        return 'https://yolov3-flask1-wx2bjo7cia-uc.a.run.app';
      case ProcessType.supermarket:
        return 'https://supermarket.ngrok.app';
      case ProcessType.museum:
        return 'https://ymcaimage-792768179921.us-central1.run.app';
    }
  }

  @override
  Future<Uint8List?> busDetectFromImage(Uint8List imageBytes) async {
    if (Platform.isIOS) {
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        Logger.e("Failed to decode image");
        return null;
      }
      final Map<String, dynamic> args = {"image": imageBytes};
      final result = await channel.invokeMethod("runModel", args);
      final detections = List<Map>.from(result['detections']);

      if (detections.isEmpty) {
        return null;
      } else {
        final detectionResults = detections
            .map((e) => DetectionResult.fromJson(jsonEncode(e)))
            .toIList();
        final detection = detectionResults.first;
        final int imageWidth = originalImage.width;
        final int imageHeight = originalImage.height;

        // Extract bounding box values (normalized)
        final double x = detection.boundingBox.x;
        final double y = detection.boundingBox.y;
        final double width = detection.boundingBox.width;
        final double height = detection.boundingBox.height;

        Logger.i({
          "x": x,
          "y": y,
          "width": width,
          "height": height,
          "imageWidth": imageWidth,
          "imageHeight": imageHeight
        });

        if (width >= imageWidth && height >= imageHeight) {
          return null;
        }

        // Convert to pixel values and adjust y-axis origin
        int cropX = (x * imageWidth).toInt();
        int cropY = ((1 - y - height) * imageHeight).toInt();
        int cropWidth = (width * imageWidth).toInt();
        int cropHeight = (height * imageHeight).toInt();

        // Ensure crop coordinates stay within bounds
        cropX = cropX.clamp(0, imageWidth - 1);
        cropY = cropY.clamp(0, imageHeight - 1);
        cropWidth = cropWidth.clamp(1, imageWidth - cropX);
        cropHeight = cropHeight.clamp(1, imageHeight - cropY);

        // Crop the detected bounding box
        final img.Image croppedImage = img.copyCrop(originalImage,
            x: cropX, y: cropY, width: cropWidth, height: cropHeight);

        // Crop the right half of the detected region
        final int rightX = cropWidth ~/ 2;
        final int rightWidth = cropWidth - rightX;
        final img.Image rightHalfImage = img.copyCrop(croppedImage,
            x: rightX, y: 0, width: rightWidth, height: cropHeight);

        final croppedHeight = rightHalfImage.height;
        final croppedWidth = rightHalfImage.width;
        Logger.i({
          "croppedWidth": croppedWidth,
          "croppedHeight": croppedHeight,
        });

        return img.encodeJpg(rightHalfImage);
      }
    } else {
      return null;
    }
  }

  @override
  Future<String?> ocrFromImage(Uint8List imageBytes) async {
    final path =
        "https://vidiazure.cognitiveservices.azure.com/computervision/imageanalysis:analyze";

    // Query parameters
    final queryParams = {
      'features': 'read',
      'model-version': 'latest',
      'language': 'en',
      'gender-neutral-caption': 'false',
      'api-version': '2023-10-01'
    };
    final url = Uri.parse(path).replace(queryParameters: queryParams);
    final request = Request('POST', url)
      ..headers['Ocp-Apim-Subscription-Key'] =
          'b7e373dc1615410d86a06639e8e87b43'
      ..headers['Content-Type'] = 'application/octet-stream'
      ..bodyBytes = imageBytes;

    final Response response = await Response.fromStream(await request.send());

    if (response.statusCode != 200) {
      Logger.e('Error: ${response.statusCode}');
      Logger.e('Response body: ${response.body}');
      return null;
    }
    final data = jsonDecode(response.body);
    final blocks = OcrBlocks.fromMap(data['readResult']);
    if (blocks.blocks.isEmpty) {
      return null;
    }
    final text = blocks.blocks
        .map((e) => e.lines.map((e) => e.text).join(' '))
        .join(' ');

    if (text.trimLeft().isEmpty) {
      return null;
    }
    return text;
  }
}
