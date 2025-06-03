import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/image_process_provider.dart';
import 'package:seekr_app/application/live_modes/device_live_camera_provider.dart';
import 'package:seekr_app/application/live_modes/processing_status_provider.dart';

final deviceLiveBusPreviewProvider = AutoDisposeFutureProvider<String?>(
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
                final result = await imageProcessRepo.busDetectFromImage(data);
                if (result != null) {
                  final text = await imageProcessRepo.ocrFromImage(result);
                  if (text != null) {
                    final result = 'Bus number $text is approaching';
                    ref.read(lastResultProvider.notifier).state = result;
                    await audio.playText(text: result);
                    Logger.i('Bus detected $text');

                    return result;
                  } else {
                    final result =
                        "Bus detected but the number plate is not clear";
                    ref.read(lastResultProvider.notifier).state = result;
                    await audio.playText(text: result);
                    return result;
                  }
                } else {
                  return null;
                }
              }
            }

            final result = await getResult();
            ref.read(processingProvider.notifier).stopProcessing();
            await Future.delayed(const Duration(
                milliseconds: 100)); // Delay to prevent rapid processing
            isProcessing = false;
            return result;
          }
        },
        error: (error, stack) {
          Logger.e('Error in device camera stream: $error');
          throw error;
        },
        loading: () => null));
