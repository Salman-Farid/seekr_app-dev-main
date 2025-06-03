import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/device/device_provider.dart';
import 'package:seekr_app/application/device/device_state.dart';
import 'package:seekr_app/application/live_modes/device_live_camera_provider.dart';
import 'package:seekr_app/application/live_modes/processing_status_provider.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/screens/device/live/widgets/device_auto_read_detection_widget.dart';
import 'package:seekr_app/presentation/screens/device/live/widgets/device_live_bus_detection_widget.dart';
import 'package:seekr_app/presentation/screens/device/live/widgets/device_live_walking_detection_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LiveDetectionPage extends HookConsumerWidget {
  static const routeName = 'live-detection';
  static const routePath = '/live-detection';

  const LiveDetectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = useState<int?>(null);
    ref.watch(lastResultProvider);
    final deviceState = ref.watch(deviceStateProvider);
    final showStream = useState(true);
    final modes = [
      (
        Words.of(context)!.modeBus,
        Icon(Icons.bus_alert),
        DeviceLiveBusDetectionWidget()
      ),
      (
        Words.of(context)!.modeWalking,
        Icon(Icons.directions_walk),
        DeviceLiveWalkingDetectionWidget()
      ),
      (
        Words.of(context)!.autoRead,
        Icon(Icons.text_fields),
        DeviceAutoReadDetectionWidget()
      ),
    ];
    if (deviceState is ConnectedState) {
      return VisibilityDetector(
        key: const Key('device-bus'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction == 0) {
            showStream.value = false;
          } else {
            showStream.value = true;
          }
          Logger.i(
            'Device bus detection page visibility changed: ${showStream.value}',
          );
        },
        child: Scaffold(
          body: showStream.value
              ? ref.watch(deviceCameraStreamProvider).when(
                    data: (data) => Column(
                      children: [
                        Expanded(
                            child: currentIndex.value != null
                                ? modes[currentIndex.value!].$3
                                : Center(
                                    child: Text(
                                      "Please select a mode to start",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.red),
                                    ),
                                  )),
                        Row(
                          children: List.generate(modes.length, (index) {
                            final mode = modes[index];
                            return Expanded(
                              child: SizedBox(
                                height: 100,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: currentIndex.value == index
                                        ? Colors.blue
                                        : Colors.grey,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(),
                                  ),
                                  onPressed: () {
                                    currentIndex.value = index;
                                    ref
                                        .read(lastResultProvider.notifier)
                                        .state = null;
                                  },
                                  child: Text(mode.$1),
                                ),
                              ),
                            );
                          }),
                        )
                      ],
                    ),
                    error: (error, stack) {
                      return Center(
                        child: Text(
                          'Errorx: $error',
                          style: TextStyle(fontSize: 20, color: Colors.red),
                        ),
                      );
                    },
                    loading: () {
                      // Show a loading indicator while the camera stream is loading
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.red,
                        ),
                      );
                    },
                  )
              : SizedBox.shrink(),
        ),
      );
    } else {
      return Center(
        child: Text(
          Words.of(context)!.deviceNotConnected,
          style: TextStyle(fontSize: 20, color: Colors.red),
        ),
      );
    }
  }
}
