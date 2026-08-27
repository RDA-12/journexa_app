import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/expense_categories/bloc/add_expense_category_bloc.dart';
import 'package:journexa_app/ui/expense_categories/widgets/add_expense_category_view.dart';
import 'package:journexa_app/ui/expense_categories/widgets/expense_category_form.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';
import 'package:journexa_app/ui/shared/widgets/app_toast.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockAddExpenseCategoryBloc extends Mock
    implements AddExpenseCategoryBloc {}

final expectedTranslations = {
  'id': {
    'successToastTitle': 'Kategori pengeluaran ditambahkan',
    'successToastMessage': 'Kategori pengeluaran berhasil ditambahkan',
    'failureToastTitle': 'Gagal menambahkan kategori pengeluaran',
    'failureToastMessage': 'Terjadi kesalahan internal',
  },
  'en': {
    'successToastTitle': 'Expense category added',
    'successToastMessage': 'Expense category successfully added',
    'failureToastTitle': 'Failed to add expense category',
    'failureToastMessage': 'Internal exception error',
  },
};

void main() {
  late AddExpenseCategoryBloc mockAddExpenseCategoryBloc;

  setUp(() {
    mockAddExpenseCategoryBloc = MockAddExpenseCategoryBloc();
    whenListen(
      mockAddExpenseCategoryBloc,
      const Stream<AddExpenseCategoryState>.empty(),
      initialState: const AddExpenseCategoryState.initial(),
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
        value: mockAddExpenseCategoryBloc,
        child: const AddExpenseCategoryView(),
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows ExpenseCategoryForm',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byType(ExpenseCategoryForm), findsOneWidget);
      },
    );

    testWidgets(
      'set isAdding true to ExpenseCategoryForm '
      'when state is loading',
      (tester) async {
        whenListen(
          mockAddExpenseCategoryBloc,
          const Stream<AddExpenseCategoryState>.empty(),
          initialState: const AddExpenseCategoryState.loading(),
        );
        await pumpWidget(tester);

        final finder = find.byType(ExpenseCategoryForm);
        final widget = tester.widget<ExpenseCategoryForm>(finder);
        expect(widget.isSaving, isTrue);
      },
    );
  });

  group('Interactions', () {
    testWidgets(
      'add correct AddExpenseCategoryEvent.submit '
      'when user submit the form',
      (tester) async {
        const expectedName = 'Test';

        await pumpWidget(tester);

        await tester.enterText(find.byType(TextFormField), expectedName);
        await tester.tap(find.byType(AppButton));

        verify(
          () => mockAddExpenseCategoryBloc.add(
            const AddExpenseCategoryEvent.submit(name: expectedName),
          ),
        ).called(1);
      },
    );
  });

  group('Side Effects', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final translations = expectedTranslations[locale.toLanguageTag()]!;
      final expectedSuccessToastTitle = translations['successToastTitle']!;
      final expectedSuccessToastMessage = translations['successToastMessage']!;
      testWidgets(
        'shows correct toast when state is success '
        'for locale $locale',
        (tester) async {
          whenListen(
            mockAddExpenseCategoryBloc,
            Stream<AddExpenseCategoryState>.fromIterable([
              const AddExpenseCategoryState.added(),
            ]),
            initialState: const AddExpenseCategoryState.loading(),
          );

          await pumpWidget(tester, locale: locale);
          await tester.pumpAndSettle();

          expect(find.text(expectedSuccessToastTitle), findsOneWidget);
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
            mockAddExpenseCategoryBloc,
            Stream<AddExpenseCategoryState>.fromIterable([
              AddExpenseCategoryState.failure(AppException.test()),
            ]),
            initialState: const AddExpenseCategoryState.loading(),
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
      final expectedToastTitle = translations['successToastTitle']!;
      final expectedToastMessage = translations['successToastMessage']!;
      testWidgets(
        'has correct semantics on toast when state is success '
        'for locale $locale',
        (tester) async {
          whenListen(
            mockAddExpenseCategoryBloc,
            Stream<AddExpenseCategoryState>.fromIterable([
              const AddExpenseCategoryState.added(),
            ]),
            initialState: const AddExpenseCategoryState.loading(),
          );

          await pumpWidget(tester, locale: locale);
          await tester.pumpAndSettle();

          expect(
            find.bySemanticsLabel('$expectedToastTitle\n$expectedToastMessage'),
            findsOneWidget,
          );

          await tester.pumpAndSettle(kToastDuration);
        },
      );

      final expectedFailureToastTitle = translations['failureToastTitle']!;
      final expectedFailureToastMessage = translations['failureToastMessage']!;
      testWidgets(
        'has corrent semantics on toast when state is failure '
        'for locale $locale',
        (tester) async {
          whenListen(
            mockAddExpenseCategoryBloc,
            Stream<AddExpenseCategoryState>.fromIterable([
              AddExpenseCategoryState.failure(AppException.test()),
            ]),
            initialState: const AddExpenseCategoryState.loading(),
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
