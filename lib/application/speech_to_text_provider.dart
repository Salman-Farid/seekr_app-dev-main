import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

final speechToTextInitProvider =
    FutureProvider((ref) => ref.watch(speechToTextProvider).initialize());

final speechToTextProvider =
    ChangeNotifierProvider<SpeechToTextProvider>((ref) {
  final speech = SpeechToText();
  return SpeechToTextProvider(speech);
});
