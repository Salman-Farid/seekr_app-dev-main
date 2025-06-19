import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/image_process_provider.dart';

int findSequence(List<int> source, List<int> sequence, [int startIndex = 0]) {
  if (startIndex + sequence.length > source.length) {
    return -1;
  }

  for (int i = startIndex; i <= source.length - sequence.length; i++) {
    bool found = true;
    for (int j = 0; j < sequence.length; j++) {
      if (source[i + j] != sequence[j]) {
        found = false;
        break;
      }
    }
    if (found) {
      return i;
    }
  }
  return -1;
}

final processingProvider = StateProvider<bool>((ref) => false);
final deviceLivePreviewProvider = AutoDisposeStreamProvider<String?>((
  ref,
) async* {
  final url = Uri.parse("http://192.168.1.254:8192/");
  final Uint8List jpegStart = Uint8List.fromList([0xFF, 0xD8]);
  final Uint8List jpegEnd = Uint8List.fromList([0xFF, 0xD9]);
  final List<int> buffer = [];
  final imageProcessRepo = ref.read(imageProcessRepoProvider);
  final client = Client();
  final audio = ref.watch(audioRepoProvider);
  ref.onDispose(() {
    Logger.i("Disposing device live preview stream");
    client.close();
    buffer.clear();
  });

  final request = Request('GET', url);
  final streamedResponse = await client.send(request);
  Logger.i('Started device stream');
  await for (final data in streamedResponse.stream) {
    bool foundData = false;
    if (!ref.read(processingProvider)) {
      ref.read(processingProvider.notifier).state = true;
      buffer.addAll(data);
      try {
        final int startIndex = findSequence(buffer, jpegStart);
        if (startIndex >= 0) {
          final int endIndex = findSequence(buffer, jpegEnd, startIndex + 2);
          if (endIndex >= 0) {
            final imageData =
                Uint8List.fromList(buffer.sublist(startIndex, endIndex + 2));
            buffer.removeRange(0, endIndex + 2);
            final result = await imageProcessRepo.busDetectFromImage(imageData);

            if (result != null) {
              final text = await imageProcessRepo.ocrFromImage(result);
              if (text != null) {
                await audio.playText(text: 'Bus number $text is approaching');
                Logger.i('Bus detected $text');
                yield text;
              } else {
                await audio.playText(
                    text: "Bus detected but the number plate is not clear");
                yield null;
              }
              foundData = true;
            } else {
              yield null;
            }
          }
        } else {
          buffer.clear();
        }
      } catch (e) {
        Logger.e(e);
      }
      Future.delayed((foundData ? Duration(seconds: 2) : Duration.zero), () {
        ref.read(processingProvider.notifier).state = false;
      });
    }
  }
});
