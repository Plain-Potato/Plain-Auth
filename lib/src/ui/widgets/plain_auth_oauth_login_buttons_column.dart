import 'package:flutter/material.dart';
import 'package:plain_auth/plain_auth.dart';

class PlainAUthOAuthLoginButtonsColumn extends StatelessWidget {
  const PlainAUthOAuthLoginButtonsColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        PlainAuthOAuthLoginButton(
          provider: PlainAuthOAuthProviderType.google,
        ),
        SizedBox(
          height: 8,
        ),
        PlainAuthOAuthLoginButton(
          provider: PlainAuthOAuthProviderType.facebook,
        ),
        SizedBox(
          height: 8,
        ),
        PlainAuthOAuthLoginButton(
          provider: PlainAuthOAuthProviderType.apple,
        )
      ],
    );
  }
}
