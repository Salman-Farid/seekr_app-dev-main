import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/chat/chat_provider.dart';
import 'package:seekr_app/application/device/device_provider.dart';
import 'package:seekr_app/application/device/socket_provider.dart';
import 'package:seekr_app/application/image_process_provider.dart';
import 'package:seekr_app/domain/device/device_action_type.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/screens/chat/widgets/chat_body.dart';
import 'package:seekr_app/presentation/screens/chat/widgets/chat_bot_camera_view.dart';

class ChatBotPage extends HookConsumerWidget {
  static const String routeName = 'chat-bot';
  static const String routePath = '/chat-bot';
  const ChatBotPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final image = useState<Uint8List?>(null);
    final isDeviceConnected = ref.watch(deviceConnectedProvider);
    final lifeCycleState = useAppLifecycleState();

    if (isDeviceConnected) {
      ref.watch(socketProvider).whenData((socket) =>
          ref.watch(ensureDeviceCameraModeProvider).whenData((_) => ref.listen(
                deviceEventStreamProvider,
                (previous, next) async {
                  if (next.hasValue &&
                      previous?.value != next.value &&
                      lifeCycleState == AppLifecycleState.resumed) {
                    final action = next.value!.action;
                    switch (action) {
                      case DeviceActionType.capturePhoto:
                        Logger.i("capture photo");

                        final file = await ref
                            .read(deviceRepoProvider)
                            .getPhotoFromDevice();
                        final compressedFiles = await ref
                            .watch(imageCompressProvider(file.path).future);
                        final bytes = await compressedFiles.readAsBytes();
                        image.value = bytes;
                        break;
                      default:
                        break;
                    }
                  }
                },
              )));
    }

    return PopScope(
      onPopInvokedWithResult: (_, result) {
        final audio = ref.read(audioRepoProvider);
        audio.stopBgMusic();
        audio.stopTextToSpeech();
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: image.value != null
              ? ref.watch(chatProvider(image.value!)).when(
                    data: (contexts) => Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Semantics(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 30),
                                    backgroundColor: Colors.blue.shade200,
                                    shape: const RoundedRectangleBorder(),
                                    foregroundColor: Colors.white,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        )),
                                onPressed: () {
                                  image.value = null;
                                },
                                child: Text(Words.of(context)!.goBack)),
                          ),
                        ),
                        Expanded(
                          child: ChatBody(
                            contexts: contexts,
                            image: image.value!,
                          ),
                        ),
                      ],
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      child: Text(error.toString(),
                          style: TextStyle(color: Colors.red)),
                    ),
                  )
              : ChatBotCameraView(
                  onImageSelected: (bytes) {
                    image.value = bytes;
                  },
                ),
        ),
      ),
    );
  }
}
