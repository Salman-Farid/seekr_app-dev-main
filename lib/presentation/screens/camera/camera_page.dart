import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/permission/permission_provider.dart';
import 'package:seekr_app/application/permission/permission_state.dart';
import 'package:seekr_app/presentation/screens/camera/widgets/camera_body.dart';
import 'package:seekr_app/presentation/screens/camera/widgets/no_camera_permission_view.dart';

class CameraPage extends HookConsumerWidget {
  static const routeName = 'camera';
  static const routePath = '/camera';
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final permission =
        ref.watch(permissionProvider).requireValue.cameraPerission;
    switch (permission) {
      case PermissionResult.accepted:
        return const CameraBody();
      default:
        return NoCameraPermissionView();
    }
  }
}
