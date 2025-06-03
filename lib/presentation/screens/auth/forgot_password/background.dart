import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      height: size.height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              "assets/images/Ellipse_forgot_password_top.png",
              // width: size.width * 0.35,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              "assets/images/Ellipse_forgot_password_bottom.png",
              // width: size.width * 0.4,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
