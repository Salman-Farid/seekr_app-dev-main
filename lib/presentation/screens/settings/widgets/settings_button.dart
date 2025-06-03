import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/settings_provider.dart';

class SettingsButton extends ConsumerWidget {
  final String label;
  final String semanticLabel;
  final Widget action;
  const SettingsButton(
      {super.key,
      required this.label,
      required this.action,
      required this.semanticLabel});

  @override
  Widget build(BuildContext context, ref) {
    final textScale = ref.watch(settingsProvider).requireValue.textScale;
    return Semantics(
      explicitChildNodes: false,
      label: semanticLabel,
      // enabled: false,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: textScale <= 1.5
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  action
                ],
              )
            : Column(
                children: [
                  const Divider(),
                  ExcludeSemantics(
                    child: Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  action
                ],
              ),
      ),
    );
  }
}
