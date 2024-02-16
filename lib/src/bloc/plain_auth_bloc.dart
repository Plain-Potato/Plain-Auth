import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:plain_auth/src/resources/datasources/plain_auth_oauth_provider.dart';

import '../resources/repositories/plain_auth_oauth_repository.dart';

part 'plain_auth_event.dart';

part 'plain_auth_state.dart';

class PlainAuthBloc extends HydratedBloc<PlainAuthEvent, PlainAuthState> {
  /*
  Constructor.
  */
  PlainAuthBloc({
    required PlainAuthOAuthRepository plainAuthOAuthRepository,
    required scopes,
    required this.firebaseAuth,
  })  : _repository = plainAuthOAuthRepository,
        _scopes = scopes,
        super(PlainAuthUnauthenticated()) {
    /*
    Register event listeners
     */
    on<PlainAuthLoginRequestedEvent>(_onLoginRequested);
    on<PlainAuthLogoutRequestedEvent>(_onLogoutRequested);
    on<_PlainAuthAuthenticationStateChangedEvent>(
        _onAuthenticationStateChanged);

    /*
    Listen to authStateChange event and add _PlainAuthAuthenticationStateChangedEvent with state accordingly.
     */
    firebaseAuth.authStateChanges().listen((User? user) async {
      if (user == null) {
        add(
          _PlainAuthAuthenticationStateChangedEvent(
            state: PlainAuthUnauthenticated(),
          ),
        );
      } else {
        if (user.photoURL == null) {
          await user.updatePhotoURL(
              'https://firebasestorage.googleapis.com/v0/b/plain-potato-412823.appspot.com/o/default_images%2Favatar.png?alt=media&token=b255ea7e-b59c-4dd8-81a5-2b9739f4c4e9');
        }
        if (user.displayName == null) {
          user.updateDisplayName(user.providerData[0].displayName);
        }
        if (state.runtimeType != PlainAuthAuthenticated) {
          add(
            _PlainAuthAuthenticationStateChangedEvent(
              state: PlainAuthAuthenticated(),
            ),
          );
        }
      }
    });
  }

  final PlainAuthOAuthRepository _repository;
  final List<PlainAuthOAuthProviderScope> _scopes;
  final FirebaseAuth firebaseAuth;

  /*
  Event listeners.
   */
  Future<void> _onLoginRequested(
      PlainAuthLoginRequestedEvent event, Emitter<PlainAuthState> emit) async {
    emit(PlainAuthUnauthenticated(loading: true));
    final user =
        await _repository.login(provider: event.provider, scopes: _scopes);
    if (user == null) {
      emit(PlainAuthUnauthenticated());
    }
  }

  void _onLogoutRequested(
      PlainAuthLogoutRequestedEvent event, Emitter<PlainAuthState> emit) {
    _repository.logout();
  }

  void _onAuthenticationStateChanged(
      _PlainAuthAuthenticationStateChangedEvent event,
      Emitter<PlainAuthState> emit) async {
    return emit(event.state);
  }

  /*
  Below are methods for storage use.
   */

  @override
  PlainAuthState? fromJson(Map<String, dynamic> json) {
    final state = json['state'];
    switch (state) {
      case 'PlainAuthAuthenticated':
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          return PlainAuthAuthenticated();
        } else {
          return PlainAuthUnauthenticated();
        }
      case 'PlainAuthUnauthenticated':
        return PlainAuthUnauthenticated();
    }
    return null;
  }

  @override
  Map<String, dynamic>? toJson(PlainAuthState state) {
    switch (state) {
      case PlainAuthAuthenticated():
        return {'state': 'PlainAuthAuthenticated'};
      case PlainAuthUnauthenticated():
        return {'state': 'PlainAuthUnauthenticated'};
    }
  }
}
