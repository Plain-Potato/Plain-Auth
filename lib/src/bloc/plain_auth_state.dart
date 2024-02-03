part of 'plain_auth_bloc.dart';

sealed class PlainAuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlainAuthAuthenticated extends PlainAuthState {}

class PlainAuthUnauthenticated extends PlainAuthState {
  PlainAuthUnauthenticated({this.loading = false});

  final bool loading;
}
