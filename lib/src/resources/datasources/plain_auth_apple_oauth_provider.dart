import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plain_auth/plain_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class PlainAuthAppleOAuthProvider extends PlainAuthOAuthProvider {
  PlainAuthAppleOAuthProvider(
      {super.scopes = const ['email', 'name'], super.firebaseAuth});

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<UserCredential?> login() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    try {
      final scopes = <AppleIDAuthorizationScopes>[];
      for (final scope in super.scopes) {
        if (scope == 'email') {
          scopes.add(AppleIDAuthorizationScopes.email);
        } else if (scope == 'name') {
          scopes.add(AppleIDAuthorizationScopes.fullName);
        }
      }
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      firebaseAuth ??= FirebaseAuth.instance;

      try {
        return await super.firebaseAuth!.signInWithCredential(oauthCredential);
      } on FirebaseAuthException catch (e) {
        return await handleFirebaseAuthError(
            e: e,
            firebaseAuth: firebaseAuth!,
            provider: PlainAuthOAuthProviderType.apple);
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      return null;
    }
  }
}
