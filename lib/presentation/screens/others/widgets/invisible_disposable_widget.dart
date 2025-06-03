import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:visibility_detector/visibility_detector.dart';

class InvisibleDisposableWidget extends HookWidget {
  final Widget child;
  const InvisibleDisposableWidget({required super.key, required this.child})
      : assert(key != null);

  @override
  Widget build(BuildContext context) {
    final showChild = useState(true);
    return VisibilityDetector(
      key: super.key!,
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0) {
          showChild.value = false;
        } else {
          showChild.value = true;
        }
      },
      child: showChild.value ? child : const SizedBox.shrink(),
    );
  }
}
