import 'dart:async';

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
  }

  final PlainAuthOAuthRepository _repository;
  final List<PlainAuthOAuthProviderScope> _scopes;

  Future<void> _onLoginRequested(
      PlainAuthLoginRequestedEvent event, Emitter<PlainAuthState> emit) async {
    // emit(PlainAuthUnauthenticated(loading: true));
    final user =
        await _repository.login(provider: event.provider, scopes: _scopes);
    if (user != null) {
      emit(PlainAuthAuthenticated());
    }
  }

  void _onLogoutRequested(
      PlainAuthLogoutRequestedEvent event, Emitter<PlainAuthState> emit) {
    _repository.logout();
    emit(PlainAuthUnauthenticated());
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
