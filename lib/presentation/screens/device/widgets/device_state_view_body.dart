import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/device/socket_provider.dart';
import 'package:seekr_app/domain/device/device_info.dart';
import 'package:seekr_app/presentation/screens/device/widgets/device_command_listener_widget.dart';

class DeviceStateViewBody extends ConsumerWidget {
  final DeviceInfo deviceInfo;
  const DeviceStateViewBody({
    required this.deviceInfo,
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final socketState = ref.watch(socketProvider);
    return socketState.when(
        data: (socket) => DeviceCommandListener(socket: socket),
        error: (error, _) => const Center(
            child: Text('Error occurred when connecting to device')),
        loading: () =>
            const Center(child: Text('Connecting to device button clicks')));
  }
}
