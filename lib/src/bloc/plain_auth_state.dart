part of 'plain_auth_bloc.dart';

class PlainAuthState extends Equatable {
  const PlainAuthState({this.loading = false, this.authenticated = false});

  final bool loading;
  final bool authenticated;

  @override
  List<Object?> get props => [loading, authenticated];

  Map<String, dynamic> toJson() {
    return {'authenticated': authenticated, 'loading': loading};
  }

  factory PlainAuthState.fromJson(Map<String, dynamic> json) {
    return PlainAuthState(
        loading: json['loading'], authenticated: json['authenticated']);
  }
}
