import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/chat/chat_provider.dart';
import 'package:seekr_app/application/device/device_provider.dart';
import 'package:seekr_app/application/device/socket_provider.dart';
import 'package:seekr_app/application/settings_provider.dart';
import 'package:seekr_app/application/speech_to_text_provider.dart';
import 'package:seekr_app/domain/chat/chat_context.dart';
import 'package:seekr_app/domain/device/device_action_type.dart';
import 'package:seekr_app/presentation/screens/chat/widgets/stream_response_widget.dart';

class ChatBody extends HookConsumerWidget {
  final IList<ChatContext> contexts;
  final Uint8List image;
  const ChatBody({
    super.key,
    required this.contexts,
    required this.image,
  });

  @override
  Widget build(BuildContext context, ref) {
    final speechProvider = ref.watch(speechToTextProvider);
    final chatController = useTextEditingController();
    final provider = chatProvider(image);
    final shouldScroll = useState(true);

    final scrollController = useScrollController();

    final isDeviceConnected = ref.watch(deviceConnectedProvider);
    final lifeCycleState = useAppLifecycleState();

    if (isDeviceConnected) {
      ref.watch(socketProvider).whenData((socket) => ref.listen(
            deviceEventStreamProvider,
            (previous, next) async {
              if (next.hasValue &&
                  previous?.value != next.value &&
                  lifeCycleState == AppLifecycleState.resumed) {
                final action = next.value!.action;
                switch (action) {
                  case DeviceActionType.longPress:
                    Logger.i("long press");
                    if (speechProvider.isListening) {
                      Logger.i("stop listening");
                      speechProvider.stop();
                    } else {
                      Logger.i("start listening");
                      final currentLocaleId = ref
                          .read(settingsRepoProvider)
                          .requireValue
                          .getLangCodeForLocale();
                      Logger.i('currentLocaleId: $currentLocaleId');
                      speechProvider.listen(
                          partialResults: false, localeId: currentLocaleId);
                    }
                    break;
                  default:
                    break;
                }
              }
            },
          ));
    }

    useEffect(() {
      scrollController.addListener(() {
        if (scrollController.position.pixels <
            scrollController.position.maxScrollExtent - 50) {
          // Only update if needed to avoid unnecessary rebuilds
          if (shouldScroll.value) {
            shouldScroll.value = false;
          }
        }
        // When user manually scrolls to near bottom
        else if (scrollController.position.pixels >
            scrollController.position.maxScrollExtent - 50) {
          // Only update if needed to avoid unnecessary rebuilds
          if (!shouldScroll.value) {
            shouldScroll.value = true;
          }
        }
      });

      return () {
        scrollController.removeListener(() {});
      };
    }, [scrollController]);

    useEffect(() {
      chatController.text = speechProvider.lastResult?.recognizedWords ?? '';
      if (speechProvider.hasResults && chatController.text.isNotEmpty) {
        shouldScroll.value = true;

        Future.microtask(() async {
          await ref.read(provider.notifier).sendMessage(chatController.text);
          Future.delayed(
            const Duration(milliseconds: 500),
            () {
              chatController.clear();
              scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut);
            },
          );
        });
        Logger.i(
            'SpeechProvider has results: ${speechProvider.lastResult?.recognizedWords}');
      }

      return null;
    }, [speechProvider.lastResult?.recognizedWords]);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: contexts.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(image)),
                  );
                }
                final index = i - 1;
                final contextData = contexts[index];
                // return StreamResponseWidget(
                //   context: contextData,
                // );
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.blue[200],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                contextData.text,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Text('You',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                )),
                          ],
                        ),
                      ),
                    ),
                    if (ref.watch(chatResultProvider(contextData)).text == null)
                      StreamResponseWidget(
                        context: contextData,
                        scrollToBottom: () {
                          if (shouldScroll.value) {
                            scrollController.jumpTo(
                                scrollController.position.maxScrollExtent);
                          }
                        },
                      )
                    else
                      FinalChatResponseWidget(
                        result:
                            ref.watch(chatResultProvider(contextData)).text!,
                      )
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ref.watch(speechToTextInitProvider).when(
                      data: (data) {
                        return IconButton(
                          icon: Icon(Icons.mic),
                          color: speechProvider.isListening
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            if (speechProvider.isListening) {
                              speechProvider.stop();
                            } else {
                              final currentLocaleId = ref
                                  .read(settingsRepoProvider)
                                  .requireValue
                                  .getLangCodeForLocale();
                              Logger.i('currentLocaleId: $currentLocaleId');
                              speechProvider.listen(
                                  partialResults: false,
                                  localeId: currentLocaleId);
                            }
                          },
                        );
                      },
                      error: (error, stackTrace) => const SizedBox(),
                      loading: () => const SizedBox(),
                    ),
                Expanded(
                  child: TextField(
                    controller: chatController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (chatController.text.isNotEmpty) {
                      await ref
                          .read(provider.notifier)
                          .sendMessage(chatController.text);
                      scrollController.animateTo(
                          scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut);
                      chatController.clear();
                      shouldScroll.value = true;
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
