import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OrDivider extends StatelessWidget {
  final String text;

  const OrDivider(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size.width * .3,
          child: Divider(
            height: 1,
            thickness: 1.5,
            color: Colors.grey[350],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            text,
            textAlign: TextAlign.end,
            style: TextStyle(
                fontFamily: "NeueMachina-Regular",
                // fontWeight: FontWeight.bold,
                fontSize: size.width * .041,
                color: const Color(0xff092E49)),
          ),
        ),
        SizedBox(
          width: size.width * .3,
          child: Divider(
            height: 1,
            thickness: 1.5,
            color: Colors.grey[350],
          ),
        )
      ],
    );
  }

  Expanded buildDivider() {
    return const Expanded(
      child: Divider(
        color: Color(0xFFD9D9D9),
        height: 1.5,
      ),
    );
  }
}
