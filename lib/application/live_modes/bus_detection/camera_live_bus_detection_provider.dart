import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_image_converter/flutter_image_converter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/camera/camera_controller_provider.dart';
import 'package:seekr_app/application/image_process_provider.dart';
import 'package:seekr_app/infrastructure/img_util.dart';

final cameraLiveBusDetectionStreamProvider =
    AutoDisposeStreamProvider<Uint8List?>((
  ref,
) async* {
  bool processing = false;
  final cameraController = ref.watch(cameraControllerProvider).requireValue!;
  final streamController = StreamController<Uint8List?>.broadcast();
  // Removing unused variable
  final imageProcessRepo = ref.read(imageProcessRepoProvider);
  final audio = ref.read(audioRepoProvider);
  if (Platform.isIOS) {
    await cameraController.startImageStream((image) async {
      if (!processing) {
        processing = true; // Set processing to true before starting
        final imageData = ImageUtils.convertCameraImage(image);
        final imageByte = await imageData.pngUint8List;

        // If you need to use imageProcessRepo, uncomment and use it like:
        // final imageProcessRepo = ref.read(imageProcessRepoProvider);
        final result = await imageProcessRepo.busDetectFromImage(imageByte);
        if (result != null) {
          streamController.add(result);
          try {
            final text = await imageProcessRepo.ocrFromImage(result);
            if (text != null) {
              await audio.playText(text: "Bus number $text is approaching");
              Logger.i('Bus detected $text');
            }
          } catch (e) {
            Logger.e('Error in ocr $e');
          }
          await audio.playText(
              text: "Bus detected but the number plate is not clear");
          // audio.playText(text: "Bus detected");
          await Future.delayed(const Duration(seconds: 2));
        } else {
          streamController.add(null);
          await Future.delayed(const Duration(milliseconds: 500));
        }

        // final result = imgImage.toUint8List();
        // streamController.add(result);

        processing = false;
      }
    });
  }
  ref.onDispose(() {
    if (Platform.isIOS) {
      cameraController.stopImageStream();
    }
    streamController.close();
  });

  yield* streamController.stream;
});
