import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/live_modes/device_live_camera_provider.dart';
import 'package:seekr_app/application/image_process_provider.dart';
import 'package:seekr_app/application/live_modes/processing_status_provider.dart';

final deviceLiveWalkingPreviewProviderNew = AutoDisposeFutureProvider<String?>(
    (ref) => ref.watch(deviceCameraStreamProvider).when(
        data: (data) async {
          final isProcessingTimer = ref.watch(processingProvider);
          if (isProcessing || isProcessingTimer) {
            Logger.i('Processing is already in progress, skipping this frame');
            return ref.read(lastResultProvider);
          } else {
            isProcessing = true;
            final imageProcessRepo = ref.read(imageProcessRepoProvider);
            final audio = ref.read(audioRepoProvider);

            getResult() async {
              if (data == null) {
                return null;
              } else {
                final text = await imageProcessRepo.objectDetectFromImage(data);
                if (text != null) {
                  ref.read(lastResultProvider.notifier).state = text;
                  await audio.playText(text: text);
                  Logger.i('Obstacle detected $text');
                  return text;
                } else {
                  // await audio.playText(text: "No obstacle detected");
                  return null;
                }
              }
            }

            final result = await getResult();
            ref.read(processingProvider.notifier).stopProcessing();
            isProcessing = false;
            return result;
          }
        },
        error: (error, stack) {
          Logger.e('Error in device camera stream: $error');
          throw error;
        },
        loading: () => null));

// final deviceObstacleAvoidanceProvider = AutoDisposeStreamProvider<String?>((
//   ref,
// ) async* {
//   final url = Uri.parse("http://192.168.1.254:8192/");
//   final Uint8List jpegStart = Uint8List.fromList([0xFF, 0xD8]);
//   final Uint8List jpegEnd = Uint8List.fromList([0xFF, 0xD9]);
//   final List<int> buffer = [];
//   final imageProcessRepo = ref.read(imageProcessRepoProvider);
//   final client = Client();
//   final audio = ref.watch(audioRepoProvider);
//   ref.onDispose(() {
//     Logger.i("Disposing device live preview stream");
//     client.close();
//     buffer.clear();
//   });
//   final request = Request('GET', url);
//   final streamedResponse = await client.send(request);
//   Logger.i('Started device stream');
//   await for (final data in streamedResponse.stream) {
//     bool foundData = false;
//     if (!ref.read(processingProvider)) {
//       ref.read(processingProvider.notifier).startProcessing();
//       buffer.addAll(data);
//       try {
//         final int startIndex = findSequence(buffer, jpegStart);
//         if (startIndex >= 0) {
//           final int endIndex = findSequence(buffer, jpegEnd, startIndex + 2);
//           if (endIndex >= 0) {
//             final imageData =
//                 Uint8List.fromList(buffer.sublist(startIndex, endIndex + 2));
//             buffer.removeRange(0, endIndex + 2);
//             final text =
//                 await imageProcessRepo.objectDetectFromImage(imageData);

//             if (text != null) {
//               await audio.playText(text: text);
//               Logger.i('Obstacle detected $text');
//               yield text;
//               foundData = true;
//             } else {
//               // await audio.playText(text: "No obstacle detected");
//               yield null;
//             }
//           }
//         } else {
//           buffer.clear();
//         }
//       } catch (e) {
//         Logger.e(e);
//       }
//       Future.delayed((foundData ? Duration(seconds: 2) : Duration.zero), () {
//         ref.read(processingProvider.notifier).stopProcessing();
//       });
//     }
//   }
// });
