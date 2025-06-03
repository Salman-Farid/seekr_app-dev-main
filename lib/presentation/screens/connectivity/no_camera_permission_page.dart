import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/permission/permission_provider.dart';
import 'package:seekr_app/localization/localization_type.dart';

class NoCameraPermissionPage extends ConsumerWidget {
  static const routeName = 'no-camera-permission';
  static const routePath = '/no-camera-permission';
  const NoCameraPermissionPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final words = Words.of(context)!;

    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 50,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Semantics(
              label: words.requiredCameraPermission,
              child: Text(
                words.requiredCameraPermission,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Semantics(
            label: words.requestCameraPermission,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade200,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 10),
                    textStyle: Theme.of(context).textTheme.titleLarge,
                    elevation: 0,
                    shape: const RoundedRectangleBorder()),
                onPressed: () {
                  ref
                      .read(permissionProvider.notifier)
                      .forceAskForCameraPermission();
                },
                child: Text(words.requestCameraPermission)),
          )
        ],
      ),
    ));
  }
}
