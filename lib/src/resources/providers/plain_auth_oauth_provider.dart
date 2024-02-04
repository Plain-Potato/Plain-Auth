import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum PlainAuthOAuthProviderType { google }

extension PlainAuthOAuthProviderTypeExtension on PlainAuthOAuthProviderType {
  String get text {
    switch (this) {
      case PlainAuthOAuthProviderType.google:
        return 'GOOGLE';
    }
  }

  IconData get icon {
    switch (this) {
      case PlainAuthOAuthProviderType.google:
        return FontAwesomeIcons.google;
    }
  }
}

enum PlainAuthOAuthProviderScope { name, email }

abstract class PlainAuthOAuthProvider {
  PlainAuthOAuthProvider({required this.scopes, this.firebaseAuth});

  @protected
  final List<String> scopes;

  @protected
  FirebaseAuth? firebaseAuth;

  Future<UserCredential?> login();
}
