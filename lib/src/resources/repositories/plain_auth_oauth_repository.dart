import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../providers/providers.dart';

class PlainAuthOAuthRepository {
  PlainAuthOAuthProvider _getOAuthProvider(
      {required PlainAuthOAuthProviderType provider,
      required List<PlainAuthOAuthProviderScope> scopes}) {
    late final PlainAuthOAuthProvider oauthProvider;

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
        oauthProvider = PlainAuthGoogleOAuthProvider();
    }

    return oauthProvider;
  }

  Future<UserCredential?> login(
      {required PlainAuthOAuthProviderType provider,
      required List<PlainAuthOAuthProviderScope> scopes}) async {
    final oauthProvider = _getOAuthProvider(provider: provider, scopes: scopes);
    return await oauthProvider.login();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
