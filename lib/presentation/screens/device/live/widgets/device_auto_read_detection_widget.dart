import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/device/device_provider.dart';
import 'package:seekr_app/application/device/socket_provider.dart';
import 'package:seekr_app/application/live_modes/processing_status_provider.dart';
import 'package:seekr_app/application/live_modes/text_detection/camera_live_text_detection_provider.dart';
import 'package:seekr_app/application/live_modes/text_detection/device_live_text_detection_provider.dart';
import 'package:seekr_app/domain/device/device_action_type.dart';
import 'package:seekr_app/presentation/screens/device/live/widgets/live_detection_result_text.dart';

class DeviceAutoReadDetectionWidget extends HookConsumerWidget {
  const DeviceAutoReadDetectionWidget({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final lifeCycleState = useAppLifecycleState();
    ref.watch(socketProvider).whenData((socket) =>
        ref.watch(ensureDeviceCameraModeProvider).whenData((_) => ref.listen(
              deviceEventStreamProvider,
              (previous, next) {
                if (next.hasValue &&
                    previous?.value != next.value &&
                    lifeCycleState == AppLifecycleState.resumed) {
                  final action = next.value!.action;
                  switch (action) {
                    case DeviceActionType.longPress:
                      ref.read(lastFoundDocumentProvider.notifier).state = null;
                      break;
                    default:
                      break;
                  }
                }
              },
              onError: (error, stackTrace) => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(error.toString()))),
            )));
    final lastResult = ref.watch(lastResultProvider);

    return Center(
      child: (ref.watch(lastFoundDocumentProvider)?.isResultGenerated == true)
          ? Center(
              child: SingleChildScrollView(
                child: Text(
                  ref.watch(lastFoundDocumentProvider)!.message,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            )
          : ref.watch(deviceLiveTextDetectionProviderNew).when(
                error: (error, _) => Text(
                  'Error: $error',
                  style: TextStyle(fontSize: 20, color: Colors.red),
                ),
                loading: () => lastResult != null
                    ? LiveDetectionResultText(
                        resultText: lastResult,
                      )
                    : CircularProgressIndicator(),
                data: (data) => data != null
                    ? LiveDetectionResultText(
                        resultText: data,
                      )
                    : lastResult != null
                        ? LiveDetectionResultText(
                            resultText: lastResult,
                          )
                        : Text(
                            'No document detected',
                            style: TextStyle(fontSize: 20, color: Colors.red),
                          ),
              ),
    );
  }
}
