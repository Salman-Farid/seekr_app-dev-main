import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final authProvider =
    StreamProvider<User?>((ref) => FirebaseAuth.instance.userChanges());
