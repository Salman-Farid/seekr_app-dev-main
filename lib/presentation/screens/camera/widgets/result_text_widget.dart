import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/device/device_provider.dart';
import 'package:seekr_app/application/device/socket_provider.dart';
import 'package:seekr_app/domain/device/device_action_type.dart';
import 'package:seekr_app/domain/image_process/image_process_data.dart';
import 'package:seekr_app/domain/image_process/image_process_page_param.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/screens/camera/image_process_page.dart';
import 'package:seekr_app/presentation/screens/camera/reuse_camera_page.dart';

class ResultTextWidget extends HookConsumerWidget {
  final ImageProcessData data;
  final String translatedText;
  final bool fromDevice;
  const ResultTextWidget({
    super.key,
    required this.translatedText,
    required this.fromDevice,
    required this.data,
  });

  @override
  Widget build(BuildContext context, ref) {
    final type = data.processType;
    final isPaused = useState(false);

    return PopScope(
      onPopInvokedWithResult: (v, _) =>
          ref.read(audioRepoProvider).stopTextToSpeech(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (type == ProcessType.scene && !fromDevice)
            SizedBox(
              width: double.infinity,
              child: Semantics(
                sortKey: const OrdinalSortKey(3),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        backgroundColor: Colors.blue.shade200,
                        shape: const RoundedRectangleBorder(),
                        foregroundColor: Colors.white,
                        textStyle:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                    onPressed: () {
                      context.replace(ImageProcessPage.routePath,
                          extra: ImageProcessPageParam(
                            imagePath: data.image.path,
                            processType: ProcessType.sceneLong,
                          ));
                    },
                    child: Text("Read Long Description")),
              ),
            )
          else if (type == ProcessType.sceneLong && !fromDevice)
            SizedBox(
              width: double.infinity,
              child: Semantics(
                sortKey: const OrdinalSortKey(3),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        backgroundColor: Colors.blue.shade200,
                        shape: const RoundedRectangleBorder(),
                        foregroundColor: Colors.white,
                        textStyle:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                    onPressed: () {
                      context.replace(ImageProcessPage.routePath,
                          extra: ImageProcessPageParam(
                            imagePath: data.image.path,
                            processType: ProcessType.scene,
                          ));
                    },
                    child: Text("Read Short Description")),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: SingleChildScrollView(
                  child: GestureDetector(
                    onTap: () async {
                      if (isPaused.value) {
                        await ref
                            .read(audioRepoProvider)
                            .speakTts(text: translatedText);

                        Logger.i('resuming tts');
                        isPaused.value = false;
                      } else {
                        await ref.read(audioRepoProvider).pauseTts();
                        Logger.i('pausing tts');
                        isPaused.value = true;
                      }
                    },
                    child: Semantics(
                      label: translatedText,
                      sortKey: const OrdinalSortKey(1),
                      child: Text(
                        translatedText,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              if (!fromDevice)
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          backgroundColor: Colors.deepPurple.shade200,
                          shape: const RoundedRectangleBorder(),
                          foregroundColor: Colors.white,
                          textStyle:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                      onPressed: () {
                        context.replace(ReuseCameraPage.routePath,
                            extra: type.name);
                      },
                      child: Text(Words.of(context)!.reuseFeature)),
                ),
              ReplayButton(
                text: translatedText,
                processType: type,
              )
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: Semantics(
              sortKey: const OrdinalSortKey(2),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      backgroundColor: Colors.blue.shade200,
                      shape: const RoundedRectangleBorder(),
                      foregroundColor: Colors.white,
                      textStyle:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                  onPressed: () {
                    if (fromDevice) {
                      ref.read(showDevImageProcessProvider.notifier).state =
                          false;
                      ref.read(audioRepoProvider).stopTextToSpeech();
                    } else {
                      context.pop();
                    }
                  },
                  child: Text(Words.of(context)!.goBack)),
            ),
          ),
        ],
      ),
    );
  }
}

class ReplayButton extends HookConsumerWidget {
  final String text;
  final ProcessType processType;

  const ReplayButton({
    super.key,
    required this.text,
    required this.processType,
  });

  @override
  Widget build(BuildContext context, ref) {
    final lifeCycleState = useAppLifecycleState();
    ref.watch(socketProvider).whenData((socket) => ref.listen(
          deviceEventStreamProvider,
          (previous, next) {
            if (next.hasValue &&
                previous?.value != next.value &&
                lifeCycleState == AppLifecycleState.resumed) {
              final action = next.value!.action;
              switch (action) {
                case DeviceActionType.longPress:
                  if (processType != ProcessType.scene) {
                    Logger.i("replay");
                    ref.read(audioRepoProvider).playText(text: text);
                  }
                  break;
                default:
                  break;
              }
            }
          },
        ));

    return Expanded(
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 30),
              backgroundColor: Colors.green.shade300,
              shape: const RoundedRectangleBorder(),
              foregroundColor: Colors.white,
              textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          onPressed: () {
            ref.read(audioRepoProvider).playText(text: text);
          },
          child: Text(Words.of(context)!.replay)),
    );
  }
}
