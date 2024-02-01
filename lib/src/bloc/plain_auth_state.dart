part of 'plain_auth_bloc.dart';

sealed class PlainAuthState {}

class PlainAuthAuthenticated extends PlainAuthState {}

class PlainAuthUnauthenticated extends PlainAuthState {
  PlainAuthUnauthenticated({this.loading = false});

  final bool loading;
}
