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
      required this.firebaseAuth,
      this.onDeleteAccount})
      : _repository = plainAuthOAuthRepository,
        _scopes = scopes,
        super(const PlainAuthState()) {
    /*
    Register event listeners
     */
    on<PlainAuthLoginRequestEvent>(_onLoginRequested);
    on<PlainAuthLogoutRequestEvent>(_onLogoutRequested);
    on<_PlainAuthAuthenticationStateChangedEvent>(
        _onAuthenticationStateChanged);
    on<PlainAuthDeleteAccountRequestEvent>(_onDeleteAccountRequested);

    /*
    Listen to authStateChange event and add _PlainAuthAuthenticationStateChangedEvent with state accordingly.
     */
    firebaseAuth.authStateChanges().listen((User? user) async {
      if (user == null) {
        add(
          _PlainAuthAuthenticationStateChangedEvent(
            state: const PlainAuthState(authenticated: false),
          ),
        );
      } else {
        if (user.photoURL == null) {
          await user.updatePhotoURL(
              'https://firebasestorage.googleapis.com/v0/b/plain-potato-412823.appspot.com/o/default_images%2Favatar.png?alt=media&token=b255ea7e-b59c-4dd8-81a5-2b9739f4c4e9');
        }
        if (user.displayName == null) {
          await user.updateDisplayName('Plain Potato');
        }
        if (!state.authenticated) {
          add(
            _PlainAuthAuthenticationStateChangedEvent(
              state: const PlainAuthState(authenticated: true),
            ),
          );
        }
      }
    });
  }

  final PlainAuthOAuthRepository _repository;
  final List<PlainAuthOAuthProviderScope> _scopes;
  final FirebaseAuth firebaseAuth;
  final Future<void> Function(User)? onDeleteAccount;

  /*
  Event listeners.
   */
  Future<void> _onLoginRequested(
      PlainAuthLoginRequestEvent event, Emitter<PlainAuthState> emit) async {
    emit(const PlainAuthState(loading: true));
    final user =
        await _repository.login(provider: event.provider, scopes: _scopes);
    if (user == null) {
      emit(const PlainAuthState(loading: false));
    }
  }

  void _onLogoutRequested(
      PlainAuthLogoutRequestEvent event, Emitter<PlainAuthState> emit) {
    _repository.logout();
  }

  void _onAuthenticationStateChanged(
      _PlainAuthAuthenticationStateChangedEvent event,
      Emitter<PlainAuthState> emit) async {
    return emit(event.state);
  }

  _onDeleteAccountRequested(PlainAuthDeleteAccountRequestEvent event,
      Emitter<PlainAuthState> emit) async {
    if (firebaseAuth.currentUser == null) {
      throw PlainAuthDeleteAccountException(
          message: 'firebaseAuth.currentUser can not be null');
    }
    if (onDeleteAccount != null) {
      await onDeleteAccount!(firebaseAuth.currentUser!);
    }
    await firebaseAuth.currentUser?.delete();
  }

  /*
  Below are methods for storage use.
   */

  @override
  PlainAuthState? fromJson(Map<String, dynamic> json) {
    return PlainAuthState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(PlainAuthState state) {
    return state.toJson();
  }
}

class PlainAuthDeleteAccountException implements Exception {
  PlainAuthDeleteAccountException({required this.message});

  final String message;

  @override
  String toString() {
    return 'PlainAuthDeleteAccountException: $message';
  }
}
