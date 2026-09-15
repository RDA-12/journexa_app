import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/initialize/bloc/initialize_bloc.dart';
import 'package:journexa_app/ui/initialize/widgets/initializing_box.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/app_exception_box.dart';
import 'package:journexa_app/ui/shared/widgets/loading_indicator.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockInitializeBloc extends Mock implements InitializeBloc;

final expectedTranslations = {
  'id': {
    'loadingText': 'Menginisialisasi...',
    'errorTitle': 'Inisialisasi gagal',
    'errorMessage': 'Terjadi kesalahan internal',
  },
  'en': {
    'loadingText': 'Initializing...',
    'errorTitle': 'Initialization failed',
    'errorMessage': 'Internal exception error',
  },
};

void main() {
  late InitializeBloc mockInitializeBloc;

  setUp(() {
    mockInitializeBloc = MockInitializeBloc();
    whenListen(
      mockInitializeBloc,
      const Stream<InitializeState>.empty(),
      initialState: const InitializeState.loading(),
    );
  });

  Future<void> pumpWidget(WidgetTester tester, {required Locale locale}) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: BlocProvider.value(
        value: mockInitializeBloc,
        child: const InitializingBox(),
      ),
    );
  }

  group('Render', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedLoadingText =
          expectedTranslations[locale.languageCode]!['loadingText']!;
      testWidgets(
        'shows $expectedLoadingText for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.text(expectedLoadingText), findsOneWidget);
        },
      );

      final expectedErrorTitle =
          expectedTranslations[locale.languageCode]!['errorTitle']!;
      testWidgets(
        'shows $expectedErrorTitle as Title '
        'when state is failure for ${locale.languageCode}',
        (tester) async {
          when(() => mockInitializeBloc.state).thenReturn(
            InitializeState.failure(AppException.test()),
          );

          await pumpWidget(tester, locale: locale);

          expect(find.text(expectedErrorTitle), findsOneWidget);
          final exceptionBoxFinder = find.byType(AppExceptionBox);
          final widget = tester.widget<AppExceptionBox>(exceptionBoxFinder);
          expect(widget.title, expectedErrorTitle);
        },
      );

      final expectedDescription =
          expectedTranslations[locale.languageCode]!['errorMessage']!;
      testWidgets(
        'shows $expectedErrorTitle as Description '
        'when state is failure for ${locale.languageCode}',
        (tester) async {
          when(() => mockInitializeBloc.state).thenReturn(
            InitializeState.failure(AppException.test()),
          );

          await pumpWidget(tester, locale: locale);

          expect(find.text(expectedDescription), findsOneWidget);
          final exceptionBoxFinder = find.byType(AppExceptionBox);
          final widget = tester.widget<AppExceptionBox>(exceptionBoxFinder);
          expect(widget.description, expectedDescription);
        },
      );
    }

    testWidgets(
      'shows LoadingIndicator when state is loading',
      (tester) async {
        await pumpWidget(tester, locale: const Locale('en'));

        expect(find.byType(LoadingIndicator), findsOneWidget);
      },
    );
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedLoadingText =
          expectedTranslations[locale.languageCode]!['loadingText']!;
      testWidgets(
        'have $expectedLoadingText semantically for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(
            find.bySemanticsLabel(expectedLoadingText),
            findsOneWidget,
          );
        },
      );
    }

    testWidgets(
      'LoadingIndicator doesnt have semantics label',
      (tester) async {
        await pumpWidget(tester, locale: const Locale('id'));

        final finder = find.byType(LoadingIndicator);
        expect(finder, findsOneWidget);

        final widget = tester.widget<LoadingIndicator>(finder);
        expect(widget.semanticsLabel, isNull);
      },
    );
  });
}
