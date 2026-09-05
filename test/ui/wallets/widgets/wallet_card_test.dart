import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:journexa_app/ui/wallets/widgets/delete_wallet_button.dart';
import 'package:journexa_app/ui/wallets/widgets/update_wallet_button.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_card.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_form.dart';

import '../../util.dart';

final expectedTranslations = {
  'id': {
    'semantics': 'Dompet Hitam, Saldo Rp 10.000',
    'balance': 'Rp 10.000',
  },
  'en': {
    'semantics': 'Dompet Hitam, Balance Rp 10,000',
    'balance': 'Rp 10,000',
  },
};

void main() {
  final walletData = WalletUIModel(
    wallet: Wallet(
      id: 'id',
      name: 'Dompet Hitam',
      account: Account.user(
        parent: SystemDefinedAccount.rootAsset,
        name: 'Dompet Hitam',
        currentChildrenCount: 0,
      ),
    ),
    balance: Decimal.fromInt(10000),
  );

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool isDeleting = false,
    VoidCallback? onDeletePressed,
    bool isUpdating = false,
    void Function(String)? onUpdatePressed,
  }) async {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: WalletCard(
        data: walletData,
        isDeleting: isDeleting,
        onDeletePressed: onDeletePressed ?? () {},
        isUpdating: isUpdating,
        onUpdatePressed: onUpdatePressed ?? (v) {},
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows correct name',
      (tester) async {
        await pumpWidget(tester);

        expect(find.text(walletData.wallet.name), findsOneWidget);
      },
    );

    for (final locale in AppLocalizations.supportedLocales) {
      final expectedBalance =
          expectedTranslations[locale.languageCode]!['balance']!;
      testWidgets(
        'shows correct formatted balance for ${locale.toLanguageTag()}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.text(expectedBalance), findsOneWidget);
        },
      );
    }

    testWidgets('shows correct Initials', (tester) async {
      await pumpWidget(tester);

      expect(find.text('DH'), findsOneWidget);
    });

    testWidgets(
      'shows DeleteWalletButton',
      (tester) async {
        await pumpWidget(tester);

        final finder = find.byType(DeleteWalletButton);
        expect(finder, findsOneWidget);
        final widget = tester.widget<DeleteWalletButton>(finder);
        expect(widget.wallet, walletData.wallet);
      },
    );

    testWidgets(
      'shows UpdateWalletButton',
      (tester) async {
        await pumpWidget(tester);

        final finder = find.byType(UpdateWalletButton);
        expect(finder, findsOneWidget);
        final widget = tester.widget<UpdateWalletButton>(finder);
        expect(widget.wallet, walletData.wallet);
      },
    );

    testWidgets(
      'disabled DeleteWalletButton when isDeleting is true',
      (tester) async {
        await pumpWidget(tester, isDeleting: true);

        final finder = find.byType(DeleteWalletButton);
        expect(finder, findsOneWidget);
        final buttonFinder = find.descendant(
          of: finder,
          matching: find.byType(AppButton),
        );
        final widget = tester.widget<AppButton>(buttonFinder);
        expect(widget.onPressed, isNull);
      },
    );

    testWidgets(
      'disabled DeleteWalletButton when isUpdating is true',
      (tester) async {
        await pumpWidget(tester, isUpdating: true);

        final finder = find.byType(DeleteWalletButton);
        expect(finder, findsOneWidget);
        final buttonFinder = find.descendant(
          of: finder,
          matching: find.byType(AppButton),
        );
        final widget = tester.widget<AppButton>(buttonFinder);
        expect(widget.onPressed, isNull);
      },
    );

    testWidgets(
      'disabled UpdateWalletButton when isDeleting is true',
      (tester) async {
        await pumpWidget(tester, isDeleting: true);

        final finder = find.byType(UpdateWalletButton);
        expect(finder, findsOneWidget);
        final buttonFinder = find.descendant(
          of: finder,
          matching: find.byType(AppButton),
        );
        final widget = tester.widget<AppButton>(buttonFinder);
        expect(widget.onPressed, isNull);
      },
    );

    testWidgets(
      'disabled UpdateWalletButton when isUpdating is true',
      (tester) async {
        await pumpWidget(tester, isUpdating: true);

        final finder = find.byType(UpdateWalletButton);
        expect(finder, findsOneWidget);
        final buttonFinder = find.descendant(
          of: finder,
          matching: find.byType(AppButton),
        );
        final widget = tester.widget<AppButton>(buttonFinder);
        expect(widget.onPressed, isNull);
      },
    );
  });

  group('Interactions', () {
    testWidgets(
      'calls onDeletePressed when DeleteWalletButton pressed '
      'and user confirmed to delete it',
      (tester) async {
        var isDeleted = false;
        await pumpWidget(
          tester,
          onDeletePressed: () {
            isDeleted = true;
          },
        );

        final finder = find.byType(DeleteWalletButton);
        await tester.tap(finder);
        await tester.pump();

        await tester.tap(
          find.descendant(
            of: find.byType(AppDialog),
            matching: find.text('Delete'),
          ),
        );
        await tester.pump();

        expect(isDeleted, isTrue);
      },
    );

    testWidgets(
      'calls onUpdatePressed with correct name '
      'when UpdateWalletButton pressed and user save the updated data',
      (tester) async {
        String? newName;
        const expectedName = 'name';

        await pumpWidget(
          tester,
          onUpdatePressed: (name) {
            newName = name;
          },
        );

        await tester.tap(find.byType(UpdateWalletButton));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), expectedName);
        await tester.tap(
          find.descendant(
            of: find.byType(WalletForm),
            matching: find.byType(AppButton),
          ),
        );
        await tester.pumpAndSettle();

        expect(newName, expectedName);
      },
    );
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedSemantics =
          expectedTranslations[locale.toLanguageTag()]!['semantics']!;
      testWidgets(
        'has correct semantics for locale $locale',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.bySemanticsLabel(expectedSemantics), findsOneWidget);
        },
      );
    }
  });
}
