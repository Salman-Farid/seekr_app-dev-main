import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seekr_app/presentation/screens/auth/login/components/login_screen_body.dart';
import 'package:seekr_app/presentation/screens/camera/camera_page.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = 'login';
  static const routePath = '/login';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FocusScope(
        canRequestFocus: true,
        child: GestureDetector(
          onTap: () {
            // Clear focus when tapping outside of text fields
            FocusScope.of(context).unfocus();
          },
          child: StreamBuilder(
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
                  return const LoginScreenBody();
                }
              }),
        ),
      ),
    );
  }
}
