import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plain_auth/plain_auth.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  late PlainAuthGoogleOAuthProvider plainAuthGoogleOAuthProvider;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
  });

  group('PlainAuthGoogleOAuthProvider', () {
    group('constructor', () {
      test('does not require scopes or googleSignIn or firebaseAuth', () {
        expect(PlainAuthGoogleOAuthProvider(), isNotNull);
      });
    });

    group('login()', () {
      test(
          'should return null when account is null and googleSignIn.signIn should be called once',
          () async {
        final googleSignIn = MockGoogleSignIn();
        when(() => googleSignIn.signIn()).thenAnswer((_) => Future(() => null));

        plainAuthGoogleOAuthProvider =
            PlainAuthGoogleOAuthProvider(googleSignIn: googleSignIn);

        expect(await plainAuthGoogleOAuthProvider.login(), null);
        verify(() => googleSignIn.signIn()).called(1);
      });

      test(
          'should throw PlainAuthLoginFailure when firebaseAuth.signInWithCredential throws FirebaseAuthException',
          () async {
        final googleSignIn = MockGoogleSignIn();
        final googleSignInAccount = MockGoogleSignInAccount();
        final googleSignInAuthentication = MockGoogleSignInAuthentication();
        final firebaseAuth = MockFirebaseAuth();

        when(() => googleSignIn.signIn())
            .thenAnswer((_) => Future(() => googleSignInAccount));
        when(() => googleSignInAccount.authentication)
            .thenAnswer((_) => Future(() => googleSignInAuthentication));
        when(() => googleSignInAuthentication.accessToken)
            .thenReturn('accessToken');
        when(() => googleSignInAuthentication.idToken).thenReturn('idToken');
        when(() => firebaseAuth.signInWithCredential(any()))
            .thenThrow(FirebaseAuthException(code: ''));

        plainAuthGoogleOAuthProvider = PlainAuthGoogleOAuthProvider(
            googleSignIn: googleSignIn, firebaseAuth: firebaseAuth);

        expect(() async => await plainAuthGoogleOAuthProvider.login(),
            throwsA(isA<PlainAuthLoginFailure>()));
      });
    });
  });
}
