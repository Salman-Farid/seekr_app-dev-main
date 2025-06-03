import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/audio_provider.dart';
import 'package:seekr_app/application/device/device_provider.dart';
import 'package:seekr_app/application/device/device_state.dart';
import 'package:seekr_app/application/device/socket_provider.dart';
import 'package:seekr_app/application/live_modes/device_live_camera_provider.dart';
import 'package:seekr_app/application/live_modes/processing_status_provider.dart';
import 'package:seekr_app/application/live_modes/text_detection/device_live_text_detection_provider.dart';
import 'package:seekr_app/application/session_provider.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/main.dart';
import 'package:seekr_app/presentation/screens/fake_device_wrapper.dart';
import 'package:seekr_app/presentation/screens/settings/widgets/confirm_exit_dialog.dart';

class RootPage extends HookConsumerWidget {
  static const routeName = 'root';
  static const routePath = '/';
  final StatefulNavigationShell navigationShell;
  const RootPage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, ref) {
    useEffect(() {
      final appLifecycleListener =
          AppLifecycleListener(onStateChange: (AppLifecycleState next) {
        final deviceState = ref.watch(deviceStateProvider);
        final deviceConnected = deviceState is ConnectedState;

        if (next == AppLifecycleState.paused && !deviceConnected) {
          Logger.i('AppLifecycleState.paused');
          ref.read(audioRepoProvider).stopTextToSpeech();
          ref.read(audioRepoProvider).stopBgMusic();
        } else if (next == AppLifecycleState.inactive && !deviceConnected) {
          Logger.i('AppLifecycleState.inactive');
          ref.read(audioRepoProvider).stopTextToSpeech();
          ref.read(audioRepoProvider).stopBgMusic();
        } else if (next == AppLifecycleState.hidden && !deviceConnected) {
          Logger.i('AppLifecycleState.hidden');
          ref.read(audioRepoProvider).stopTextToSpeech();
          ref.read(audioRepoProvider).stopBgMusic();
        } else if (next == AppLifecycleState.detached) {
          Logger.i('AppLifecycleState.detached');
          ref.read(audioRepoProvider).stopTextToSpeech();
          ref.read(audioRepoProvider).stopBgMusic();
        }
      });
      return () {
        appLifecycleListener.dispose();
      };
    }, const []);
    // ref.listen(appStateProvider, (previous, next) {
    // if (next == AppLifecycleState.resumed) {
    // } else if (next == AppLifecycleState.paused) {
    //   Logger.i('AppLifecycleState.paused');
    //   ref.read(audioRepoProvider).stopTextToSpeech();
    //   ref.read(audioRepoProvider).stopBgMusic();
    // } else if (next == AppLifecycleState.detached) {
    //   Logger.i('AppLifecycleState.detached');
    //   ref.read(audioRepoProvider).stopTextToSpeech();
    //   ref.read(audioRepoProvider).stopBgMusic();
    // } else if (next == AppLifecycleState.inactive) {
    //   Logger.i('AppLifecycleState.inactive');
    //   ref.read(audioRepoProvider).stopTextToSpeech();
    //   ref.read(audioRepoProvider).stopBgMusic();
    // } else if (next == AppLifecycleState.hidden) {
    //   Logger.i('AppLifecycleState.hidden');
    //   ref.read(audioRepoProvider).stopTextToSpeech();
    //   ref.read(audioRepoProvider).stopBgMusic();
    // }
    // });
    final voActivated = MediaQuery.of(context).accessibleNavigation;
    final sessionState = ref.watch(sessionProvider(voActivated));
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        showDialog(context: context, builder: (context) => ConfirmExitDialog());
      },
      child: FakeDeviceWrapper(
        child: Scaffold(
            body: GestureDetector(
              child: sessionState.maybeWhen(
                  orElse: () => navigationShell,
                  loading: () => const Center(
                        child: CircularProgressIndicator(),
                      )),
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
            ),
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
                  NavigationDestination(
                    icon: const Icon(Icons.chair_alt),
                    label: Words.of(context)!.aiAssistant,
                  ),
                  if (Platform.isIOS || useFakeDevice)
                    Semantics(
                      // excludeSemantics: navigationShell.currentIndex == 1,
                      label: navigationShell.currentIndex == 1
                          ? Words.of(context)!.deviceTabSelected
                          : Words.of(context)!.deviceTab,
                      child: NavigationDestination(
                        icon: const Icon(Icons.camera_rear_rounded),
                        label: Words.of(context)!.seekrDevice,
                      ),
                    ),
                  if (Platform.isIOS)
                    Semantics(
                      // excludeSemantics:
                      //     navigationShell.currentIndex == (Platform.isIOS ? 2 : 1),
                      label: 'Live Mode',
                      child: NavigationDestination(
                        icon: const Icon(Icons.energy_savings_leaf_outlined),
                        label: "Live",
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
                ],
                onDestinationSelected: (int index) {
                  ref.read(audioRepoProvider).stopTextToSpeech();
                  ref.read(audioRepoProvider).stopBgMusic();
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (index == 1 && Platform.isIOS) {
                    const backgroundChannel =
                        MethodChannel('background_channel/ios');
                    Future.microtask(() => backgroundChannel.invokeMethod(
                        'setSelectedMode', 'chat'));
                    Logger.i('setSelectedMode chat');
                  }

                  if (index == 2 && (Platform.isIOS || useFakeDevice)) {
                    ref.read(deviceStateProvider.notifier).checkManually();
                    ref
                        .read(audioRepoProvider)
                        .playText(text: Words.of(context)!.devicePage);
                  } else {
                    ref.invalidate(deviceStateProvider);
                    ref.invalidate(socketProvider);
                    ref.invalidate(deviceEventStreamProvider);
                    ref.invalidate(ensureDeviceCameraModeProvider);
                    ref.invalidate(deviceLiveTextDetectionProvider);
                    ref.invalidate(deviceCameraStreamProvider);
                    ref.read(processingProvider.notifier).stopProcessing();
                  }
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
              ),
            )),
      ),
    );
  }
}
