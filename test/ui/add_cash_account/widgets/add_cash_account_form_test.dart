import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/add_cash_account/bloc/add_cash_account_bloc.dart';
import 'package:journexa_app/ui/add_cash_account/widgets/add_cash_account_form.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';
import 'package:journexa_app/ui/shared/widgets/app_toast.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

final expectedTranslations = {
  'id': {
    'label': 'Nama',
    'button': 'Tambah Kas',
    'required': 'Wajib',
  },
  'en': {
    'label': 'Name',
    'button': 'Add Cash',
    'required': 'Required',
  },
};

class MockAddCashAccountBloc extends Mock implements AddCashAccountBloc {}

void main() {
  late AddCashAccountBloc mockAddCashAccountBloc;

  setUp(() {
    mockAddCashAccountBloc = MockAddCashAccountBloc();
    whenListen(
      mockAddCashAccountBloc,
      const Stream<AddCashAccountState>.empty(),
      initialState: const AddCashAccountState.initial(),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    VoidCallback? onSuccess,
  }) async {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: BlocProvider.value(
        value: mockAddCashAccountBloc,
        child: AddCashAccountForm(
          onSuccess: onSuccess,
        ),
      ),
    );
  }

  group(
    'Render',
    () {
      for (final locale in AppLocalizations.supportedLocales) {
        final expectedLocaleTranslated =
            expectedTranslations[locale.languageCode]!;
        final expectedLabel = expectedLocaleTranslated['label']!;
        testWidgets(
          'shows $expectedLabel * label for ${locale.languageCode} ',
          (tester) async {
            await pumpWidget(tester, locale: locale);

            expect(find.text('$expectedLabel *'), findsOneWidget);
          },
        );

        final expectedButton = expectedLocaleTranslated['button']!;
        testWidgets(
          'shows $expectedButton button for ${locale.languageCode}',
          (tester) async {
            await pumpWidget(tester, locale: locale);

            final finder = find.text(expectedButton);
            expect(finder, findsOneWidget);
          },
        );
      }
    },
  );

  group(
    'Interaction',
    () {
      testWidgets(
        'allows input name',
        (tester) async {
          await pumpWidget(tester);

          final formFieldFinder = find.byType(TextFormField);
          await tester.enterText(formFieldFinder, 'Test');

          expect(find.text('Test'), findsOneWidget);
        },
      );

      testWidgets(
        'add correct event to AddCashBloc when clicks save button',
        (tester) async {
          const expectedName = 'Test';

          await pumpWidget(tester);

          final formFieldFinder = find.byType(TextFormField);
          await tester.enterText(formFieldFinder, expectedName);
          await tester.tap(find.byType(AppButton));

          verify(
            () => mockAddCashAccountBloc.add(
              const AddCashAccountEvent.submit(name: expectedName),
            ),
          ).called(1);
        },
      );
    },
  );

  group('Side Effects', () {
    testWidgets(
      'calls onSuccess when cash account added',
      (tester) async {
        whenListen(
          mockAddCashAccountBloc,
          Stream.fromIterable(const [
            AddCashAccountState.loading(),
            AddCashAccountState.added(),
          ]),
        );
        var success = false;

        await pumpWidget(
          tester,
          onSuccess: () {
            success = true;
          },
        );

        await tester.pumpAndSettle(kToastDuration);

        expect(success, isTrue);
      },
    );

    // TODO(RDA): expect to shows toast when success/failure
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedLocaleTranslated =
          expectedTranslations[locale.languageCode]!;
      final expectedLabel = expectedLocaleTranslated['label']!;
      final requiredLabel = expectedLocaleTranslated['required']!;
      testWidgets(
        'shows $expectedLabel, $requiredLabel label semantically for '
        '${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(
            find.bySemanticsLabel('$expectedLabel, $requiredLabel'),
            findsOneWidget,
          );
        },
      );

      final expectedButton = expectedLocaleTranslated['button']!;
      testWidgets(
        'shows $expectedButton button semantically for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          final finder = find.bySemanticsLabel(expectedButton);
          expect(finder, findsOneWidget);
        },
      );
    }

    // TODO(RDA): expect to shows toast when success/failure semantically
  });
}
