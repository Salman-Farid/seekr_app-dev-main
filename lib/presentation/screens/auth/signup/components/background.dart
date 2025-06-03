import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          child: ExcludeSemantics(
            child: Image.asset(
              "assets/images/Ellipse_signup_top.png",
              // width: size.width * 0.35,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: ExcludeSemantics(
            child: Image.asset(
              "assets/images/Ellipse_signup_bottom.png",
              // width: size.width * 0.4,
            ),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}
