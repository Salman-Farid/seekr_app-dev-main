import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seekr_app/presentation/screens/camera/camera_page.dart';
// import 'package:seekr_app/presentation/screens/navigation_bar.dart';
import 'components/body.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(CameraPage.routePath);
              });
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong!"));
            } else {
              return const SignupBody();
            }
          }),
    );
  }
}
