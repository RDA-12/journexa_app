import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/accounts/bloc/add_cash_account_bloc.dart';
import 'package:journexa_app/ui/accounts/widgets/add_cash_account_view.dart';
import 'package:journexa_app/ui/accounts/widgets/cash_account_form.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

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
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: BlocProvider.value(
        value: mockAddCashAccountBloc,
        child: const AddCashAccountView(),
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows CashAccountForm',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byType(CashAccountForm), findsOneWidget);
      },
    );

    testWidgets(
      'set isAdding true to CashAccountForm '
      'when state is loading',
      (tester) async {
        whenListen(
          mockAddCashAccountBloc,
          const Stream<AddCashAccountState>.empty(),
          initialState: const AddCashAccountState.loading(),
        );
        await pumpWidget(tester);

        final finder = find.byType(CashAccountForm);
        final widget = tester.widget<CashAccountForm>(finder);
        expect(widget.isSaving, isTrue);
      },
    );
  });

  group('Interactions', () {
    testWidgets(
      'add correct AddCashAccountEvent.submit '
      'when user submit the form',
      (tester) async {
        const expectedName = 'Test';

        await pumpWidget(tester);

        await tester.enterText(find.byType(TextFormField), expectedName);
        await tester.tap(find.byType(AppButton));

        verify(
          () => mockAddCashAccountBloc.add(
            const AddCashAccountEvent.submit(name: expectedName),
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
