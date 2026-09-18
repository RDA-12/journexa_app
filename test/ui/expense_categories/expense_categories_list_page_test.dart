import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/ui/expense_categories/bloc/expense_categories_bloc.dart';
import 'package:journexa_app/ui/expense_categories/expense_categories_list_page.dart';
import 'package:journexa_app/ui/expense_categories/widgets/expense_categories_list_view.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_icon_button.dart';
import 'package:mocktail/mocktail.dart';

import '../util.dart';

class MockExpenseCategoriesBloc extends Mock implements ExpenseCategoriesBloc;

final expectedTranslations = {
  'id': {'title': 'Daftar Kategori Pengeluaran'},
  'en': {'title': 'Expense Categories List'},
};

void main() {
  late ExpenseCategoriesBloc mockExpenseCategoriesBloc;

  setUp(() {
    mockExpenseCategoriesBloc = MockExpenseCategoriesBloc();
    whenListen(
      mockExpenseCategoriesBloc,
      const Stream<ExpenseCategoriesState>.empty(),
      initialState: const ExpenseCategoriesState(),
    );
    when(mockExpenseCategoriesBloc.close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    List<RouteBase> nextRoutes = const [],
    List<RouteBase> childRoutes = const [],
  }) {
    return pumpForPageTest(
      tester,
      initialLocation: '/expense-categories',
      routes: [
        GoRoute(
          path: '/expense-categories',
          routes: childRoutes,
          builder: (context, state) => ExpenseCategoriesListPage(
            expenseCategoriesBloc: mockExpenseCategoriesBloc,
          ),
        ),
        ...nextRoutes,
      ],
      locale: locale,
    );
  }

  group('Init', () {
    testWidgets(
      'add ExpenseCategoriesEvent.subscriptionRequested event on start',
      (tester) async {
        await pumpWidget(tester);

        verify(
          () => mockExpenseCategoriesBloc.add(
            const ExpenseCategoriesEvent.subscriptionRequested(),
          ),
        ).called(1);
      },
    );
  });

  group('Render', () {
    testWidgets('provides ExpenseCategoriesBloc', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(BlocProvider<ExpenseCategoriesBloc>), findsOneWidget);
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

    testWidgets('has ExpenseCategoriesListView', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(ExpenseCategoriesListView), findsOneWidget);
    });
  });

  group('Interactions', () {
    testWidgets(
      'navigates to /expense-categories/add '
      'when add button pressed',
      (tester) async {
        await pumpWidget(
          tester,
          childRoutes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const Placeholder(),
            ),
          ],
        );

        final finder = find.byType(AppIconButton);
        await tester.tap(finder);
        await tester.pumpAndSettle();

        expect(find.byType(Placeholder), findsOneWidget);
      },
    );
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedTitle =
          expectedTranslations[locale.languageCode]!['title']!;
      testWidgets(
        'has $expectedTitle title semantically for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.bySemanticsLabel(expectedTitle), findsOneWidget);
        },
      );
    }
  });

  group('Side Effects', () {
    testWidgets('add ExpenseCategoriesBlocEvent.load '
        'after going back from add expense category page', (tester) async {
      await pumpWidget(
        tester,
        childRoutes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => Scaffold(
              key: const ValueKey('add-expense-category-page'),
              appBar: AppBar(),
            ),
          ),
        ],
      );

      final finder = find.byType(AppIconButton);
      await tester.tap(finder);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('add-expense-category-page')),
        findsOneWidget,
      );

      await tester.tap(find.backButton());
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('add-expense-category-page')),
        findsNothing,
      );

      verify(
        () => mockExpenseCategoriesBloc.add(
          const ExpenseCategoriesEvent.subscriptionRequested(),
        ),
      ).called(2);
    });
  });
}
