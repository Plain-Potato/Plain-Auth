import 'package:firebase_auth/firebase_auth.dart';
import 'package:plain_auth/plain_auth.dart';

class PlainAuthAppleOAuthProvider extends PlainAuthOAuthProvider {
  PlainAuthAppleOAuthProvider(
      {super.scopes = const ['email', 'name'], super.firebaseAuth});

  @override
  Future<UserCredential?> login() async {
    AppleAuthProvider appleProvider = AppleAuthProvider();
    appleProvider = appleProvider.addScope('email');
    appleProvider = appleProvider.addScope('name');

    firebaseAuth ??= FirebaseAuth.instance;

    try {
      return await firebaseAuth!.signInWithProvider(appleProvider);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled' || e.code == 'web-context-canceled') {
        return null;
      }
      return await handleFirebaseAuthError(
        e: e,
        firebaseAuth: firebaseAuth!,
        provider: PlainAuthOAuthProviderType.apple,
      );
    }
  }
}
