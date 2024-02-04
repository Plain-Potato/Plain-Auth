import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plain_auth/plain_auth.dart';

class MockPlainAuthBloc extends MockBloc<PlainAuthEvent, PlainAuthState>
    implements PlainAuthBloc {}

void main() {
  group('PlainAuthOAuthLoginButton', () {
    const providerType = PlainAuthOAuthProviderType.google;

    testWidgets('renders properly.', (widgetTester) async {
      await widgetTester.pumpWidget(
        const MaterialApp(
          home: Material(
            child: PlainAuthOAuthLoginButton(provider: providerType),
          ),
        ),
      );

      final textFinder = find.text('socialLoginButtonText');
      final iconFinder = find.byWidgetPredicate((Widget widget) =>
          widget is FaIcon && widget.icon == providerType.icon);

      expect(textFinder, findsOneWidget);
      expect(iconFinder, findsOneWidget);
    });

    testWidgets('PlainAuthLoginRequestedEvent should be added when clicked.',
        (widgetTester) async {
      final mockBloc = MockPlainAuthBloc();
      when(() => mockBloc.state).thenReturn(PlainAuthUnauthenticated());
      when(() => mockBloc
              .add(PlainAuthLoginRequestedEvent(provider: providerType)))
          .thenAnswer((invocation) {});
      await widgetTester.pumpWidget(
        BlocProvider<PlainAuthBloc>(
          create: (_) => mockBloc,
          child: const MaterialApp(
            home: Scaffold(
              body: PlainAuthOAuthLoginButton(provider: providerType),
            ),
          ),
        ),
      );

      await widgetTester.pumpAndSettle();

      final finder = find.byKey(Key('${providerType.text} button'));
      await widgetTester.tap(finder);

      verify(() => mockBloc
          .add(PlainAuthLoginRequestedEvent(provider: providerType))).called(1);
    });
  });
}
