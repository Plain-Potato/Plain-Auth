import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plain_auth/plain_auth.dart';

class MockPlainAuthBloc extends MockBloc<PlainAuthEvent, PlainAuthState>
    implements PlainAuthBloc {}

class MockPlainOAuthRepository extends Mock
    implements PlainAuthOAuthRepository {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockStorage extends Mock implements Storage {}

class MockStream extends Mock implements Stream<User?> {}

class MockStreamSubscription extends Mock
    implements StreamSubscription<User?> {}

class MockPlainAuthOAuthProvider extends Mock
    implements PlainAuthOAuthProvider {}

class MockUser extends Mock implements User {}

class FakeUserCredential extends Fake implements UserCredential {}

void main() {
  group('PlainAuthBloc', () {
    const scopes = [
      PlainAuthOAuthProviderScope.name,
      PlainAuthOAuthProviderScope.email
    ];
    late MockPlainOAuthRepository repository;
    late Storage storage;
    late FirebaseAuth firebaseAuth;
    late MockStream stream;
    late MockStreamSubscription streamSubscription;
    late User user;

    setUp(() {
      repository = MockPlainOAuthRepository();
      storage = MockStorage();
      firebaseAuth = MockFirebaseAuth();
      stream = MockStream();
      streamSubscription = MockStreamSubscription();
      user = MockUser();

      when(() => user.displayName).thenReturn('');
      when(() => user.photoURL).thenReturn('');

      when(
        () => storage.write(any(), any<dynamic>()),
      ).thenAnswer((_) async {});

      when(() => stream.listen(any())).thenAnswer((_) => streamSubscription);

      when(() => firebaseAuth.authStateChanges()).thenAnswer((_) => stream);

      when(() => repository.login(
              provider: PlainAuthOAuthProviderType.google, scopes: scopes))
          .thenAnswer((_) => Future(() => FakeUserCredential()));

      when(() => repository.logout()).thenAnswer((_) => Future(() => null));

      HydratedBloc.storage = storage;
    });

    blocTest('initial state should be Unauthenticated.',
        build: () => PlainAuthBloc(
              plainAuthOAuthRepository: repository,
              scopes: scopes,
              firebaseAuth: firebaseAuth,
            ),
        verify: (bloc) {
          expect(bloc.state, PlainAuthUnauthenticated());
        });

    blocTest(
      'should emit [] when nothing is added.',
      build: () => PlainAuthBloc(
        plainAuthOAuthRepository: repository,
        scopes: scopes,
        firebaseAuth: firebaseAuth,
      ),
      expect: () => [],
    );

    blocTest(
        'repository.login() should be called once when PlainAuthLoginRequestedEvent added.',
        build: () => PlainAuthBloc(
              plainAuthOAuthRepository: repository,
              scopes: scopes,
              firebaseAuth: firebaseAuth,
            ),
        act: (bloc) => bloc.add(PlainAuthLoginRequestEvent(
              provider: PlainAuthOAuthProviderType.google,
            )),
        verify: (_) {
          verify(() => repository.login(
              provider: PlainAuthOAuthProviderType.google,
              scopes: scopes)).called(1);
        });

    blocTest(
        'repository.logout() should be called once when PlainAuthLogoutRequestedEvent added.',
        build: () => PlainAuthBloc(
              plainAuthOAuthRepository: repository,
              scopes: scopes,
              firebaseAuth: firebaseAuth,
            ),
        act: (bloc) => bloc.add(PlainAuthLogoutRequestEvent()),
        verify: (_) {
          verify(() => repository.logout()).called(1);
        });

    blocTest(
      'should emit [PlainAuthAuthenticated()] when auth state changes that user is not null.',
      build: () => PlainAuthBloc(
        plainAuthOAuthRepository: repository,
        scopes: scopes,
        firebaseAuth: firebaseAuth,
      ),
      setUp: () {
        Stream<User?> streamFunc() async* {
          yield user;
        }

        when(() => firebaseAuth.authStateChanges())
            .thenAnswer((_) => streamFunc());
      },
      expect: () => [PlainAuthAuthenticated()],
    );

    blocTest(
      'should emit [PlainAuthAuthenticated(), PlainAuthUnauthenticated()] when auth state changes that user is null and user is not null.',
      build: () => PlainAuthBloc(
        plainAuthOAuthRepository: repository,
        scopes: scopes,
        firebaseAuth: firebaseAuth,
      ),
      setUp: () {
        Stream<User?> streamFunc() async* {
          yield user;
          yield null;
        }

        when(() => firebaseAuth.authStateChanges())
            .thenAnswer((_) => streamFunc());
      },
      expect: () => [PlainAuthAuthenticated(), PlainAuthUnauthenticated()],
    );

    blocTest(
      'should emit [PlainAuthAuthenticated()] when auth state changes that user is not null twice.',
      build: () => PlainAuthBloc(
        plainAuthOAuthRepository: repository,
        scopes: scopes,
        firebaseAuth: firebaseAuth,
      ),
      setUp: () {
        Stream<User?> streamFunc() async* {
          yield user;
          yield user;
        }

        when(() => firebaseAuth.authStateChanges())
            .thenAnswer((_) => streamFunc());
      },
      expect: () => [PlainAuthAuthenticated()],
    );

    blocTest(
      'should emit [PlainAuthAuthenticated(), PlainAuthUnAuthenticated()] when auth state changes that user is null twice.',
      build: () => PlainAuthBloc(
        plainAuthOAuthRepository: repository,
        scopes: scopes,
        firebaseAuth: firebaseAuth,
      ),
      setUp: () {
        Stream<User?> streamFunc() async* {
          yield user;
          yield null;
          yield null;
        }

        when(() => firebaseAuth.authStateChanges())
            .thenAnswer((_) => streamFunc());
      },
      expect: () => [PlainAuthAuthenticated(), PlainAuthUnauthenticated()],
    );
  });
}
