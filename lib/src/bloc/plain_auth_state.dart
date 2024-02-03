part of 'plain_auth_bloc.dart';

sealed class PlainAuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlainAuthAuthenticated extends PlainAuthState {
  PlainAuthAuthenticated({required this.user});

  final User user;
}

class PlainAuthUnauthenticated extends PlainAuthState {
  PlainAuthUnauthenticated({this.loading = false});

  final bool loading;
}
