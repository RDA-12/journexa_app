import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/income_categories/bloc/add_income_category_bloc.dart';
import 'package:journexa_app/ui/income_categories/widgets/add_income_category_view.dart';
import 'package:journexa_app/ui/income_categories/widgets/income_category_form.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockAddIncomeCategoryBloc extends Mock implements AddIncomeCategoryBloc {}

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
    // TODO(RDA): test to ensure toast is showed when success/fail
  });

  group('a11y', () {
    // TODO(RDA): test to ensure toast has correct semantics when success/fail
  });
}
