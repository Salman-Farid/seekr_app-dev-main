import 'package:flutter/material.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/components/rounded_button.dart';
import 'package:seekr_app/presentation/screens/others/instructions.dart';

class InstructionsButton extends StatelessWidget {
  const InstructionsButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .1),
      child: RoundedButton(
        text: Words.of(context)!.howToUseSeekr,
        press: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const InstructionsScreen()));
        },
      ),
    );
  }
}
