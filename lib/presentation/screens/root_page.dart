import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/device/device_provider.dart';
import 'package:seekr_app/application/device/device_state.dart';
import 'package:seekr_app/application/device/socket_provider.dart';
import 'package:seekr_app/application/talker_provider.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/screens/fake_device_wrapper.dart';

class RootPage extends HookConsumerWidget {
  static const routeName = 'root';
  static const routePath = '/';
  final StatefulNavigationShell navigationShell;
  const RootPage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, ref) {
    final sessionState = ref.watch(sessionProvider);
    return FakeDeviceWrapper(
      child: Scaffold(
          body: sessionState.maybeWhen(
              orElse: () => navigationShell,
              loading: () => const Center(
                    child: CircularProgressIndicator(),
                  )),
          bottomNavigationBar: sessionState.maybeWhen(
            loading: () => null,
            orElse: () => NavigationBar(
              height: 80,
              selectedIndex: navigationShell.currentIndex,
              destinations: [
                Semantics(
                  // excludeSemantics: navigationShell.currentIndex == 0,
                  label: navigationShell.currentIndex == 0
                      ? Words.of(context)!.cameraTabSelected
                      : Words.of(context)!.cameraTab,
                  child: NavigationDestination(
                    icon: const Icon(Icons.camera_alt),
                    label: Words.of(context)!.cameraButton,
                  ),
                ),
                if (Platform.isIOS)
                  Semantics(
                    // excludeSemantics: navigationShell.currentIndex == 1,
                    label: navigationShell.currentIndex == 1
                        ? Words.of(context)!.deviceTabSelected
                        : Words.of(context)!.deviceTab,
                    child: NavigationDestination(
                      icon: const Icon(Icons.camera_rear_rounded),
                      label: Words.of(context)!.deviceButton,
                    ),
                  ),
                Semantics(
                  // excludeSemantics:
                  //     navigationShell.currentIndex == (Platform.isIOS ? 2 : 1),
                  label:
                      navigationShell.currentIndex == (Platform.isIOS ? 2 : 1)
                          ? Words.of(context)!.settingsTabSelected
                          : Words.of(context)!.settingsTab,
                  child: NavigationDestination(
                    icon: const Icon(Icons.settings),
                    label: Words.of(context)!.settingButton,
                  ),
                ),
                if (ref.watch(
                    deviceStateProvider.select((p) => p is ConnectedState)))
                  Semantics(
                    // excludeSemantics:
                    //     navigationShell.currentIndex == (Platform.isIOS ? 2 : 1),
                    label: "Bus Detection",
                    child: NavigationDestination(
                      icon: const Icon(Icons.bus_alert),
                      label: "Bus Detection",
                    ),
                  )
              ],
              onDestinationSelected: (int index) {
                if (index == 1 && Platform.isIOS) {
                  ref.read(deviceStateProvider.notifier).checkManually();
                  ref
                      .read(audioRepoProvider)
                      .playText(text: Words.of(context)!.devicePage);
                } else {
                  ref.invalidate(deviceStateProvider);
                  ref.invalidate(socketProvider);
                  ref.invalidate(deviceEventStreamProvider);
                  ref.invalidate(ensureDeviceCameraModeProvider);
                }
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
            ),
          )),
    );
  }
}
