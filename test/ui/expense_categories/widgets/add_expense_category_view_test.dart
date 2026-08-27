import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/expense_categories/bloc/add_expense_category_bloc.dart';
import 'package:journexa_app/ui/expense_categories/widgets/add_expense_category_view.dart';
import 'package:journexa_app/ui/expense_categories/widgets/expense_category_form.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockAddExpenseCategoryBloc extends Mock
    implements AddExpenseCategoryBloc {}

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
    // TODO(RDA): test to ensure toast is showed when success/fail
  });

  group('a11y', () {
    // TODO(RDA): test to ensure toast has correct semantics when success/fail
  });
}
