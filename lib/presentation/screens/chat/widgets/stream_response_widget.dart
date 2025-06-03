import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/chat/chat_provider.dart';
import 'package:seekr_app/domain/chat/chat_context.dart';

class StreamResponseWidget extends HookConsumerWidget {
  final ChatContext context;
  final VoidCallback scrollToBottom;
  const StreamResponseWidget(
      {super.key, required this.context, required this.scrollToBottom});

  @override
  Widget build(BuildContext context, ref) {
    final provider = chatStreamProvider(this.context);
    ref.listen(provider, (previous, next) {
      scrollToBottom();
    });
    return ref.watch(provider).when(
        data: (data) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                onTap: () {
                  ref.read(audioRepoProvider).stopTextToSpeech();
                },
                tileColor: Colors.grey[200],
                subtitle: Text(data.join()),
              ),
            ),
        error: (error, _) => ListTile(
              title: Text('Error'),
              subtitle: Text(error.toString()),
            ),
        loading: () => ListTile());
  }
}

class FinalChatResponseWidget extends HookConsumerWidget {
  final String result;
  const FinalChatResponseWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, ref) {
    useEffect(() {
      ref.read(audioRepoProvider).playText(text: result);
      return () {
        ref.read(audioRepoProvider).stopTextToSpeech();
      };
    }, [result]);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: () {
          ref.read(audioRepoProvider).stopTextToSpeech();
        },
        tileColor: Colors.grey[200],
        subtitle: Text(result),
      ),
    );
  }
}
