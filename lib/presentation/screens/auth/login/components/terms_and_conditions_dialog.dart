import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/components/rounded_button.dart';

class TermsAndConditionsDialog extends StatelessWidget {
  const TermsAndConditionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return AlertDialog(
      backgroundColor: const Color(0xff01A0C7),
      title: Semantics(
        child: Text(
          Words.of(context)!.termsAndCondition,
          style: TextStyle(
              fontSize: size.width * .055,
              color: Colors.black,
              fontFamily: "Rounded_Elegance",
              fontWeight: FontWeight.bold),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Semantics(
              sortKey: const OrdinalSortKey(1),
                child: Text(
                  Words.of(context)!.termsAndConditionText,
                  style: TextStyle(
                      fontSize: size.width * .035,
                      color: Colors.white,
                      fontFamily: "Rounded_Elegance",
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 51,
          ),
          Center(
            child: SizedBox(
              width: size.width * .35,
              child: Semantics(
                sortKey: const OrdinalSortKey(2),
                child: RoundedButton(
                  text: Words.of(context)!.agree,
                  press: () {
                    Navigator.of(context).pop(true);
                  },
                  color: const Color(0xff000000),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Center(
            child: SizedBox(
              width: size.width * .35,
              child: Semantics(
                sortKey: const OrdinalSortKey(3),
                child: RoundedButton(
                  text: Words.of(context)!.cancel,
                  press: () {
                    Navigator.of(context).pop(false);
                  },
                  color: const Color(0xff000000),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
