import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'plain_auth_oauth_provider.dart';

class PlainAuthGoogleOAuthProvider extends PlainAuthOAuthProvider {
  PlainAuthGoogleOAuthProvider(
      {super.scopes = const ['email', 'profile', 'openid']}) {
    _googleSignIn = GoogleSignIn(scopes: scopes);
  }

  late final GoogleSignIn _googleSignIn;

  @override
  Future<UserCredential?> login() async {
    try {
      final account = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await account?.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception catch (e) {
      if (kDebugMode) {
        print('PlainAuthGoogleOAuthProvider login error $e');
      }
    }
  }
}
