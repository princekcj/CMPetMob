import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

Future<UserCredential?> signInWithFacebook() async {
  try {
    final LoginResult loginResult = await FacebookAuth.instance.login(permissions: ["public_profile", "email"]);

    print(loginResult.status);
    print(loginResult.accessToken!.token);

    if (loginResult.status == LoginStatus.success) {
      final AuthCredential credential = FacebookAuthProvider.credential(
        loginResult.accessToken!.token,
      );
      print(credential);
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
  } catch (error) {
    print('Facebook sign-in error: $error');
  }
  return null;
}
