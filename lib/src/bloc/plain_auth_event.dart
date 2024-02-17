part of 'plain_auth_bloc.dart';

sealed class PlainAuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class PlainAuthLogoutRequestEvent extends PlainAuthEvent {}

final class PlainAuthLoginRequestEvent extends PlainAuthEvent {
  PlainAuthLoginRequestEvent({required this.provider});

  final PlainAuthOAuthProviderType provider;
}

final class PlainAuthDeleteAccountRequestEvent extends PlainAuthEvent {}

final class _PlainAuthAuthenticationStateChangedEvent extends PlainAuthEvent {
  _PlainAuthAuthenticationStateChangedEvent({required this.state});

  final PlainAuthState state;
}
