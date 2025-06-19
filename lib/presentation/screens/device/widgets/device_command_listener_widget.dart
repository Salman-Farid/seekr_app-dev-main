import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/device/device_image_process_mode_provider.dart';
import 'package:seekr_app/application/device/museum/device_museum_provider.dart';
import 'package:seekr_app/application/device/device_provider.dart';
import 'package:seekr_app/application/device/museum/museum_state.dart';
import 'package:seekr_app/application/settings_provider.dart';
import 'package:seekr_app/domain/device/device_action_type.dart';
import 'package:seekr_app/domain/image_process/image_process_data.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/screens/device/widgets/device_image_process_widget.dart';
import 'package:seekr_app/presentation/screens/device/widgets/museum_selection.dart';

class DeviceCommandListener extends HookConsumerWidget {
  final Socket socket;
  const DeviceCommandListener({super.key, required this.socket});

  @override
  Widget build(BuildContext context, ref) {
    final lifeCycleState = useAppLifecycleState();
    final words = Words.of(context)!;
    var size = MediaQuery.of(context).size;
    useOnAppLifecycleStateChange((previous, current) async {
      if (current == AppLifecycleState.resumed && Platform.isIOS) {
        final modeName = ref.watch(
            deviceImageProcessModeProvider.select((value) => value.name));
        const backgroundChannel = MethodChannel('background_channel/ios');
        await backgroundChannel.invokeMethod('setSelectedMode', modeName);
      } else {
        ref.read(audioRepoProvider).stopBgMusic();
      }
    });
    final deviceState = ref.watch(deviceStateProvider);
    useEffect(() {
      if (Platform.isIOS) {
        Future.microtask(() async {
          final modeName = ref.watch(
              deviceImageProcessModeProvider.select((value) => value.name));
          const backgroundChannel = MethodChannel('background_channel/ios');
          await backgroundChannel.invokeMethod('setSelectedMode', modeName);
        });
      }
      return null;
    }, []);
    final enableTTs = ref.watch(settingsProvider).requireValue.enableTTs;

    ref.listen(deviceImageProcessModeProvider, (previous, next) async {
      if (previous != next && lifeCycleState == AppLifecycleState.resumed) {
        final museumState = ref.watch(museumProvider);

        if (next == ProcessType.text && !deviceState.isFake) {
          await ref.read(deviceRepoProvider).switchToHighResMode();
        } else if (previous == ProcessType.text && !deviceState.isFake) {
          await ref.read(deviceRepoProvider).switchToVGAResMode();
        }
        final modeAnnounce = getProcessTypeAnnouncements(next, words);
        ref.read(audioRepoProvider).stopTextToSpeech();
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(modeAnnounce)));
        }
        if (Platform.isIOS) {
          const backgroundChannel = MethodChannel('background_channel/ios');
          await backgroundChannel.invokeMethod('setSelectedMode', next.name);
        }
        if (enableTTs) {
          ref.read(audioRepoProvider).playText(
              text: next == ProcessType.museum &&
                      museumState.isMuseum &&
                      museumState.museumName != null
                  ? 'Mode switched to ${museumState.museumName} mode'
                  : modeAnnounce);
        }
        if (next == ProcessType.bus && context.mounted) {
          context.push('/device-bus');
        }
      }
    });
    ref.listen(
      deviceEventStreamProvider(socket),
      (previous, next) {
        if (next.hasValue &&
            previous?.value != next.value &&
            lifeCycleState == AppLifecycleState.resumed) {
          final action = next.value!.action;
          final museumState = ref.read(museumProvider);
          final canSwitchModes =
              !museumState.isMuseum || museumState.museumName != null;
          final canProcess =
              ref.read(deviceImageProcessModeProvider) != ProcessType.museum ||
                  (museumState.isMuseum && museumState.museumName != null);
          switch (action) {
            case DeviceActionType.switchToNextMode:
              if (canSwitchModes) {
                ref
                    .read(deviceImageProcessModeProvider.notifier)
                    .switchToNextType();
                ref.read(showDevImageProcessProvider.notifier).state = false;
                ref.read(audioRepoProvider).stopBgMusic();
                ref.read(audioRepoProvider).stopTextToSpeech();
              }

              break;
            case DeviceActionType.switchToPreviousMode:
              if (canSwitchModes) {
                ref
                    .read(deviceImageProcessModeProvider.notifier)
                    .switchToPreviousType();
                ref.read(showDevImageProcessProvider.notifier).state = false;
                ref.read(audioRepoProvider).stopBgMusic();
                ref.read(audioRepoProvider).stopTextToSpeech();
              }

              break;
            case DeviceActionType.capturePhoto:
              if (canProcess) {
                ref.read(showDevImageProcessProvider.notifier).state = true;
                ref.invalidate(devicePhotoProvider);
              }
            case DeviceActionType.longPress:
              if (ref.watch(deviceImageProcessModeProvider) ==
                      ProcessType.museum &&
                  !ref.read(showDevImageProcessProvider.notifier).state) {
                Logger.d(
                    "Museum mode long press ${ref.read(museumProvider).isMuseum}");
                if (museumState.isMuseum) {
                  if (enableTTs) {
                    ref
                        .read(audioRepoProvider)
                        .playText(text: "Museum mode deactivated");
                  }
                  ref.read(museumProvider.notifier).state =
                      const MuseumState(isMuseum: false, museumName: null);
                } else {
                  if (enableTTs) {
                    ref.read(audioRepoProvider).playText(
                        text:
                            "Museum mode activated, Please select a museum from the list");
                  }
                  ref.read(museumProvider.notifier).state =
                      const MuseumState(isMuseum: true);
                }
              }
              break;
            default:
              break;
          }
        }
      },
      onError: (error, stackTrace) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString()))),
    );
    final museumState = ref.watch(museumProvider);
    final deviceMode = ref.watch(deviceImageProcessModeProvider);
    return ref.watch(showDevImageProcessProvider)
        ? ref.watch(devicePhotoProvider).when(
            data: (data) => DeviceImageProcessWidget(
                imagePath: data.path,
                processType: ref.watch(deviceImageProcessModeProvider)),
            error: (error, _) => Center(
                  child: Text(error.toString()),
                ),
            loading: () => const Center(child: CircularProgressIndicator()))
        : museumState.isMuseum && museumState.museumName == null
            ? MuseumSelectionWidget(
                socket: socket,
                lifeCycleState: lifeCycleState,
              )
            : deviceMode == ProcessType.museum &&
                    museumState.isMuseum &&
                    museumState.museumName != null
                ? Center(
                    child: Text(
                      museumState.museumName!,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Rounded_Elegance',
                          fontSize: size.width * .065),
                    ),
                  )
                : Center(
                    child: Text(
                      deviceMode.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Rounded_Elegance',
                          fontSize: size.width * .065),
                    ),
                  );
  }
}

String getProcessTypeAnnouncements(ProcessType type, Words words) {
  switch (type) {
    case ProcessType.text:
      return words.textButtonDevice;
    case ProcessType.depth:
      return words.depthButtonDevice;
    case ProcessType.scene:
      return words.scenebuttonDevice;
    case ProcessType.supermarket:
      return words.superMarketModeDevice;
    case ProcessType.museum:
      return 'Mode switched to Museum detection';
    default:
      return 'Mode switched to ${type.name} detection';
  }
}
