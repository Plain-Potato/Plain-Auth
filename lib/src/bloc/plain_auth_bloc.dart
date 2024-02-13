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
  PlainAuthBloc(
      {required PlainAuthOAuthRepository plainAuthOAuthRepository,
      required scopes,
      FirebaseAuth? firebaseAuth})
      : _repository = plainAuthOAuthRepository,
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
    (firebaseAuth ?? FirebaseAuth.instance)
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        add(_PlainAuthAuthenticationStateChangedEvent(
            state: PlainAuthUnauthenticated()));
      } else {
        if (state.runtimeType != PlainAuthAuthenticated) {
          add(_PlainAuthAuthenticationStateChangedEvent(
              state: PlainAuthAuthenticated(user: user)));
        }
      }
    });
  }

  final PlainAuthOAuthRepository _repository;
  final List<PlainAuthOAuthProviderScope> _scopes;

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
          return PlainAuthAuthenticated(user: user);
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
