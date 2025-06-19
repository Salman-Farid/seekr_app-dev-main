import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/device/device_provider.dart';
import 'package:seekr_app/application/device/museum/device_museum_provider.dart';
import 'package:seekr_app/application/settings_provider.dart';
import 'package:seekr_app/domain/device/device_action_type.dart';

class MuseumSelectionWidget extends HookConsumerWidget {
  final Socket socket;
  final AppLifecycleState? lifeCycleState;
  const MuseumSelectionWidget({
    super.key,
    required this.socket,
    required this.lifeCycleState,
  });

  @override
  Widget build(BuildContext context, ref) {
    final enableTTs = ref.watch(settingsProvider).requireValue.enableTTs;

    ref.listen(
      deviceEventStreamProvider(socket),
      (previous, next) {
        if (next.hasValue &&
            previous?.value != next.value &&
            lifeCycleState == AppLifecycleState.resumed) {
          final action = next.value!.action;

          switch (action) {
            case DeviceActionType.switchToNextMode:
              if (enableTTs) {
                ref.read(audioRepoProvider).playText(text: "YMCA museum");
              }

              break;
            case DeviceActionType.switchToPreviousMode:
              if (enableTTs) {
                ref.read(audioRepoProvider).playText(text: "YMCA museum");
              }
              break;
            case DeviceActionType.capturePhoto:
              if (enableTTs) {
                ref
                    .read(audioRepoProvider)
                    .playText(text: "YMCA museum selected");
              }
              ref.read(museumProvider.notifier).update((state) {
                return state.copyWith(
                  isMuseum: true,
                  museumName: () => "YMCA Museum",
                );
              });
              break;
            default:
              break;
          }
        }
      },
      onError: (error, stackTrace) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString()))),
    );

    final Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Text(
          "Please select a museum from the list:\n1. YMCA Museum",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Rounded_Elegance',
              fontSize: size.width * .065),
        ),
      ),
    );
  }
}
