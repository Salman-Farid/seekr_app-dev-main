import 'package:flutter/material.dart';
import 'package:seekr_app/infrastructure/constants.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback press;
  final Color color, textColor;
  final bool loading;
  const RoundedButton(
      {super.key,
      required this.text,
      required this.press,
      this.color = kPrimaryColor,
      this.textColor = Colors.white,
      this.loading = false});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: press,
      child: Container(
        // height: size.width * .135,
        width: size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100), color: color),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(size.width * .045),
            child: loading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * .045,
                        fontFamily: 'Arista-Pro-Alternate-Light-trial'),
                  ),
          ),
        ),
      ),
    );
  }

  //Used:ElevatedButton as FlatButton is deprecated.
  //Here we have to apply customizations to Button by inheriting the styleFrom

  Widget newElevatedButton() {
    return ElevatedButton(
      onPressed: press,
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          textStyle: TextStyle(
              color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
