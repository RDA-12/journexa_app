import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/transactions/widgets/transfer_money_form.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_selector.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockWalletsBloc extends Mock implements WalletsBloc {}

final expectedTranslations = {
  'id': {
    'sourceLabel': 'Dompet Sumber',
    'destinationLabel': 'Dompet Tujuan',
    'dateLabel': 'Tanggal',
    'amountLabel': 'Jumlah',
    'feeLabel': 'Biaya Transfer',
    'notesLabel': 'Catatan',
    'submitButton': 'Transfer',
  },
  'en': {
    'sourceLabel': 'Source Wallet',
    'destinationLabel': 'Destination Wallet',
    'dateLabel': 'Date',
    'amountLabel': 'Amount',
    'feeLabel': 'Transfer Fee',
    'notesLabel': 'Notes',
    'submitButton': 'Transfer',
  },
};

void main() {
  final wallets = List.generate(5, (index) {
    return Wallet.test().update(name: 'wallet $index').copyWith(id: '$index');
  }).toList();
  final blocWallets = wallets.map((it) {
    return WalletWithBalanceState(
      walletWithBalance: WalletWithBalance(wallet: it, balance: Decimal.zero),
    );
  }).toList();

  late WalletsBloc mockWalletsBloc;

  setUp(() {
    mockWalletsBloc = MockWalletsBloc();
    whenListen(
      mockWalletsBloc,
      Stream<WalletsState>.value(
        WalletsState(
          status: WalletsStatus.loaded,
          walletWithBalances: blocWallets,
        ),
      ),
      initialState: const WalletsState(),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool isProcessing = false,
    OnTransferPressed? onTransferPressed,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: BlocProvider.value(
        value: mockWalletsBloc,
        child: TransferMoneyForm(
          isProcessing: isProcessing,
          onTransferPressed: onTransferPressed,
        ),
      ),
    );
  }

  group('Render', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final translations = expectedTranslations[locale.languageCode]!;

      final dateLabel = translations['dateLabel']!;
      testWidgets(
        'shows AppDateTimeFormField with label $dateLabel '
        'for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          final labelFinder = find.text('$dateLabel *');
          expect(labelFinder, findsOneWidget);

          final formFinder = find.ancestor(
            of: labelFinder,
            matching: find.byType(AppDateTimeFormField),
          );
          expect(formFinder, findsOneWidget);
        },
      );

      final sourceLabel = translations['sourceLabel']!;
      testWidgets(
        'shows WalletSelector for source wallet with label $sourceLabel '
        'for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          final labelFinder = find.text('$sourceLabel *');
          expect(labelFinder, findsOneWidget);

          final selectorFinder = find.ancestor(
            of: labelFinder,
            matching: find.byType(WalletSelector),
          );
          expect(selectorFinder, findsOneWidget);
        },
      );

      final destinationLabel = translations['destinationLabel']!;
      testWidgets(
        'shows WalletSelector for source wallet with label $destinationLabel '
        'for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          final labelFinder = find.text('$destinationLabel *');
          expect(labelFinder, findsOneWidget);

          final selectorFinder = find.ancestor(
            of: labelFinder,
            matching: find.byType(WalletSelector),
          );
          expect(selectorFinder, findsOneWidget);
        },
      );

      final amountLabel = translations['amountLabel']!;
      testWidgets(
        'shows AppDecimalFormField with label $amountLabel '
        'for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          final labelFinder = find.text('$amountLabel *');
          expect(labelFinder, findsOneWidget);

          final formFinder = find.ancestor(
            of: labelFinder,
            matching: find.byType(AppDecimalFormField),
          );
          expect(formFinder, findsOneWidget);
        },
      );

      final feeLabel = translations['feeLabel']!;
      testWidgets(
        'shows AppDecimalFormField with label $feeLabel '
        'for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          final labelFinder = find.text(feeLabel);
          expect(labelFinder, findsOneWidget);

          final formFinder = find.ancestor(
            of: labelFinder,
            matching: find.byType(AppDecimalFormField),
          );
          expect(formFinder, findsOneWidget);
        },
      );

      final notesLabel = translations['notesLabel']!;
      testWidgets(
        'showsFormField with label $notesLabel '
        'for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          final labelFinder = find.text(notesLabel);
          expect(labelFinder, findsOneWidget);

          final formFinder = find.ancestor(
            of: labelFinder,
            matching: find.byType(AppFormField),
          );
          expect(formFinder, findsOneWidget);
        },
      );

      final submitButtonText = translations['submitButton']!;
      testWidgets(
        'shows AppButton with label $submitButtonText '
        'for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          final labelFinder = find.text(submitButtonText);
          expect(labelFinder, findsOneWidget);

          final buttonFinder = find.ancestor(
            of: labelFinder,
            matching: find.byType(AppButton),
          );
          expect(buttonFinder, findsOneWidget);
        },
      );
    }

    testWidgets(
      'submit button disabled when isProcessing true',
      (tester) async {
        await pumpWidget(tester, isProcessing: true);

        final buttonFinder = find.byType(AppButton);
        expect(buttonFinder, findsOneWidget);

        final button = tester.widget<AppButton>(buttonFinder);
        expect(button.onPressed, isNull);
      },
    );

    testWidgets(
      'submit button disabled when onTransferPressed null',
      (tester) async {
        // ignore: avoid_redundant_argument_values for testing purposes
        await pumpWidget(tester, onTransferPressed: null);

        final buttonFinder = find.byType(AppButton);
        expect(buttonFinder, findsOneWidget);

        final button = tester.widget<AppButton>(buttonFinder);
        expect(button.onPressed, isNull);
      },
    );
  });

  group('Interactions', () {
    testWidgets(
      'calls onTransferPressed when submit button pressed',
      (tester) async {
        final now = DateTime.now();
        final expected = {
          'source': wallets[0],
          'destination': wallets[1],
          'amount': Decimal.parse('100'),
          'fee': Decimal.parse('1'),
          'date': DateTime(now.year, now.month, now.day),
          'notes': 'test',
        };
        final args = <String, Object?>{};
        await pumpWidget(
          tester,
          onTransferPressed:
              ({
                required source,
                required destination,
                required amount,
                required fee,
                required date,
                notes,
              }) {
                args['source'] = source;
                args['destination'] = destination;
                args['amount'] = amount;
                args['fee'] = fee;
                args['date'] = date;
                args['notes'] = notes;
              },
        );

        final dateFormFinder = find.byType(AppDateTimeFormField);
        await tester.tap(dateFormFinder);
        await tester.pumpAndSettle();
        await tester.tap(find.text(now.day.toString()));
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        final sourceSelectorFinder = find.ancestor(
          of: find.text('Source Wallet *'),
          matching: find.byType(WalletSelector),
        );
        await tester.tap(sourceSelectorFinder);
        await tester.pumpAndSettle();
        await tester.tap(find.text(wallets[0].name));
        await tester.pumpAndSettle();

        final destSelectorFinder = find.ancestor(
          of: find.text('Destination Wallet *'),
          matching: find.byType(WalletSelector),
        );
        await tester.tap(destSelectorFinder);
        await tester.pumpAndSettle();
        await tester.tap(find.text(wallets[1].name));
        await tester.pumpAndSettle();

        final amountFormFinder = find.ancestor(
          of: find.text('Amount *'),
          matching: find.byType(AppDecimalFormField),
        );
        await tester.enterText(amountFormFinder, '100');

        final feeFormFinder = find.ancestor(
          of: find.text('Transfer Fee'),
          matching: find.byType(AppDecimalFormField),
        );
        await tester.enterText(feeFormFinder, '1');

        final notesFormFinder = find.ancestor(
          of: find.text('Notes'),
          matching: find.byType(AppFormField),
        );
        await tester.enterText(notesFormFinder, 'test');

        final buttonFinder = find.byType(AppButton);
        await tester.tap(buttonFinder);
        await tester.pump();

        expect(args, expected);
      },
    );
  });
}
