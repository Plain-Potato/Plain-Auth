import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plain_auth/plain_auth.dart';

enum PlainAuthOAuthProviderType { google, facebook, apple }

extension PlainAuthOAuthProviderTypeExtension on PlainAuthOAuthProviderType {
  String get text {
    switch (this) {
      case PlainAuthOAuthProviderType.google:
        return 'GOOGLE';
      case PlainAuthOAuthProviderType.facebook:
        return 'FACEBOOK';
      case PlainAuthOAuthProviderType.apple:
        return 'APPLE';
    }
  }

  IconData get icon {
    switch (this) {
      case PlainAuthOAuthProviderType.google:
        return FontAwesomeIcons.google;
      case PlainAuthOAuthProviderType.facebook:
        return FontAwesomeIcons.facebook;
      case PlainAuthOAuthProviderType.apple:
        return FontAwesomeIcons.apple;
    }
  }
}

enum PlainAuthOAuthProviderScope { name, email }

abstract class PlainAuthOAuthProvider {
  PlainAuthOAuthProvider({required this.scopes, this.firebaseAuth});

  @protected
  final List<String> scopes;

  @protected
  FirebaseAuth? firebaseAuth;

  Future<UserCredential?> login();
}

class PlainAuthLoginFailure implements Exception {
  PlainAuthLoginFailure({required this.provider, this.message, this.code});

  final PlainAuthOAuthProviderType provider;
  final String? message;
  final String? code;

  @override
  String toString() {
    Object? message = this.message;
    return "PlainAuthLoginFailure\nprovider: $provider\nmessage: $message\ncode: $code";
  }
}

Future<UserCredential?> handleFirebaseAuthError({
  required FirebaseAuthException e,
  required FirebaseAuth firebaseAuth,
  required PlainAuthOAuthProviderType provider,
}) async {
  if (e.code == 'account-exists-with-different-credential') {
    final signInMethods =
        await firebaseAuth.fetchSignInMethodsForEmail(e.email!);
    final providerId = signInMethods[0];
    UserCredential? credential;

    if (providerId == FacebookAuthProvider.PROVIDER_ID) {
      credential = await PlainAuthFacebookOAuthProvider().login();
    } else if (providerId == GoogleAuthProvider.PROVIDER_ID) {
      credential = await PlainAuthGoogleOAuthProvider().login();
    }

    if (credential != null) {
      return await credential.user!.linkWithCredential(e.credential!);
    }
  }
  throw PlainAuthLoginFailure(
    message: e.message,
    code: e.code,
    provider: provider,
  );
}
