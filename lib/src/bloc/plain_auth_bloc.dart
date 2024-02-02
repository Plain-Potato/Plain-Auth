import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:plain_auth/src/resources/providers/plain_auth_oauth_provider.dart';

import '../resources/repositories/plain_auth_oauth_repository.dart';

part 'plain_auth_event.dart';

part 'plain_auth_state.dart';

class PlainAuthBloc extends HydratedBloc<PlainAuthEvent, PlainAuthState> {
  PlainAuthBloc(
      {required PlainAuthOAuthRepository plainAuthOAuthRepository,
      required scopes})
      : _repository = plainAuthOAuthRepository,
        _scopes = scopes,
        super(PlainAuthUnauthenticated()) {
    on<PlainAuthLoginRequestedEvent>(_onLoginRequested);
    on<PlainAuthLogoutRequestedEvent>(_onLogoutRequested);
    on<_PlainAuthAuthenticationStateChangedEvent>(
        _onAuthenticationStateChanged);

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        add(_PlainAuthAuthenticationStateChangedEvent(
            state: PlainAuthUnauthenticated()));
      } else {
        add(_PlainAuthAuthenticationStateChangedEvent(
            state: PlainAuthAuthenticated()));
      }
    });
  }

  final PlainAuthOAuthRepository _repository;
  final List<PlainAuthOAuthProviderScope> _scopes;

  Future<void> _onLoginRequested(
      PlainAuthLoginRequestedEvent event, Emitter<PlainAuthState> emit) async {
    await _repository.login(provider: event.provider, scopes: _scopes);
  }

  void _onLogoutRequested(
      PlainAuthLogoutRequestedEvent event, Emitter<PlainAuthState> emit) {
    _repository.logout();
  }

  void _onAuthenticationStateChanged(
      _PlainAuthAuthenticationStateChangedEvent event,
      Emitter<PlainAuthState> emit) async {
    switch (event.state) {
      case PlainAuthAuthenticated():
        return emit(PlainAuthAuthenticated());
      case PlainAuthUnauthenticated():
        return emit(PlainAuthUnauthenticated());
    }
  }

  @override
  PlainAuthState? fromJson(Map<String, dynamic> json) {
    final state = json['state'];
    switch (state) {
      case 'PlainAuthAuthenticated':
        return PlainAuthAuthenticated();
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
