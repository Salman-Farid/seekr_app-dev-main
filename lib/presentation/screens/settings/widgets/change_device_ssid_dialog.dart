import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seekr_app/application/device/device_provider.dart';
import 'package:seekr_app/localization/localization_type.dart';

class ChangeDeviceSSidDialog extends HookConsumerWidget {
  const ChangeDeviceSSidDialog({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final textController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return AlertDialog(
      title: Text(Words.of(context)!.changeDeviceName),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: textController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Invalid Name";
            }
            return null;
          },
          maxLines: 4,
          minLines: 1,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              try {
                await ref
                    .read(deviceRepoProvider)
                    .setWifiName(textController.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text(Words.of(context)!.restartDeviceChangeSSID)));

                  Navigator.of(context).pop();
                }
              } catch (e) {
                Logger.e("Error occured while changing device ssid: $e");
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          "Error occured while changing device ssid: $e")));
                  Navigator.of(context).pop();
                }
              }
            }
          },
          child: Text(Words.of(context)!.ok),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(Words.of(context)!.cancel),
        ),
      ],
    );
  }
}
