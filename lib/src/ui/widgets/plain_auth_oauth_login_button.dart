import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plain_auth/src/bloc/plain_auth_bloc.dart';
import 'package:plain_auth/src/resources/providers/plain_auth_oauth_provider.dart';

class PlainAuthOAuthLoginButton extends StatelessWidget {
  const PlainAuthOAuthLoginButton({super.key, required this.provider});

  final PlainAuthOAuthProviderType provider;

  String _getProviderText() {
    switch (provider) {
      case PlainAuthOAuthProviderType.google:
        return 'GOOGLE';
    }
  }

  IconData _getIcon() {
    switch (provider) {
      case PlainAuthOAuthProviderType.google:
        return FontAwesomeIcons.google;
    }
  }

  @override
  Widget build(BuildContext context) {
    void onTap() {
      final plainAuthBloc = context.read<PlainAuthBloc>();
      if (plainAuthBloc.state is PlainAuthUnauthenticated) {
        if ((plainAuthBloc.state as PlainAuthUnauthenticated).loading) {
          return;
        }
      }

      plainAuthBloc.add(PlainAuthLoginRequestedEvent(provider: provider));
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 40,
                child: FaIcon(_getIcon()),
              ),
              Center(
                  child: const Text(
                'socialLoginButtonText',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ).tr(namedArgs: {'provider': _getProviderText()})),
              const SizedBox(
                width: 40,
              )
            ],
          ),
        ),
      ),
    );
  }
}
