import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/permission/permission_provider.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/screens/others/widgets/permission_button.dart';

class PermissionScreen extends HookConsumerWidget {
  static const routeName = 'permission';
  static const routePath = '/permission';
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final permissionState = ref.watch(permissionProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Colors.white,
        body: permissionState.when(
            data: (data) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/icons/seekrLogo.png',
                        width: size.width * .55,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    PermissionButton(
                      icon: Icons.camera_alt,
                      semanticsLabel:
                          Words.of(context)!.grantCameraAccessSemantic,
                      result: data.cameraPerission,
                      label: Words.of(context)!.grantCameraAccessLabel,
                      onTap: () {
                        ref
                            .read(permissionProvider.notifier)
                            .askForCameraPermission();
                      },
                    ),
                    PermissionButton(
                      icon: Icons.mic,
                      semanticsLabel:
                          Words.of(context)!.grantMicrophoneAccessSemantic,
                      result: data.microphonePermission,
                      label: Words.of(context)!.grantMicrophoneAccessLabel,
                      onTap: () {
                        ref
                            .read(permissionProvider.notifier)
                            .askForMicrophonePermission();
                      },
                    ),
                    PermissionButton(
                      icon: Icons.folder,
                      semanticsLabel:
                          Words.of(context)!.grantStorageAccessSemantic,
                      result: data.storagePermission,
                      label: Words.of(context)!.grantStorageAccessLabel,
                      onTap: () {
                        ref
                            .read(permissionProvider.notifier)
                            .askForStoragePermission();
                      },
                    ),
                    PermissionButton(
                      icon: Icons.map_outlined,
                      semanticsLabel:
                          Words.of(context)!.grantLocationAccessSemantic,
                      result: data.locationPermission,
                      label: Words.of(context)!.grantLocationAccessLabel,
                      onTap: () {
                        ref
                            .read(permissionProvider.notifier)
                            .askForLocationPermission();
                      },
                    ),
                  ],
                ),
            error: (error, _) => Center(child: Text(error.toString())),
            loading: () => const Center(
                  child: CircularProgressIndicator(),
                )));
  }
}
