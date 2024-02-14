import 'dart:convert';

import 'package:facebook_auth_desktop/facebook_auth_desktop.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:plain_auth/plain_auth.dart';

class PlainAuthFacebookOAuthProvider extends PlainAuthOAuthProvider {
  PlainAuthFacebookOAuthProvider(
      {super.scopes = const [], FacebookAuth? facebookAuth, super.firebaseAuth})
      : _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  final FacebookAuth _facebookAuth;
  late final FacebookAuthDesktopPlugin _plugin;

  @override
  Future<UserCredential?> login() async {
    final LoginResult loginResult;

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      _plugin = FacebookAuthDesktopPlugin();
      _plugin.webAndDesktopInitialize(
          appId: '3823348807877566',
          cookie: true,
          xfbml: true,
          version: 'v18.0');

      loginResult = await _plugin.login();
    } else {
      loginResult = await _facebookAuth.login();
    }

    if (loginResult.accessToken == null) {
      return null;
    }
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    firebaseAuth ??= FirebaseAuth.instance;

    try {
      return await firebaseAuth!.signInWithCredential(facebookAuthCredential);
    } on FirebaseAuthException catch (e) {
      return await handleFirebaseAuthError(
          e: e,
          firebaseAuth: firebaseAuth!,
          provider: PlainAuthOAuthProviderType.facebook);
    }
  }
}

String prettyPrint(Map json) {
  JsonEncoder encoder = const JsonEncoder.withIndent('  ');
  String pretty = encoder.convert(json);
  return pretty;
}
