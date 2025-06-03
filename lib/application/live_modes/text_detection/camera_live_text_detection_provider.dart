import 'dart:async';
import 'dart:io';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_image_converter/flutter_image_converter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/camera/camera_controller_provider.dart';
import 'package:seekr_app/application/image_process_provider.dart';
import 'package:seekr_app/domain/image_process/live_text_result.dart';
import 'package:seekr_app/infrastructure/img_util.dart';

final lastFoundDocumentProvider =
    AutoDisposeStateProvider<LiveTextResult?>((ref) {
  return null;
});

final cameraLiveTextDetectionStreamProvider =
    AutoDisposeStreamProvider<LiveTextResult?>((
  ref,
) async* {
  bool processing = false;
  final cameraController = ref.watch(cameraControllerProvider).requireValue!;
  final streamController = StreamController<LiveTextResult?>.broadcast();
  // Removing unused variable
  final imageProcessRepo = ref.read(imageProcessRepoProvider);
  ref.read(audioRepoProvider);

  if (Platform.isIOS) {
    await cameraController.startImageStream((image) async {
      if (!processing) {
        processing = true; // Set processing to true before starting
        final imageData = ImageUtils.convertCameraImage(image);
        final imageByte = await imageData.pngUint8List;

        // If you need to use imageProcessRepo, uncomment and use it like:
        // final imageProcessRepo = ref.read(imageProcessRepoProvider);
        final result = await imageProcessRepo.textDetectFromImage(imageByte);
        if (result != null) {
          Logger.i("Detected text: $result");
          streamController.add(result);
          // audio.playText(text: "Bus detected");
          // await Future.delayed(const Duration(milliseconds: 100));
        } else {
          // streamController.add(null);
          // await Future.delayed(const Duration(milliseconds: 100));
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
