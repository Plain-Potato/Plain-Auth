import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'plain_auth_oauth_provider.dart';

class PlainAuthFacebookLoginFailure implements Exception {
  PlainAuthFacebookLoginFailure([this.message]);

  final dynamic message;

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return "PlainAuthFacebookLoginFailure";
    return "PlainAuthFacebookLoginFailure: $message";
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
    try {
      return await super
          .firebaseAuth!
          .signInWithCredential(facebookAuthCredential);
    } on FirebaseAuthException catch (e) {
      throw PlainAuthFacebookLoginFailure(e.message);
    }
  }
}
