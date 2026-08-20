import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';
import 'package:journexa_app/ui/wallets/bloc/add_wallet_bloc.dart';
import 'package:journexa_app/ui/wallets/widgets/add_wallet_view.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_form.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockAddWalletBloc extends Mock implements AddWalletBloc {}

void main() {
  late AddWalletBloc mockAddWalletBloc;

  setUp(() {
    mockAddWalletBloc = MockAddWalletBloc();
    whenListen(
      mockAddWalletBloc,
      const Stream<AddWalletState>.empty(),
      initialState: const AddWalletState.initial(),
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
        value: mockAddWalletBloc,
        child: const AddWalletView(),
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows WalletForm',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byType(WalletForm), findsOneWidget);
      },
    );

    testWidgets(
      'set isAdding true to WalletForm '
      'when state is loading',
      (tester) async {
        whenListen(
          mockAddWalletBloc,
          const Stream<AddWalletState>.empty(),
          initialState: const AddWalletState.loading(),
        );
        await pumpWidget(tester);

        final finder = find.byType(WalletForm);
        final widget = tester.widget<WalletForm>(finder);
        expect(widget.isSaving, isTrue);
      },
    );
  });

  group('Interactions', () {
    testWidgets(
      'add correct AddWalletEvent.submit '
      'when user submit the form',
      (tester) async {
        const expectedName = 'Test';

        await pumpWidget(tester);

        await tester.enterText(find.byType(TextFormField), expectedName);
        await tester.tap(find.byType(AppButton));

        verify(
          () => mockAddWalletBloc.add(
            const AddWalletEvent.submit(name: expectedName),
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
