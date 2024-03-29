import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plain_auth/src/bloc/plain_auth_bloc.dart';
import 'package:plain_auth/src/resources/datasources/plain_auth_oauth_provider.dart';

class PlainAuthOAuthLoginButton extends StatelessWidget {
  const PlainAuthOAuthLoginButton({super.key, required this.provider});

  final PlainAuthOAuthProviderType provider;

  @override
  Widget build(BuildContext context) {
    void onTap() {
      final plainAuthBloc = context.read<PlainAuthBloc>();
      if (!plainAuthBloc.state.authenticated) {
        if (plainAuthBloc.state.loading) {
          return;
        }
        plainAuthBloc.add(PlainAuthLoginRequestEvent(provider: provider));
      }
    }

    return InkWell(
      key: Key('${provider.text} button'),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 2,
            color: Theme.of(context).primaryColor,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 40,
                child: FaIcon(
                  provider.icon,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Center(
                  child: Text(
                'socialLoginButtonText',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Theme.of(context).primaryColor,
                ),
              ).tr(namedArgs: {'provider': provider.text})),
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
