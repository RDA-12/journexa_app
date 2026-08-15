import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/cash_account_card.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';

import '../../util.dart';

final expectedTranslations = {
  'id': {
    'semantics': 'Dompet Hitam, Rp 10.000',
    'balance': 'Rp 10.000',
  },
  'en': {
    'semantics': 'Dompet Hitam, Rp 10,000',
    'balance': 'Rp 10,000',
  },
};

void main() {
  final accountBalance = AccountBalance(
    account: Account(
      code: '10.0001',
      name: 'Dompet Hitam',
      type: AccountType.asset,
    ),
    balance: Decimal.fromInt(10000),
  );

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: CashAccountCard(
        accountBalance: accountBalance,
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows correct name',
      (tester) async {
        await pumpWidget(tester);

        expect(find.text(accountBalance.account.name), findsOneWidget);
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

    testWidgets('shows correct Monogram', (tester) async {
      await pumpWidget(tester);

      expect(find.text('DH'), findsOneWidget);
    });
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
