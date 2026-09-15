import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/expense_categories/add_expense_category_page.dart';
import 'package:journexa_app/ui/expense_categories/bloc/add_expense_category_bloc.dart';
import 'package:journexa_app/ui/expense_categories/widgets/add_expense_category_view.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:mocktail/mocktail.dart';

import '../util.dart';

class MockAddExpenseCategoryBloc extends Mock implements AddExpenseCategoryBloc;

const expectedTranslations = {
  'id': {'title': 'Tambah Kategori Pengeluaran'},
  'en': {'title': 'Add Expense Category'},
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
    when(mockAddExpenseCategoryBloc.close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Map<String, Widget> nextRoutes = const {},
  }) {
    return pumpForPageTest(
      tester,
      initialLocation: '/add-expense-category',
      routes: {
        '/add-expense-category': AddExpenseCategoryPage(
          addExpenseCategoryBloc: mockAddExpenseCategoryBloc,
        ),
        ...nextRoutes,
      },
      locale: locale,
    );
  }

  group('Render', () {
    testWidgets('provides AddExpenseCategoryBloc', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(BlocProvider<AddExpenseCategoryBloc>), findsOneWidget);
    });

    testWidgets('has AddExpenseCategoryView', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(AddExpenseCategoryView), findsOneWidget);
    });

    for (final locale in AppLocalizations.supportedLocales) {
      final expectedTitle =
          expectedTranslations[locale.languageCode]!['title']!;
      testWidgets('shows $expectedTitle title for ${locale.languageCode}', (
        tester,
      ) async {
        await pumpWidget(tester, locale: locale);

        expect(find.text(expectedTitle), findsOneWidget);
      });
    }
  });
}
