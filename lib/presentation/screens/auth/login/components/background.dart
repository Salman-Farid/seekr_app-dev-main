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
              "assets/images/Ellipse_login_top.png",
              // width: size.width * 0.35,
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 0,
          child: ExcludeSemantics(
            child: Image.asset(
              "assets/images/Ellipse_login_bottom.png",
              // width: size.width * 0.25,
            ),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}
