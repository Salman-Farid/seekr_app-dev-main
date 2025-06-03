import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = 'splash';
  static const routePath = '/splash';
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/icons/seekrLogo.png',
          width: size.width * .55,
        ),
      ),
    );
  }
}
