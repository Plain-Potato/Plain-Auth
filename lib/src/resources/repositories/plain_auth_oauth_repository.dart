import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../datasources/providers.dart';

class PlainAuthOAuthRepository {
  PlainAuthOAuthProvider _getOAuthProvider(
      {required PlainAuthOAuthProviderType provider,
      required List<PlainAuthOAuthProviderScope> scopes}) {
    late final PlainAuthOAuthProvider oAuthProvider;

    switch (provider) {
      case PlainAuthOAuthProviderType.google:
        final googleOAuthScopes = ['openid'];
        for (final s in scopes) {
          switch (s) {
            case PlainAuthOAuthProviderScope.email:
              googleOAuthScopes.add('email');
              break;
            case PlainAuthOAuthProviderScope.name:
              googleOAuthScopes.add('profile');
              break;
          }
        }
        oAuthProvider = PlainAuthGoogleOAuthProvider();
    }

    return oAuthProvider;
  }

  Future<UserCredential?> login(
      {required PlainAuthOAuthProviderType provider,
      required List<PlainAuthOAuthProviderScope> scopes,
      PlainAuthOAuthProvider? oAuthProvider}) async {
    final oauthProvider =
        oAuthProvider ?? _getOAuthProvider(provider: provider, scopes: scopes);
    return await oauthProvider.login();
  }

  Future<void> logout({FirebaseAuth? firebaseAuth}) async {
    final firebaseAuthInstance = firebaseAuth ?? FirebaseAuth.instance;
    await firebaseAuthInstance.signOut();
  }
}
