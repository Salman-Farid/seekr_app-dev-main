import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/permission/permission_provider.dart';
import 'package:seekr_app/application/permission/permission_state.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/screens/camera/widgets/camera_body.dart';

class CameraPage extends HookConsumerWidget {
  static const routeName = 'camera';
  static const routePath = '/camera';
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final permission =
        ref.watch(permissionProvider).requireValue.cameraPerission;
    final words = Words.of(context)!;

    switch (permission) {
      case PermissionResult.accepted:
        return const CameraBody();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    width: 200,
                    child: Text(
                      words.requiredCameraPermission,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                  ),
                  onPressed: () {
                    ref
                        .read(permissionProvider.notifier)
                        .forceAskForCameraPermission();
                  },
                  child: Text(words.requestCameraPermission))
            ],
          ),
        );
    }
  }
}
