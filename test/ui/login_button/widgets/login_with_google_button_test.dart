import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/login_button/bloc/login_bloc.dart';
import 'package:journexa_app/ui/login_button/widgets/login_with_google_button.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/loading_indicator.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockLoginBloc extends Mock implements LoginBloc {}

const expectedTranslations = {
  'en': {
    'label': 'Login with Google',
  },
  'id': {
    'label': 'Masuk dengan Google',
  },
};

void main() {
  final LoginBloc mockLoginBloc = MockLoginBloc();

  setUp(() {
    whenListen(
      mockLoginBloc,
      Stream.value(const LoginState.initial()),
      initialState: const LoginState.initial(),
    );
  });

  tearDown(() {
    reset(mockLoginBloc);
  });

  Future<void> pumpWidget({
    required WidgetTester tester,
    required Locale locale,
    VoidCallback? onSuccess,
  }) async {
    return pumpForWidgetTest(
      tester,
      widget: BlocProvider.value(
        value: mockLoginBloc,
        child: LoginWithGoogleButton(
          onSuccess: onSuccess,
        ),
      ),
      locale: locale,
    );
  }

  group('Render', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedLabel =
          expectedTranslations[locale.languageCode]!['label']!;
      testWidgets('shows "$expectedLabel" for $locale', (tester) async {
        await pumpWidget(tester: tester, locale: locale);

        expect(find.text(expectedLabel), findsOneWidget);
      });
    }

    testWidgets('shows LoadingIndicator when state is loading', (tester) async {
      when(() => mockLoginBloc.state).thenReturn(const LoginState.loading());
      await pumpWidget(tester: tester, locale: const Locale('en'));

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('disabled when state is loading', (tester) async {
      when(() => mockLoginBloc.state).thenReturn(const LoginState.loading());
      await pumpWidget(tester: tester, locale: const Locale('en'));

      final button = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      expect(button.enabled, false);
    });
  });

  group('Interaction', () {
    testWidgets(
      'adding LoginEvent.loginWithGoogle() when pressed',
      (tester) async {
        when(() => mockLoginBloc.state).thenReturn(const LoginState.initial());
        await pumpWidget(tester: tester, locale: const Locale('en'));

        await tester.tap(find.byType(LoginWithGoogleButton));

        verify(
          () => mockLoginBloc.add(const LoginEvent.loginWithGoogle()),
        ).called(1);
      },
    );
  });

  group('Side Effects', () {
    testWidgets(
      'calls onSuccess when login with Google is suceeded',
      (tester) async {
        whenListen(
          mockLoginBloc,
          Stream.fromIterable([
            const LoginState.loading(),
            const LoginState.success(),
          ]),
        );

        var isSucceeded = false;
        await pumpWidget(
          tester: tester,
          locale: const Locale('en'),
          onSuccess: () => isSucceeded = true,
        );

        await tester.pumpAndSettle();

        expect(isSucceeded, true);
      },
    );
  });

  group('a11y', () {
    testWidgets('follows a11y guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpWidget(tester: tester, locale: const Locale('en'));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });

    for (final locale in AppLocalizations.supportedLocales) {
      final expectedLabel =
          expectedTranslations[locale.languageCode]!['label']!;
      testWidgets(
        'has semantic label "$expectedLabel" for $locale',
        (tester) async {
          final handle = tester.ensureSemantics();
          await pumpWidget(tester: tester, locale: locale);

          expect(find.bySemanticsLabel(expectedLabel), findsOneWidget);

          handle.dispose();
        },
      );
    }
  });
}
