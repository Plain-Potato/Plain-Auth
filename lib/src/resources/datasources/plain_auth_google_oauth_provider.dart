import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plain_auth/plain_auth.dart';

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
      return null;
      // throw PlainAuthGoogleLoginFailure('GoogleSignInAccount is null');
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
      if (e.code == 'account-exists-with-different-credential') {
        final signInMethods =
            await firebaseAuth!.fetchSignInMethodsForEmail(e.email!);
        final providerId = signInMethods[0];
        if (providerId == FacebookAuthProvider.PROVIDER_ID) {
          final credential = await PlainAuthFacebookOAuthProvider().login();
          if (credential != null) {
            return await credential.user!.linkWithCredential(e.credential!);
          }
        }
      }
      throw PlainAuthGoogleLoginFailure(e.message);
    }
  }
}
