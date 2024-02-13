import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plain_auth/plain_auth.dart';

class PlainAUthOAuthLoginButtonsColumn extends StatelessWidget {
  const PlainAUthOAuthLoginButtonsColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PlainAuthOAuthLoginButton(
          provider: PlainAuthOAuthProviderType.google,
        ),
        const SizedBox(
          height: 8,
        ),
        const PlainAuthOAuthLoginButton(
          provider: PlainAuthOAuthProviderType.facebook,
        ),
        if (Platform.isIOS) ...[
          const SizedBox(
            height: 8,
          ),
          const PlainAuthOAuthLoginButton(
            provider: PlainAuthOAuthProviderType.apple,
          )
        ]
      ],
    );
  }
}
