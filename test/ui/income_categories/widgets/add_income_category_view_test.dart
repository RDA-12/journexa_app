import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/income_categories/bloc/add_income_category_bloc.dart';
import 'package:journexa_app/ui/income_categories/widgets/add_income_category_view.dart';
import 'package:journexa_app/ui/income_categories/widgets/income_category_form.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';
import 'package:journexa_app/ui/shared/widgets/app_toast.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockAddIncomeCategoryBloc extends Mock implements AddIncomeCategoryBloc;

final expectedTranslations = {
  'id': {
    'successToastMessage': 'Kategori pendapatan berhasil ditambahkan',
    'failureToastTitle': 'Gagal menambahkan kategori pendapatan',
    'failureToastMessage': 'Terjadi kesalahan internal',
  },
  'en': {
    'successToastMessage': 'Income category successfully added',
    'failureToastTitle': 'Failed to add income category',
    'failureToastMessage': 'Internal exception error',
  },
};

void main() {
  late AddIncomeCategoryBloc mockAddIncomeCategoryBloc;

  setUp(() {
    mockAddIncomeCategoryBloc = MockAddIncomeCategoryBloc();
    whenListen(
      mockAddIncomeCategoryBloc,
      const Stream<AddIncomeCategoryState>.empty(),
      initialState: const AddIncomeCategoryState.initial(),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: BlocProvider.value(
        value: mockAddIncomeCategoryBloc,
        child: const AddIncomeCategoryView(),
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows IncomeCategoryForm',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byType(IncomeCategoryForm), findsOneWidget);
      },
    );

    testWidgets(
      'set isAdding true to IncomeCategoryForm '
      'when state is loading',
      (tester) async {
        whenListen(
          mockAddIncomeCategoryBloc,
          const Stream<AddIncomeCategoryState>.empty(),
          initialState: const AddIncomeCategoryState.loading(),
        );
        await pumpWidget(tester);

        final finder = find.byType(IncomeCategoryForm);
        final widget = tester.widget<IncomeCategoryForm>(finder);
        expect(widget.isSaving, isTrue);
      },
    );
  });

  group('Interactions', () {
    testWidgets(
      'add correct AddIncomeCategoryEvent.submit '
      'when user submit the form',
      (tester) async {
        const expectedName = 'Test';

        await pumpWidget(tester);

        await tester.enterText(find.byType(TextFormField), expectedName);
        await tester.tap(find.byType(AppButton));

        verify(
          () => mockAddIncomeCategoryBloc.add(
            const AddIncomeCategoryEvent.submit(name: expectedName),
          ),
        ).called(1);
      },
    );
  });

  group('Side Effects', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final translations = expectedTranslations[locale.toLanguageTag()]!;
      final expectedSuccessToastMessage = translations['successToastMessage']!;
      testWidgets(
        'shows correct toast when state is success '
        'for locale $locale',
        (tester) async {
          whenListen(
            mockAddIncomeCategoryBloc,
            Stream<AddIncomeCategoryState>.fromIterable([
              const AddIncomeCategoryState.added(),
            ]),
            initialState: const AddIncomeCategoryState.loading(),
          );

          await pumpWidget(tester, locale: locale);
          await tester.pumpAndSettle();

          expect(find.text(expectedSuccessToastMessage), findsOneWidget);

          await tester.pumpAndSettle(kToastDuration);
        },
      );

      final expectedFailureToastTitle = translations['failureToastTitle']!;
      final expectedFailureToastMessage = translations['failureToastMessage']!;
      testWidgets(
        'shows correct toast when state is failure '
        'for locale $locale',
        (tester) async {
          whenListen(
            mockAddIncomeCategoryBloc,
            Stream<AddIncomeCategoryState>.fromIterable([
              AddIncomeCategoryState.failure(AppException.test()),
            ]),
            initialState: const AddIncomeCategoryState.loading(),
          );

          await pumpWidget(tester, locale: locale);
          await tester.pumpAndSettle();

          expect(find.text(expectedFailureToastTitle), findsOneWidget);
          expect(find.text(expectedFailureToastMessage), findsOneWidget);

          await tester.pumpAndSettle(kToastDuration);
        },
      );
    }
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final translations = expectedTranslations[locale.toLanguageTag()]!;
      final expectedToastMessage = translations['successToastMessage']!;
      testWidgets(
        'has correct semantics on toast when state is success '
        'for locale $locale',
        (tester) async {
          whenListen(
            mockAddIncomeCategoryBloc,
            Stream<AddIncomeCategoryState>.fromIterable([
              const AddIncomeCategoryState.added(),
            ]),
            initialState: const AddIncomeCategoryState.loading(),
          );

          await pumpWidget(tester, locale: locale);
          await tester.pumpAndSettle();

          expect(find.bySemanticsLabel(expectedToastMessage), findsOneWidget);

          await tester.pumpAndSettle(kToastDuration);
        },
      );

      final expectedFailureToastTitle = translations['failureToastTitle']!;
      final expectedFailureToastMessage = translations['failureToastMessage']!;
      testWidgets(
        'has correct semantics on toast when state is failure '
        'for locale $locale',
        (tester) async {
          whenListen(
            mockAddIncomeCategoryBloc,
            Stream<AddIncomeCategoryState>.fromIterable([
              AddIncomeCategoryState.failure(AppException.test()),
            ]),
            initialState: const AddIncomeCategoryState.loading(),
          );

          await pumpWidget(tester, locale: locale);
          await tester.pumpAndSettle();

          expect(
            find.bySemanticsLabel(
              '$expectedFailureToastTitle\n$expectedFailureToastMessage',
            ),
            findsOneWidget,
          );

          await tester.pumpAndSettle(kToastDuration);
        },
      );
    }
  });
}
