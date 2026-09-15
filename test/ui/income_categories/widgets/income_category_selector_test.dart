import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/income_categories/bloc/income_categories_bloc.dart';
import 'package:journexa_app/ui/income_categories/widgets/income_category_selector.dart';
import 'package:journexa_app/ui/shared/widgets/app_selector.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockIncomeCategoriesBloc extends Mock implements IncomeCategoriesBloc;

void main() {
  late IncomeCategoriesBloc mockIncomeCategoriesBloc;

  setUp(() {
    mockIncomeCategoriesBloc = MockIncomeCategoriesBloc();
    whenListen(
      mockIncomeCategoriesBloc,
      const Stream<IncomeCategoriesState>.empty(),
      initialState: const IncomeCategoriesState(),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    AppSelectorController<IncomeCategory>? controller,
    String? label,
    bool? isRequired,
    List<IncomeCategory>? initialItems,
    IncomeCategory? initialValue,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: BlocProvider.value(
        value: mockIncomeCategoriesBloc,
        child: IncomeCategorySelector(
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

        final widgetFinder = find.byType(AppSelector<IncomeCategory>);
        expect(widgetFinder, findsOneWidget);

        final widget = tester.widget<AppSelector<IncomeCategory>>(widgetFinder);
        expect(widget.isRequired, true);
      },
    );

    testWidgets(
      'shows correct AppSelector when isRequired = false',
      (tester) async {
        await pumpWidget(tester, isRequired: false);

        final widgetFinder = find.byType(AppSelector<IncomeCategory>);
        expect(widgetFinder, findsOneWidget);

        final widget = tester.widget<AppSelector<IncomeCategory>>(widgetFinder);
        expect(widget.isRequired, false);
      },
    );

    testWidgets(
      'shows correct AppSelector when label = some text',
      (tester) async {
        await pumpWidget(tester, label: 'Some text');

        final widgetFinder = find.byType(AppSelector<IncomeCategory>);
        expect(widgetFinder, findsOneWidget);

        final widget = tester.widget<AppSelector<IncomeCategory>>(widgetFinder);
        expect(widget.label, 'Some text');
      },
    );

    testWidgets(
      'shows correct AppSelector when controller is provided',
      (tester) async {
        final controller = AppSelectorController<IncomeCategory>(
          displayAsString: (it) => it.name,
        );
        await pumpWidget(tester, controller: controller);

        final widgetFinder = find.byType(AppSelector<IncomeCategory>);
        expect(widgetFinder, findsOneWidget);

        final widget = tester.widget<AppSelector<IncomeCategory>>(widgetFinder);
        expect(widget.controller, controller);
      },
    );

    testWidgets(
      'set initialItems to controller',
      (tester) async {
        final items = List<IncomeCategory>.generate(
          2,
          (i) => IncomeCategory.test(),
        );
        final controller = AppSelectorController<IncomeCategory>(
          displayAsString: (it) => it.name,
        );
        await pumpWidget(tester, initialItems: items, controller: controller);

        expect(controller.items, items);
      },
    );

    testWidgets(
      'set initialValue to controller',
      (tester) async {
        final value = IncomeCategory.test();
        final controller = AppSelectorController<IncomeCategory>(
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
        mockIncomeCategoriesBloc,
        Stream<IncomeCategoriesState>.fromIterable([
          const IncomeCategoriesState(status: IncomeCategoriesUIStatus.loading),
        ]),
        initialState: const IncomeCategoriesState(),
      );
      final controller = AppSelectorController<IncomeCategory>(
        displayAsString: (it) => it.name,
      );
      await pumpWidget(tester, controller: controller);
      await tester.pumpAndSettle();

      expect(controller.isLoading, isTrue);
    });

    testWidgets('set items when status is loaded', (tester) async {
      final items = List<IncomeCategory>.generate(
        2,
        (i) => IncomeCategory.test(),
      );
      whenListen(
        mockIncomeCategoriesBloc,
        Stream<IncomeCategoriesState>.fromIterable([
          IncomeCategoriesState(
            categories: items
                .map((it) => IncomeCategoryUIModel(category: it))
                .toList(),
            status: IncomeCategoriesUIStatus.loaded,
          ),
        ]),
        initialState: const IncomeCategoriesState(),
      );
      final controller = AppSelectorController<IncomeCategory>(
        displayAsString: (it) => it.name,
      );
      await pumpWidget(tester, controller: controller);
      await tester.pumpAndSettle();

      expect(controller.items, items);
      expect(controller.status, SelectorStatus.idle);
    });

    testWidgets('set lastError when status is failure', (tester) async {
      whenListen(
        mockIncomeCategoriesBloc,
        Stream<IncomeCategoriesState>.fromIterable([
          IncomeCategoriesState(
            exception: AppException.test(),
            status: IncomeCategoriesUIStatus.failure,
          ),
        ]),
        initialState: const IncomeCategoriesState(),
      );
      final controller = AppSelectorController<IncomeCategory>(
        displayAsString: (it) => it.name,
      );
      await pumpWidget(tester, controller: controller);
      await tester.pumpAndSettle();

      expect(controller.lastError, AppException.test());
      expect(controller.status, SelectorStatus.error);
    });
  });

  group('Interactions', () {
    testWidgets('adds IncomeCategoriesBloc.search on search', (tester) async {
      whenListen(
        mockIncomeCategoriesBloc,
        const Stream<IncomeCategoriesState>.empty(),
        initialState: const IncomeCategoriesState(),
      );
      await pumpWidget(tester);

      final selectorFinder = find.byType(AppSelector<IncomeCategory>);
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
        () => mockIncomeCategoriesBloc.add(
          const IncomeCategoriesEvent.subscriptionRequested(query: 'Search'),
        ),
      ).called(1);
    });

    testWidgets('adds IncomeCategoriesBloc.load when pressed', (tester) async {
      whenListen(
        mockIncomeCategoriesBloc,
        const Stream<IncomeCategoriesState>.empty(),
        initialState: const IncomeCategoriesState(),
      );
      await pumpWidget(tester);

      final selectorFinder = find.byType(AppSelector<IncomeCategory>);
      expect(selectorFinder, findsOneWidget);

      await tester.tap(selectorFinder);
      await tester.pumpAndSettle();

      verify(
        () => mockIncomeCategoriesBloc.add(
          const IncomeCategoriesEvent.subscriptionRequested(),
        ),
      ).called(1);
    });
  });
}
