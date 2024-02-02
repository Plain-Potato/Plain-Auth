import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'plain_auth_oauth_provider.dart';

class PlainAuthGoogleLoginFailure implements Exception {
  PlainAuthGoogleLoginFailure([this.message]);

  final dynamic message;

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return "PlainAuthGoogleLoginFailure";
    return "PlainAuthGoogleLoginFailure: $message";
  }
}

class PlainAuthGoogleOAuthProvider extends PlainAuthOAuthProvider {
  PlainAuthGoogleOAuthProvider(
      {super.scopes = const ['email', 'profile', 'openid'],
      GoogleSignIn? googleSignIn,
      super.firebaseAuth})
      : _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: scopes);

  final GoogleSignIn _googleSignIn;

  @override
  Future<UserCredential?> login() async {
    final account = await _googleSignIn.signIn();

    if (account == null) {
      throw PlainAuthGoogleLoginFailure('GoogleSignInAccount is null');
    }

    final GoogleSignInAuthentication googleSignInAuthentication =
        await account.authentication;

    final oauthCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken);

    firebaseAuth ??= FirebaseAuth.instance;

    try {
      return await super.firebaseAuth!.signInWithCredential(oauthCredential);
    } on FirebaseAuthException catch (e) {
      throw PlainAuthGoogleLoginFailure(e.message);
    }
  }
}
