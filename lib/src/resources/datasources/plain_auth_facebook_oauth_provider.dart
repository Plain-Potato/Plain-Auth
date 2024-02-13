import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plain_auth/plain_auth.dart';

import 'plain_auth_oauth_provider.dart';

class PlainAuthFacebookLoginFailure implements Exception {
  PlainAuthFacebookLoginFailure([this.message, this.code]);

  final dynamic message;
  final dynamic code;

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return "PlainAuthFacebookLoginFailure";
    return "PlainAuthFacebookLoginFailure\nmessage: $message\ncode: $code";
  }
}

class PlainAuthFacebookOAuthProvider extends PlainAuthOAuthProvider {
  PlainAuthFacebookOAuthProvider(
      {super.scopes = const ['email', 'profile', 'openid'],
      FacebookAuth? facebookAuth,
      super.firebaseAuth})
      : _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  final FacebookAuth _facebookAuth;

  @override
  Future<UserCredential?> login() async {
    final LoginResult loginResult = await _facebookAuth.login();
    if (loginResult.accessToken == null) {
      return null;
    }
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);
    // final account = await _facebookAuth.signIn();
    //
    // if (account == null) {
    //   return null;
    //   // throw PlainAuthGoogleLoginFailure('GoogleSignInAccount is null');
    // }
    //
    // final GoogleSignInAuthentication googleSignInAuthentication =
    //     await account.authentication;
    //
    // final oauthCredential = GoogleAuthProvider.credential(
    //     accessToken: googleSignInAuthentication.accessToken,
    //     idToken: googleSignInAuthentication.idToken);
    //
    // firebaseAuth ??= FirebaseAuth.instance;
    //

    firebaseAuth ??= FirebaseAuth.instance;

    try {
      return await firebaseAuth!.signInWithCredential(facebookAuthCredential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        final signInMethods =
            await firebaseAuth!.fetchSignInMethodsForEmail(e.email!);
        final providerId = signInMethods[0];
        if (providerId == GoogleAuthProvider.PROVIDER_ID) {
          final credential = await PlainAuthGoogleOAuthProvider().login();
          if (credential != null) {
            return await credential.user!.linkWithCredential(e.credential!);
          }
        }
      }
      throw PlainAuthFacebookLoginFailure(e.message, e.code);
    }
  }
}
