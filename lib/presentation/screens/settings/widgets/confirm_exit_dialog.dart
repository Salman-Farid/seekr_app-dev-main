import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seekr_app/localization/localization_type.dart';

class ConfirmExitDialog extends StatelessWidget {
  const ConfirmExitDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
      title: Text(
        'Seekr',
        style: TextStyle(
          fontFamily: "Rounded_Elegance",
          fontWeight: FontWeight.bold,
          fontSize: size.width * .055,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: Text(
          Words.of(context)!.wantToExitLabel,
          style: const TextStyle(
            fontFamily: "Rounded_Elegance",
            // fontWeight: FontWeight.bold
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Padding(
          padding: const EdgeInsets.only(bottom: 11.0),
          child: GestureDetector(
            onTap: () {
              exit(0);
            },
            child: Text(
              Words.of(context)!.yes,
              style: TextStyle(
                  fontFamily: 'Rounded_Elegance',
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * .045,
                  color: Colors.grey),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 11.0, left: 11),
          child: GestureDetector(
            onTap: () {
              context.pop();
            },
            child: Text(
              Words.of(context)!.no,
              style: TextStyle(
                  fontFamily: 'Rounded_Elegance',
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * .045,
                  color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
