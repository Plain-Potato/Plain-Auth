part of 'plain_auth_bloc.dart';

sealed class PlainAuthEvent {}

final class PlainAuthLogoutRequestedEvent extends PlainAuthEvent {}

final class PlainAuthLoginRequestedEvent extends PlainAuthEvent {
  PlainAuthLoginRequestedEvent({required this.provider});

  final PlainAuthOAuthProviderType provider;
}
