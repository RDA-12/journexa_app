import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/shared/widgets/app_selector.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_selector.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockWalletsBloc extends Mock implements WalletsBloc {}

void main() {
  late WalletsBloc mockWalletsBloc;

  setUp(() {
    mockWalletsBloc = MockWalletsBloc();
    whenListen(
      mockWalletsBloc,
      const Stream<WalletsState>.empty(),
      initialState: const WalletsState(),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    AppSelectorController<Wallet>? controller,
    String? label,
    bool? isRequired,
    List<Wallet>? initialItems,
    Wallet? initialValue,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: BlocProvider.value(
        value: mockWalletsBloc,
        child: WalletSelector(
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

        final widgetFinder = find.byType(AppSelector<Wallet>);
        expect(widgetFinder, findsOneWidget);

        final widget = tester.widget<AppSelector<Wallet>>(widgetFinder);
        expect(widget.isRequired, true);
      },
    );

    testWidgets(
      'shows correct AppSelector when isRequired = false',
      (tester) async {
        await pumpWidget(tester, isRequired: false);

        final widgetFinder = find.byType(AppSelector<Wallet>);
        expect(widgetFinder, findsOneWidget);

        final widget = tester.widget<AppSelector<Wallet>>(widgetFinder);
        expect(widget.isRequired, false);
      },
    );

    testWidgets(
      'shows correct AppSelector when label = some text',
      (tester) async {
        await pumpWidget(tester, label: 'Some text');

        final widgetFinder = find.byType(AppSelector<Wallet>);
        expect(widgetFinder, findsOneWidget);

        final widget = tester.widget<AppSelector<Wallet>>(widgetFinder);
        expect(widget.label, 'Some text');
      },
    );

    testWidgets(
      'shows correct AppSelector when controller is provided',
      (tester) async {
        final controller = AppSelectorController<Wallet>(
          displayAsString: (it) => it.name,
        );
        await pumpWidget(tester, controller: controller);

        final widgetFinder = find.byType(AppSelector<Wallet>);
        expect(widgetFinder, findsOneWidget);

        final widget = tester.widget<AppSelector<Wallet>>(widgetFinder);
        expect(widget.controller, controller);
      },
    );

    testWidgets(
      'set initialItems to controller',
      (tester) async {
        final items = List<Wallet>.generate(
          2,
          (i) => Wallet.test(),
        );
        final controller = AppSelectorController<Wallet>(
          displayAsString: (it) => it.name,
        );
        await pumpWidget(tester, initialItems: items, controller: controller);

        expect(controller.items, items);
      },
    );

    testWidgets(
      'set initialValue to controller',
      (tester) async {
        final value = Wallet.test();
        final controller = AppSelectorController<Wallet>(
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
        mockWalletsBloc,
        Stream<WalletsState>.fromIterable([
          const WalletsState(status: WalletsUIStatus.loading),
        ]),
        initialState: const WalletsState(),
      );
      final controller = AppSelectorController<Wallet>(
        displayAsString: (it) => it.name,
      );
      await pumpWidget(tester, controller: controller);
      await tester.pumpAndSettle();

      expect(controller.isLoading, isTrue);
    });

    testWidgets('set items when status is loaded', (tester) async {
      final items = List<Wallet>.generate(
        2,
        (i) => Wallet.test(),
      );
      whenListen(
        mockWalletsBloc,
        Stream<WalletsState>.fromIterable([
          WalletsState(
            walletWithBalances: items
                .map(
                  (it) => WalletWithBalance(wallet: it, balance: Decimal.zero),
                )
                .map(
                  (it) => WalletWithBalanceUIModel(walletWithBalance: it),
                )
                .toList(),
            status: WalletsUIStatus.loaded,
          ),
        ]),
        initialState: const WalletsState(),
      );
      final controller = AppSelectorController<Wallet>(
        displayAsString: (it) => it.name,
      );
      await pumpWidget(tester, controller: controller);
      await tester.pumpAndSettle();

      expect(controller.items, items);
      expect(controller.status, SelectorStatus.idle);
    });

    testWidgets('set lastError when status is failure', (tester) async {
      whenListen(
        mockWalletsBloc,
        Stream<WalletsState>.fromIterable([
          WalletsState(
            exception: AppException.test(),
            status: WalletsUIStatus.failure,
          ),
        ]),
        initialState: const WalletsState(),
      );
      final controller = AppSelectorController<Wallet>(
        displayAsString: (it) => it.name,
      );
      await pumpWidget(tester, controller: controller);
      await tester.pumpAndSettle();

      expect(controller.lastError, AppException.test());
      expect(controller.status, SelectorStatus.error);
    });
  });

  group('Interactions', () {
    testWidgets('adds WalletsBloc.search on search', (tester) async {
      whenListen(
        mockWalletsBloc,
        const Stream<WalletsState>.empty(),
        initialState: const WalletsState(),
      );
      await pumpWidget(tester);

      final selectorFinder = find.byType(AppSelector<Wallet>);
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
        () => mockWalletsBloc.add(
          const WalletsEvent.subscriptionRequested(query: 'Search'),
        ),
      ).called(1);
    });

    testWidgets('adds WalletsBloc.load when pressed', (tester) async {
      whenListen(
        mockWalletsBloc,
        const Stream<WalletsState>.empty(),
        initialState: const WalletsState(),
      );
      await pumpWidget(tester);

      final selectorFinder = find.byType(AppSelector<Wallet>);
      expect(selectorFinder, findsOneWidget);

      await tester.tap(selectorFinder);
      await tester.pumpAndSettle();

      verify(
        () => mockWalletsBloc.add(const WalletsEvent.subscriptionRequested()),
      ).called(1);
    });
  });
}
