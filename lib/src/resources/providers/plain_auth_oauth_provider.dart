import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum PlainAuthOAuthProviderType { google }

enum PlainAuthOAuthProviderScope { name, email }

abstract class PlainAuthOAuthProvider {
  PlainAuthOAuthProvider({required this.scopes});

  @protected
  final List<String> scopes;

  Future<UserCredential?> login();
}
