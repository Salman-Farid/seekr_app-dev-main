import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/settings_provider.dart';

class ImageProcessButton extends ConsumerWidget {
  final Image image;
  final String label;
  final void Function() onTap;

  const ImageProcessButton({
    super.key,
    required this.image,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, ref) {
    final cameraView =
        ref.watch(settingsProvider).valueOrNull?.cameraView ?? true;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: cameraView ? 30 : 40,
            backgroundColor: const Color(0xff01A0C7),
            child: image,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: cameraView ? Colors.black : Colors.black,
                fontSize: cameraView ? null : 24,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
