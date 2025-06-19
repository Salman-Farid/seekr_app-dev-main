import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/bus_detection/device_live_preview_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class DeviceBusDetectionPage extends HookConsumerWidget {
  static const routeName = 'device-bus';
  static const routePath = '/device-bus';

  const DeviceBusDetectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showStream = useState(true);
    return VisibilityDetector(
      key: const Key('device-bus'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0) {
          showStream.value = false;
        } else {
          showStream.value = true;
        }
      },
      child: Scaffold(
        body: showStream.value
            ? Center(
                child: ref.watch(deviceLivePreviewProvider).maybeWhen(
                      orElse: () => CircularProgressIndicator(),
                      data: (data) => data != null
                          ? Text(
                              data,
                              style: Theme.of(context).textTheme.headlineMedium,
                            )
                          : Text(
                              "Nothing detected",
                              style: TextStyle(fontSize: 20, color: Colors.red),
                            ),
                    ),
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
