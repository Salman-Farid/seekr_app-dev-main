import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/permission/permission_provider.dart';
import 'package:seekr_app/localization/localization_type.dart';

class NoCameraPermissionView extends HookConsumerWidget {
  const NoCameraPermissionView({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final words = Words.of(context)!;

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
