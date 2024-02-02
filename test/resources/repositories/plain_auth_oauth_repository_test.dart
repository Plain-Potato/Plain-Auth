import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plain_auth/plain_auth.dart';

class MockPlainAuthOAuthProvider extends Mock
    implements PlainAuthOAuthProvider {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('PlainAuthOAuthRepository', () {
    group('constructor', () {
      test('dose not require any parameters.', () {
        expect(PlainAuthOAuthRepository(), isNotNull);
      });
    });

    group('login()', () {
      test('oauthProvider.login() should be called once.', () async {
        final repository = PlainAuthOAuthRepository();
        final oauthProvider = MockPlainAuthOAuthProvider();

        when(() => oauthProvider.login()).thenAnswer((_) => Future(() => null));

        await repository.login(
            provider: PlainAuthOAuthProviderType.google,
            scopes: [PlainAuthOAuthProviderScope.name],
            oAuthProvider: oauthProvider);

        verify(() => oauthProvider.login()).called(1);
      });
    });

    group('logout()', () {
      test('firebaseAuth.singOut() should be called once', () async {
        final repository = PlainAuthOAuthRepository();
        final firebaseAuth = MockFirebaseAuth();
        when(() => firebaseAuth.signOut())
            .thenAnswer((_) => Future(() => null));
        await repository.logout(firebaseAuth: firebaseAuth);
        verify(() => firebaseAuth.signOut()).called(1);
      });
    });
  });
}
