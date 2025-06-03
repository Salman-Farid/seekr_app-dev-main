import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/live_modes/bus_detection/device_live_bus_preview_provider.dart';
import 'package:seekr_app/application/live_modes/processing_status_provider.dart';
import 'package:seekr_app/presentation/screens/device/live/widgets/live_detection_result_text.dart';

class DeviceLiveBusDetectionWidget extends HookConsumerWidget {
  const DeviceLiveBusDetectionWidget({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final lastResult = ref.watch(lastResultProvider);

    return Center(
      child: ref.watch(deviceLiveBusPreviewProvider).when(
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
                        'No bus detected',
                        style: TextStyle(fontSize: 20, color: Colors.red),
                      ),
          ),
    );
  }
}
