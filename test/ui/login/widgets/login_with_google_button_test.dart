import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/login/bloc/login_bloc.dart';
import 'package:journexa_app/ui/login/widgets/login_with_google_button.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_toast.dart';
import 'package:journexa_app/ui/shared/widgets/loading_indicator.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockLoginBloc extends Mock implements LoginBloc {}

const expectedTranslations = {
  'en': {
    'label': 'Login with Google',
    'loginSuccessTitle': 'Login successful',
    'loginSuccessMessage': 'Redirecting to initialization process...',
    'loginFailedTitle': 'Login failed',
    'errorInternalException': 'Internal exception error',
    'errorLoginCanceled': 'Login process was cancelled',
  },
  'id': {
    'label': 'Masuk dengan Google',
    'loginSuccessTitle': 'Login berhasil',
    'loginSuccessMessage': 'Mengarahkan ke proses inisialisasi...',
    'loginFailedTitle': 'Login gagal',
    'errorInternalException': 'Terjadi kesalahan internal',
    'errorLoginCanceled': 'Proses login dibatalkan',
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

    testWidgets(
      'shows Google icon when state is not loading',
      (tester) async {
        await pumpWidget(tester: tester, locale: const Locale('en'));

        final icon = tester.widget<SvgPicture>(find.byType(SvgPicture));
        expect(
          icon.bytesLoader,
          isA<SvgAssetLoader>().having(
            (e) => e.assetName,
            'assetName',
            'assets/icons/google.svg',
          ),
        );
      },
    );
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

        await tester.pumpAndSettle(kToastDuration);
      },
    );

    for (final locale in AppLocalizations.supportedLocales) {
      final translations = expectedTranslations[locale.languageCode]!;
      final expectedSuccessTitle = translations['loginSuccessTitle']!;
      final expectedSuccessMessage = translations['loginSuccessMessage']!;
      testWidgets(
        'shows correct toast when state is success '
        'for locale $locale',
        (tester) async {
          whenListen(
            mockLoginBloc,
            Stream.fromIterable([
              const LoginState.loading(),
              const LoginState.success(),
            ]),
          );

          await pumpWidget(tester: tester, locale: locale);
          await tester.pumpAndSettle();

          expect(find.text(expectedSuccessTitle), findsOneWidget);
          expect(find.text(expectedSuccessMessage), findsOneWidget);

          await tester.pumpAndSettle(kToastDuration);
        },
      );

      final expectedFailureTitle = translations['loginFailedTitle']!;
      final expectedFailureMessage = translations['errorInternalException']!;
      testWidgets(
        'shows correct toast when state is failure '
        'for locale $locale',
        (tester) async {
          whenListen(
            mockLoginBloc,
            Stream.fromIterable([
              const LoginState.loading(),
              LoginState.failure(AppException.test()),
            ]),
          );

          await pumpWidget(tester: tester, locale: locale);
          await tester.pumpAndSettle();

          expect(find.text(expectedFailureTitle), findsOneWidget);
          expect(find.text(expectedFailureMessage), findsOneWidget);

          await tester.pumpAndSettle(kToastDuration);
        },
      );
    }
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

      final translations = expectedTranslations[locale.languageCode]!;
      final expectedSuccessTitle = translations['loginSuccessTitle']!;
      final expectedSuccessMessage = translations['loginSuccessMessage']!;
      testWidgets(
        'has correct semantics on toast when state is success '
        'for locale $locale',
        (tester) async {
          whenListen(
            mockLoginBloc,
            Stream.fromIterable([
              const LoginState.loading(),
              const LoginState.success(),
            ]),
          );

          await pumpWidget(tester: tester, locale: locale);
          await tester.pumpAndSettle();

          expect(
            find.bySemanticsLabel(
              '$expectedSuccessTitle\n$expectedSuccessMessage',
            ),
            findsOneWidget,
          );

          await tester.pumpAndSettle(kToastDuration);
        },
      );

      final expectedFailureTitle = translations['loginFailedTitle']!;
      final expectedFailureMessage = translations['errorInternalException']!;
      testWidgets(
        'has correct semantics on toast when state is failure '
        'for locale $locale',
        (tester) async {
          whenListen(
            mockLoginBloc,
            Stream.fromIterable([
              const LoginState.loading(),
              LoginState.failure(AppException.test()),
            ]),
          );

          await pumpWidget(tester: tester, locale: locale);
          await tester.pumpAndSettle();

          expect(
            find.bySemanticsLabel(
              '$expectedFailureTitle\n$expectedFailureMessage',
            ),
            findsOneWidget,
          );

          await tester.pumpAndSettle(kToastDuration);
        },
      );
    }
  });
}
