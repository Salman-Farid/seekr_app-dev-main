import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/live_modes/obstacle_avoidance/device_live_obstacle_avoidance_provider.dart';
import 'package:seekr_app/application/live_modes/processing_status_provider.dart';
import 'package:seekr_app/presentation/screens/device/live/widgets/live_detection_result_text.dart';

class DeviceLiveWalkingDetectionWidget extends HookConsumerWidget {
  const DeviceLiveWalkingDetectionWidget({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final lastResult = ref.watch(lastResultProvider);

    return Center(
      child: ref.watch(deviceLiveWalkingPreviewProviderNew).when(
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
                        'Nothing detected',
                        style: TextStyle(fontSize: 20, color: Colors.red),
                      ),
          ),
    );
  }
}
