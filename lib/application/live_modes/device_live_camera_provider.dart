import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:seekr_app/application/live_modes/processing_status_provider.dart';

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

// final processingProvider = StateProvider<bool>((ref) => false);
bool isProcessing = false;

final clientProvider = Provider<Client>((ref) {
  final client = Client();
  ref.onDispose(() {
    Logger.i("Disposing client provider");
    client.close();
  });
  return client;
});

final deviceStreamProvider = FutureProvider((ref) async {
  ByteStream? byteStream;
  const maxRetries = 5;
  const initialRetryDelay = Duration(seconds: 1);
  int retryCount = 0;
  final url = Uri.parse("http://192.168.1.254:8192/");
  final client = ref.watch(clientProvider);
  while (retryCount < maxRetries && byteStream == null) {
    try {
      final request = Request('GET', url);
      final streamedResponse = await client.send(request);
      Logger.i('Started device stream (attempt ${retryCount + 1})');
      retryCount = 0; // Reset retry count on successful connection
      byteStream = streamedResponse.stream;
      break; // Exit loop on successful connection
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
        rethrow; // Rethrow the error after max retries
      }
    }
  }
  return byteStream!.asBroadcastStream();
});

final deviceCameraStreamProvider =
    AutoDisposeStreamProvider<Uint8List?>((ref) async* {
  // This is a critical change - create a multi-listener broadcast stream
  final streamedResponse = await ref.watch(deviceStreamProvider.future);

  final Uint8List jpegStart = Uint8List.fromList([0xFF, 0xD8]);
  final Uint8List jpegEnd = Uint8List.fromList([0xFF, 0xD9]);
  final List<int> buffer = [];

  ref.onDispose(() {
    buffer.clear();
  });
  Logger.i('Started device camera stream');
  await for (final data in streamedResponse) {
    buffer.addAll(data);

    try {
      final int startIndex = findSequence(buffer, jpegStart);
      if (startIndex >= 0) {
        final int endIndex = findSequence(buffer, jpegEnd, startIndex + 2);
        if (endIndex >= 0) {
          final imageData =
              Uint8List.fromList(buffer.sublist(startIndex, endIndex + 2));
          final isProcessingState = ref.read(processingProvider);

          if (!isProcessingState && !isProcessing) {
            yield imageData;
          }
          buffer.removeRange(0, endIndex + 2);
        }
      } else {
        buffer.clear();
      }
    } catch (e) {
      Logger.e('Processing error: $e');
    }
  }
});
