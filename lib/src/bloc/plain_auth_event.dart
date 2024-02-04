part of 'plain_auth_bloc.dart';

sealed class PlainAuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class PlainAuthLogoutRequestedEvent extends PlainAuthEvent {}

final class PlainAuthLoginRequestedEvent extends PlainAuthEvent {
  PlainAuthLoginRequestedEvent({required this.provider});

  final PlainAuthOAuthProviderType provider;
}

final class _PlainAuthAuthenticationStateChangedEvent extends PlainAuthEvent {
  _PlainAuthAuthenticationStateChangedEvent({required this.state});

  final PlainAuthState state;
}
