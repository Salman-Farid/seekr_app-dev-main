import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      Logger.i(e.toString());
    }
    notifyListeners();
  }

  Future logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // FirebaseAuth.instance.signOut().whenComplete(() async => {
      // await googleSignIn.disconnect()
      // });
    } on FirebaseException catch (e) {
      Logger.i(e.message);
    }
  }
}
