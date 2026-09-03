import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/expense_categories/bloc/expense_categories_bloc.dart';
import 'package:journexa_app/ui/expense_categories/widgets/expense_category_selector.dart';
import 'package:journexa_app/ui/shared/widgets/app_selector.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockExpenseCategoriesBloc extends Mock
    implements ExpenseCategoriesBloc {}

void main() {
  late ExpenseCategoriesBloc mockExpenseCategoriesBloc;

  setUp(() {
    mockExpenseCategoriesBloc = MockExpenseCategoriesBloc();
    whenListen(
      mockExpenseCategoriesBloc,
      const Stream<ExpenseCategoriesState>.empty(),
      initialState: const ExpenseCategoriesState(),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    AppSelectorController<ExpenseCategory>? controller,
    String? label,
    bool? isRequired,
    List<ExpenseCategory>? initialItems,
    ExpenseCategory? initialValue,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: BlocProvider.value(
        value: mockExpenseCategoriesBloc,
        child: ExpenseCategorySelector(
          isRequired: isRequired ?? false,
          label: label,
          controller: controller,
          initialItems: initialItems ?? [],
          initialValue: initialValue,
        ),
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows correct AppSelector when isRequired = true',
      (tester) async {
        await pumpWidget(tester, isRequired: true);

        final widgetFinder = find.byType(AppSelector<ExpenseCategory>);
        expect(widgetFinder, findsOneWidget);

        final widget =
            tester.widget<AppSelector<ExpenseCategory>>(widgetFinder);
        expect(widget.isRequired, true);
      },
    );

    testWidgets(
      'shows correct AppSelector when isRequired = false',
      (tester) async {
        await pumpWidget(tester, isRequired: false);

        final widgetFinder = find.byType(AppSelector<ExpenseCategory>);
        expect(widgetFinder, findsOneWidget);

        final widget =
            tester.widget<AppSelector<ExpenseCategory>>(widgetFinder);
        expect(widget.isRequired, false);
      },
    );

    testWidgets(
      'shows correct AppSelector when label = some text',
      (tester) async {
        await pumpWidget(tester, label: 'Some text');

        final widgetFinder = find.byType(AppSelector<ExpenseCategory>);
        expect(widgetFinder, findsOneWidget);

        final widget =
            tester.widget<AppSelector<ExpenseCategory>>(widgetFinder);
        expect(widget.label, 'Some text');
      },
    );

    testWidgets(
      'shows correct AppSelector when controller is provided',
      (tester) async {
        final controller = AppSelectorController<ExpenseCategory>(
          displayAsString: (it) => it.name,
        );
        await pumpWidget(tester, controller: controller);

        final widgetFinder = find.byType(AppSelector<ExpenseCategory>);
        expect(widgetFinder, findsOneWidget);

        final widget =
            tester.widget<AppSelector<ExpenseCategory>>(widgetFinder);
        expect(widget.controller, controller);
      },
    );

    testWidgets(
      'set initialItems to controller',
      (tester) async {
        final items = List<ExpenseCategory>.generate(
          2,
          (i) => ExpenseCategory.test(),
        );
        final controller = AppSelectorController<ExpenseCategory>(
          displayAsString: (it) => it.name,
        );
        await pumpWidget(tester, initialItems: items, controller: controller);

        expect(controller.items, items);
      },
    );

    testWidgets(
      'set initialValue to controller',
      (tester) async {
        final value = ExpenseCategory.test();
        final controller = AppSelectorController<ExpenseCategory>(
          displayAsString: (it) => it.name,
        );
        await pumpWidget(tester, initialValue: value, controller: controller);

        expect(controller.value, value);
      },
    );
  });

  group('Side Effects', () {
    testWidgets('set isLoading when status is loading', (tester) async {
      whenListen(
        mockExpenseCategoriesBloc,
        Stream<ExpenseCategoriesState>.fromIterable([
          const ExpenseCategoriesState(status: ExpenseCategoriesStatus.loading),
        ]),
        initialState: const ExpenseCategoriesState(),
      );
      final controller = AppSelectorController<ExpenseCategory>(
        displayAsString: (it) => it.name,
      );
      await pumpWidget(tester, controller: controller);
      await tester.pumpAndSettle();

      expect(controller.isLoading, isTrue);
    });

    testWidgets('set items when status is loaded', (tester) async {
      final items = List<ExpenseCategory>.generate(
        2,
        (i) => ExpenseCategory.test(),
      );
      whenListen(
        mockExpenseCategoriesBloc,
        Stream<ExpenseCategoriesState>.fromIterable([
          ExpenseCategoriesState(
            categories: items
                .map((it) => ExpenseCategoryWithState(category: it))
                .toList(),
            status: ExpenseCategoriesStatus.loaded,
          ),
        ]),
        initialState: const ExpenseCategoriesState(),
      );
      final controller = AppSelectorController<ExpenseCategory>(
        displayAsString: (it) => it.name,
      );
      await pumpWidget(tester, controller: controller);
      await tester.pumpAndSettle();

      expect(controller.items, items);
      expect(controller.status, SelectorStatus.idle);
    });

    testWidgets('set lastError when status is failure', (tester) async {
      whenListen(
        mockExpenseCategoriesBloc,
        Stream<ExpenseCategoriesState>.fromIterable([
          ExpenseCategoriesState(
            exception: AppException.test(),
            status: ExpenseCategoriesStatus.failure,
          ),
        ]),
        initialState: const ExpenseCategoriesState(),
      );
      final controller = AppSelectorController<ExpenseCategory>(
        displayAsString: (it) => it.name,
      );
      await pumpWidget(tester, controller: controller);
      await tester.pumpAndSettle();

      expect(controller.lastError, AppException.test());
      expect(controller.status, SelectorStatus.error);
    });
  });

  group('Interactions', () {
    testWidgets('adds ExpenseCategoriesBloc.search on search', (tester) async {
      whenListen(
        mockExpenseCategoriesBloc,
        const Stream<ExpenseCategoriesState>.empty(),
        initialState: const ExpenseCategoriesState(),
      );
      await pumpWidget(tester);

      final selectorFinder = find.byType(AppSelector<ExpenseCategory>);
      expect(selectorFinder, findsOneWidget);

      await tester.tap(selectorFinder);
      await tester.pumpAndSettle();

      final searchFieldFinder = find.descendant(
        of: find.byType(Column),
        matching: find.byType(TextFormField),
      );
      expect(searchFieldFinder, findsOneWidget);

      await tester.enterText(searchFieldFinder, 'Search');
      await tester.pumpAndSettle();

      verify(
        () => mockExpenseCategoriesBloc.add(
          const ExpenseCategoriesEvent.search(query: 'Search'),
        ),
      ).called(1);
    });

    testWidgets('adds ExpenseCategoriesBloc.load when pressed', (tester) async {
      whenListen(
        mockExpenseCategoriesBloc,
        const Stream<ExpenseCategoriesState>.empty(),
        initialState: const ExpenseCategoriesState(),
      );
      await pumpWidget(tester);

      final selectorFinder = find.byType(AppSelector<ExpenseCategory>);
      expect(selectorFinder, findsOneWidget);

      await tester.tap(selectorFinder);
      await tester.pumpAndSettle();

      verify(
        () => mockExpenseCategoriesBloc.add(
          const ExpenseCategoriesEvent.load(),
        ),
      ).called(1);
    });
  });
}
