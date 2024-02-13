import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plain_auth/plain_auth.dart';

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
      return await handleFirebaseAuthError(
          e: e,
          firebaseAuth: firebaseAuth!,
          provider: PlainAuthOAuthProviderType.google);
    }
  }
}
