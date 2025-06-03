import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/device/device_provider.dart';
import 'package:seekr_app/application/device/device_state.dart';
import 'package:seekr_app/domain/device/device_action_type.dart';
import 'package:seekr_app/main.dart';

class FakeDeviceWrapper extends HookConsumerWidget {
  final Widget child;
  const FakeDeviceWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, ref) {
    final deviceState = ref.watch(deviceStateProvider);
    return Scaffold(
      body: child,
      bottomNavigationBar: useFakeDevice
          ? SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          deviceState is ConnectedState ? Colors.green : null,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                    onPressed: () {
                      ref.read(deviceStateProvider.notifier).checkManually();
                    },
                    icon: deviceState is ConnectedState
                        ? Icon(Icons.circle)
                        : Icon(Icons.refresh),
                    label: deviceState is ConnectedState
                        ? Text('Connected')
                        : Text('Connect'),
                  ),
                  TextButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                    onPressed: () {
                      final controller =
                          ref.read(fakeDeviceEventStreamControllerProvider);
                      controller.add(
                        DeviceAction(
                            action: DeviceActionType.switchToNextMode,
                            time: DateTime.now()),
                      );
                    },
                    icon: Icon(Icons.arrow_upward),
                    label: Text('Next'),
                  ),
                  TextButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                    onLongPress: () {
                      final controller =
                          ref.read(fakeDeviceEventStreamControllerProvider);
                      controller.add(
                        DeviceAction(
                            action: DeviceActionType.longPress,
                            time: DateTime.now()),
                      );
                    },
                    onPressed: () async {
                      final controller =
                          ref.read(fakeDeviceEventStreamControllerProvider);
                      controller.add(
                        DeviceAction(
                            action: DeviceActionType.switchToPreviousMode,
                            time: DateTime.now()),
                      );
                    },
                    icon: Icon(Icons.arrow_downward),
                    label: Text('Previous'),
                  ),
                  TextButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                    onPressed: () {
                      final controller =
                          ref.read(fakeDeviceEventStreamControllerProvider);
                      controller.add(
                        DeviceAction(
                            action: DeviceActionType.capturePhoto,
                            time: DateTime.now()),
                      );
                    },
                    icon: Icon(Icons.camera),
                    label: Text('Capture'),
                  )
                ],
              ),
            )
          : null,
    );
  }
}
