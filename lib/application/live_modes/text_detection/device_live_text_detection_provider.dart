import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/live_modes/device_live_camera_provider.dart';
import 'package:seekr_app/application/image_process_provider.dart';
import 'package:seekr_app/application/live_modes/processing_status_provider.dart';
import 'package:seekr_app/application/live_modes/text_detection/camera_live_text_detection_provider.dart';
import 'package:seekr_app/domain/image_process/live_text_result.dart';

final deviceLiveTextDetectionProviderNew = AutoDisposeFutureProvider<String?>(
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
                final detectionResult =
                    await imageProcessRepo.textDetectFromImage(data);
                if (detectionResult != null) {
                  audio.playText(text: detectionResult.message);
                  Logger.i('Text detected $detectionResult');
                  ref.read(lastResultProvider.notifier).state =
                      detectionResult.message;
                  ref.read(lastFoundDocumentProvider.notifier).state =
                      detectionResult;
                  return detectionResult;
                } else {
                  // await audio.playText(text: "No obstacle detected");
                  return null;
                }
              }
            }

            final result = await getResult();
            ref.read(processingProvider.notifier).stopProcessing();
            isProcessing = false;
            return result?.message;
          }
        },
        error: (error, stack) {
          Logger.e('Error in device camera stream: $error');
          throw error;
        },
        loading: () => null));

final deviceLiveTextDetectionProvider =
    AutoDisposeStreamProvider<LiveTextResult?>((
  ref,
) async* {
  final url = Uri.parse("http://192.168.1.254:8192/");
  final Uint8List jpegStart = Uint8List.fromList([0xFF, 0xD8]);
  final Uint8List jpegEnd = Uint8List.fromList([0xFF, 0xD9]);
  final List<int> buffer = [];
  final imageProcessRepo = ref.read(imageProcessRepoProvider);

  bool shouldContinue = true;
  int retryCount = 0;
  const maxRetries = 5;
  const initialRetryDelay = Duration(seconds: 1);

  ref.onDispose(() {
    Logger.i("Disposing device live text detection stream");
    shouldContinue = false;
    buffer.clear();
    ref.read(lastFoundDocumentProvider.notifier).state = null;
  });

  while (shouldContinue && retryCount < maxRetries) {
    Client client = Client();
    try {
      final request = Request('GET', url);
      final streamedResponse = await client.send(request);

      Logger.i('Started device stream (attempt ${retryCount + 1})');
      retryCount = 0;

      await for (final data in streamedResponse.stream) {
        if (!shouldContinue) break;

        bool foundData = false;
        if (!ref.read(processingProvider) &&
            ref.watch(lastFoundDocumentProvider) == null) {
          ref.read(processingProvider.notifier).startProcessing();
          buffer.addAll(data);
          try {
            final int startIndex = findSequence(buffer, jpegStart);
            if (startIndex >= 0) {
              final int endIndex =
                  findSequence(buffer, jpegEnd, startIndex + 2);
              if (endIndex >= 0) {
                final imageData = Uint8List.fromList(
                    buffer.sublist(startIndex, endIndex + 2));
                buffer.removeRange(0, endIndex + 2);
                final result =
                    await imageProcessRepo.textDetectFromImage(imageData);

                if (result != null) {
                  Logger.i('Text detected $result');
                  yield result;
                  foundData = true;
                }
              }
            } else {
              buffer.clear();
            }
          } catch (e) {
            Logger.e('Processing error: $e');
          }
          Future.delayed((foundData ? Duration(seconds: 2) : Duration.zero),
              () {
            if (shouldContinue) {
              ref.read(processingProvider.notifier).stopProcessing();
            }
          });
        }
      }
    } catch (e) {
      Logger.e('Connection error: $e');
      retryCount++;
      if (retryCount < maxRetries) {
        final delay = Duration(
            milliseconds: initialRetryDelay.inMilliseconds * (1 << retryCount));
        Logger.i(
            'Retrying in ${delay.inSeconds} seconds (attempt $retryCount/$maxRetries)');
        await Future.delayed(delay);
      } else {
        Logger.e('Max retries reached, stopping stream');
        yield null;
      }
    } finally {
      client.close();
    }
  }
});
