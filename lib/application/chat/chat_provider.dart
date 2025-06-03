import 'dart:async';
import 'dart:typed_data';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/chat/chat_repo_provider.dart';
import 'package:seekr_app/application/chat/chat_result_state.dart';
import 'package:seekr_app/domain/chat/chat_context.dart';
import 'package:seekr_app/domain/chat/chat_token.dart';
import 'package:seekr_app/domain/chat/message_request.dart';

final chatTokenProvider =
    AutoDisposeStreamProviderFamily<ChatToken, String>((ref, streamId) {
  return ref.read(chatRepoProvider).getResponseStream(streamId);
});

final chatResultProvider =
    StateProviderFamily<ChatResultState, ChatContext>((ref, context) {
  return ChatResultState(context: context);
});

final chatStreamProvider =
    StreamProviderFamily<IList<String>, ChatContext>((ref, context) async* {
  Logger.i("context for stream: $context");
  final streamController = StreamController<IList<String>>.broadcast();
  final List<String> tokenTexts = [];
  final stream = ref.read(chatRepoProvider).getResponseStream(context.streamId);
  final audio = ref.read(audioRepoProvider);
  audio.stopBgMusic();
  audio.stopTextToSpeech();
  final subscription = stream.listen((event) async {
    Logger.i(event);
    if (event.status != 'completed') {
      tokenTexts.add(event.text.replaceAll(RegExp(r'<\|im_end\|>'), ''));
      streamController.add(tokenTexts.lock);
      Logger.i(tokenTexts);
    } else {
      final fullText = tokenTexts.join();
      ref.read(chatResultProvider(context).notifier).state =
          ChatResultState(context: context, text: fullText);
    }
  }, onDone: () {
    Logger.i('chatStreamProvider done');
  }, onError: (error) {
    Logger.e("chatStreamProvider error: $error");
  });
  ref.onDispose(() {
    Logger.i('Stream disposed');
    subscription.cancel();
    streamController.close();
  });
  yield* streamController.stream;
});

final chatProvider =
    AsyncNotifierProviderFamily<ChatNotifier, IList<ChatContext>, Uint8List>(
        ChatNotifier.new);

class ChatNotifier extends FamilyAsyncNotifier<IList<ChatContext>, Uint8List> {
  @override
  FutureOr<IList<ChatContext>> build(arg) async {
    final request = MessageRequest(
      image: arg,
    );

    final audio = ref.read(audioRepoProvider);
    await audio.stopTextToSpeech();
    await audio.playBgMusic();
    final context = await ref.read(chatRepoProvider).sendMessage(request);
    await audio.stopBgMusic();
    return IListConst([context]); // Return an empty list initially
  }

  Future<void> sendMessage(String text) async {
    final audio = ref.read(audioRepoProvider);
    if (state.hasValue) {
      final request = MessageRequest(
          text: text,
          sessionId: state.requireValue.isNotEmpty
              ? state.requireValue.last.sessionId
              : null);

      await audio.playBgMusic();

      final context = await ref.read(chatRepoProvider).sendMessage(request);
      await audio.stopBgMusic();

      state = AsyncData(state.requireValue.add(context));
    }
  }
}
