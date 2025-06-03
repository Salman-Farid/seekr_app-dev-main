import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';

import 'package:seekr_app/application/live_modes/text_detection/camera_live_text_detection_provider.dart';
import 'package:seekr_app/localization/localization_type.dart';

class CameraDocumentDetectionPage extends HookConsumerWidget {
  static const routeName = 'camera-document-detection';
  static const routePath = '/camera-document-detection';
  const CameraDocumentDetectionPage({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (ref.watch(lastFoundDocumentProvider) != null) ...[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      ref.watch(lastFoundDocumentProvider)!.message,
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      backgroundColor: Colors.blue.shade200,
                      shape: const RoundedRectangleBorder(),
                      foregroundColor: Colors.white,
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    ref.read(lastFoundDocumentProvider.notifier).state = null;
                  },
                  child: Text('Continue')),
            )
          ] else
            CameraDocumentDetectionResult(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    backgroundColor: Colors.red.shade200,
                    shape: const RoundedRectangleBorder(),
                    foregroundColor: Colors.white,
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                onPressed: () {
                  ref.read(audioRepoProvider).stopTextToSpeech();
                  context.pop();
                },
                child: Text(Words.of(context)!.goBack)),
          ),
        ],
      ),
    );
  }
}

class CameraDocumentDetectionResult extends HookConsumerWidget {
  const CameraDocumentDetectionResult({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final lastDirection = useState<String?>(null);
    ref.listen(
      cameraLiveTextDetectionStreamProvider,
      (previous, next) {
        if (next.value?.message != null) {
          if (next.value?.isResultGenerated == true ||
              lastDirection.value != next.value!.message) {
            ref.read(audioRepoProvider).playText(text: next.value!.message);
          }
        }
        if (next.hasValue &&
            next.value != null &&
            next.value?.message != null &&
            next.value?.isResultGenerated == true) {
          ref.read(lastFoundDocumentProvider.notifier).state = next.value!;
        }
      },
    );

    return ref.watch(cameraLiveTextDetectionStreamProvider).when(
          error: (e, _) => Text(e.toString()),
          data: (data) => Expanded(
              child: Padding(
            padding: const EdgeInsets.all(40),
            child: data != null
                ? Center(
                    child: Text(data.message),
                  )
                : Center(
                    child: Text(
                      'No document detected',
                      style: TextTheme.of(context).headlineLarge?.copyWith(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
          )),
          loading: () =>
              Expanded(child: Center(child: const CircularProgressIndicator())),
        );
  }
}
