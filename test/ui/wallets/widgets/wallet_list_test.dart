import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/ui/shared/widgets/app_dialog.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:journexa_app/ui/wallets/widgets/delete_wallet_button.dart';
import 'package:journexa_app/ui/wallets/widgets/update_wallet_button.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_card.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_form.dart';
import 'package:journexa_app/ui/wallets/widgets/wallets_list.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockWalletsBloc extends Mock implements WalletsBloc {}

void main() {
  late WalletsBloc mockWalletsBloc;

  final data = List.generate(
    3,
    (idx) {
      final walletWithBalance = WalletWithBalance(
        wallet: Wallet(
          id: '$idx',
          name: 'asset $idx',
          account: Account.user(
            parent: SystemDefinedAccount.rootAsset,
            name: 'asset $idx',
            currentChildrenCount: idx,
          ),
        ),
        balance: Decimal.fromInt(idx * 1000),
      );
      return WalletWithBalanceState(
        walletWithBalance: walletWithBalance,
        status: idx == 0
            ? WalletStatus.idle
            : idx.isEven
            ? WalletStatus.deleting
            : WalletStatus.updating,
      );
    },
  );

  setUp(() {
    mockWalletsBloc = MockWalletsBloc();
    whenListen(
      mockWalletsBloc,
      const Stream<WalletsState>.empty(),
      initialState: WalletsState(
        status: WalletsStatus.loaded,
        walletWithBalances: data,
      ),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function(Wallet)? onDeletePressed,
    void Function(Wallet, String)? onUpdatePressed,
  }) async {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: BlocProvider.value(
        value: mockWalletsBloc,
        child: WalletsList(
          data: data,
          onDeletePressed: onDeletePressed ?? (account) {},
          onUpdatePressed: onUpdatePressed ?? (account, name) {},
        ),
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'has correct list of WalletCard',
      (tester) async {
        await pumpWidget(tester);

        final cardFinder = find.byType(WalletCard);
        expect(
          cardFinder,
          findsNWidgets(data.length),
        );

        final cards = cardFinder.evaluate().toList();
        for (var i = 0; i < cards.length; i++) {
          final item = data[i];
          final walletWithBalance = item.walletWithBalance;
          final isDeleting = item.status == WalletStatus.deleting;
          final isUpdating = item.status == WalletStatus.updating;
          final widget = cards[i].widget as WalletCard;
          expect(widget.walletWithBalance, walletWithBalance);
          expect(widget.isDeleting, isDeleting);
          expect(widget.isUpdating, isUpdating);
        }
      },
    );
  });

  group('Interactions', () {
    testWidgets(
      'calls onDeletePressed when WalletCard - DeleteWalletButton '
      'is pressed and user confirmed to delete it',
      (tester) async {
        Wallet? deletedWallet;
        await pumpWidget(
          tester,
          onDeletePressed: (account) => deletedWallet = account,
        );

        final deleteableData = data.first;
        final deleteableCardFinder = find.byType(WalletCard).first;
        final cardWidget = tester.widget<WalletCard>(
          deleteableCardFinder,
        );
        expect(cardWidget.walletWithBalance, deleteableData.walletWithBalance);

        final deleteButtonFinder = find.descendant(
          of: deleteableCardFinder,
          matching: find.byType(DeleteWalletButton),
        );
        final deleteButtonWidget = tester.widget<DeleteWalletButton>(
          deleteButtonFinder,
        );
        expect(deleteButtonWidget.onDeletePressed, isNotNull);
        expect(deleteButtonWidget.isDeleting, isFalse);
        await tester.tap(deleteButtonFinder);
        await tester.pump();

        await tester.tap(
          find.descendant(
            of: find.byType(AppDialog),
            matching: find.text('Delete'),
          ),
        );
        await tester.pump();

        expect(deletedWallet, deleteableData.walletWithBalance.wallet);
      },
    );

    testWidgets(
      'calls onUpdatePressed when WalletCard - UpdateWalletButton '
      'is pressed and user confirmed to save the update it',
      (tester) async {
        Wallet? updatedWallet;
        String? updatedName;
        const expectedName = 'new name';
        await pumpWidget(
          tester,
          onUpdatePressed: (account, name) {
            updatedWallet = account;
            updatedName = name;
          },
        );

        final updateableData = data.first;
        final updatedableCardFinder = find.byType(WalletCard).first;
        final cardWidget = tester.widget<WalletCard>(
          updatedableCardFinder,
        );
        expect(cardWidget.walletWithBalance, updateableData.walletWithBalance);

        final updateButtonFinder = find.descendant(
          of: updatedableCardFinder,
          matching: find.byType(UpdateWalletButton),
        );
        final updateButtonWidget = tester.widget<UpdateWalletButton>(
          updateButtonFinder,
        );
        expect(updateButtonWidget.onUpdatePressed, isNotNull);
        expect(updateButtonWidget.isUpdating, isFalse);
        await tester.tap(updateButtonFinder);
        await tester.pumpAndSettle();

        final formFinder = find.byType(WalletForm);
        expect(formFinder, findsOneWidget);
        await tester.enterText(
          find.descendant(
            of: formFinder,
            matching: find.byType(TextFormField),
          ),
          expectedName,
        );
        await tester.tap(
          find.descendant(
            of: formFinder,
            matching: find.byType(AppButton),
          ),
        );
        await tester.pumpAndSettle();

        expect(updatedWallet, updateableData.walletWithBalance.wallet);
        expect(updatedName, expectedName);
      },
    );
  });
}
