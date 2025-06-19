import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/background_state_provider.dart';
import 'package:seekr_app/application/device/device_image_process_mode_provider.dart';
import 'package:seekr_app/application/device/device_provider.dart';
import 'package:seekr_app/application/device/device_state.dart';
import 'package:seekr_app/application/device/socket_provider.dart';
import 'package:seekr_app/application/settings_provider.dart';
import 'package:seekr_app/presentation/screens/device/widgets/device_state_view_body.dart';
import 'package:seekr_app/localization/localization_type.dart';

class DevicePage extends HookConsumerWidget {
  static const routeName = 'device';
  static const routePath = '/device';
  const DevicePage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final lifeCycleState = useAppLifecycleState();
    final state = ref.watch(deviceStateProvider);
    var size = MediaQuery.of(context).size;
    useOnAppLifecycleStateChange((previous, current) async {
      Logger.w('State changed from $previous to: $current');
      ref.read(appStateProvider.notifier).state = current;
      if (previous != current && current == AppLifecycleState.resumed) {
        ref.invalidate(socketProvider);
        ref.read(deviceImageProcessModeProvider.notifier).syncWithBgMode();
      }
    });
    final enableTTs = ref.watch(settingsProvider).requireValue.enableTTs;
    ref.listen(deviceStateProvider, (previous, next) {
      if (previous != next) {
        Logger.i('previous: $previous next: $next');
        if (next is ConnectedState && enableTTs) {
          if (lifeCycleState == AppLifecycleState.resumed) {
            ref.read(deviceStateProvider.notifier).checkManually();
          }
          if (previous is! UncheckedState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                Words.of(context)!.connectedToDevice,
              ),
              backgroundColor: Colors.green,
            ));
            if (enableTTs) {
              ref.read(audioRepoProvider).playText(text: 'Connected to device');
            }
          }
        } else if (next is DisconnectedState) {
          //Commented out this part of code because it's overlap with the background audio
          if (lifeCycleState == AppLifecycleState.resumed && enableTTs) {
            ref
                .read(audioRepoProvider)
                .playText(text: 'Disconnected from device');
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              Words.of(context)!.disconnectedFromDevice,
            ),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
    final words = Words.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            switch (state) {
              case ConnectedState():
                return Badge(
                  backgroundColor: Colors.green,
                  smallSize: 7,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                            onLongPress: () =>
                                ref.read(deviceRepoProvider).deleteAllPhotos(),
                            child:
                                const Icon(CupertinoIcons.camera_viewfinder)),
                        Text(Words.of(context)!.deviceButton),
                      ],
                    ),
                  ),
                );
              default:
                return const SizedBox.shrink();
            }
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Builder(builder: (context) {
        switch (state) {
          case ConnectedState():
            return ref.watch(ensureDeviceCameraModeProvider).when(
                data: (_) => Column(
                      children: [
                        SizedBox(
                          width: size.width,
                          child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 30),
                                  backgroundColor: Colors.purple.shade200,
                                  shape: const RoundedRectangleBorder(),
                                  foregroundColor: Colors.white,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      )),
                              onPressed: () async {
                                final statusCode = await ref
                                    .read(deviceRepoProvider)
                                    .getBatteryStatus();
                                final status = getStatus(statusCode, words);
                                if (status != null) {
                                  ref
                                      .read(audioRepoProvider)
                                      .playText(text: status);
                                }
                              },
                              icon: const Icon(Icons.battery_saver_sharp),
                              label: Text(Words.of(context)!.batteryStatus)),
                        ),
                        Expanded(
                            child: DeviceStateViewBody(
                                deviceInfo: state.deviceInfo)),
                      ],
                    ),
                error: (error, _) => Center(
                      child: Text(
                        'Something went wrong while device switching to photo mode,\n$error',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Rounded_Elegance',
                            fontSize: size.width * .065),
                      ),
                    ),
                loading: () => Center(
                        child: Text(
                      'Device switching to photo mode',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Rounded_Elegance',
                          fontSize: size.width * .065),
                    )));
          case DisconnectedState():
            return Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Words.of(context)!.deviceIsDisconnected,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Rounded_Elegance',
                      fontSize: size.width * .065),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    onPressed: () {
                      ref.read(deviceStateProvider.notifier).checkManually();
                    },
                    child: const Text('Try connecting to device'))
              ],
            ));
          case ErrorState():
            return Center(
              child: Text(
                'Error Occurred when testing device connect:\n${state.error}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Rounded_Elegance',
                    fontSize: size.width * .065),
              ),
            );
          case UncheckedState():
            return Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Words.of(context)!.deviceIsDisconnected,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Rounded_Elegance',
                      fontSize: size.width * .065),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    onPressed: () {
                      ref.read(deviceStateProvider.notifier).checkManually();
                    },
                    child: const Text('Try connecting to device'))
              ],
            ));
        }
      }),
    );
  }

  String? getStatus(int? statusCode, Words words) {
    switch (statusCode) {
      case 0:
        return words.deviceBattery100;
      case 1:
        return words.deviceBattery70;
      case 2:
        return words.deviceBattery50;
      case 3:
        return words.deviceBattery25;
      case 4:
        return words.deviceBatteryLow;
      case 5:
        return words.deviceBatteryCharging;
      default:
        return null;
    }
  }
}
