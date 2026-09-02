import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/transactions/bloc/add_transaction_bloc.dart';
import 'package:journexa_app/ui/transactions/widgets/add_transaction_view.dart';
import 'package:journexa_app/ui/transactions/widgets/transfer_money_form.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockWalletsBloc extends Mock implements WalletsBloc {}

class MockAddTransactionBloc extends Mock implements AddTransactionBloc {}

final expectedTranslations = {
  'id': {
    'transferSuccessToastTitle': 'Transfer tercatat',
    'transferSuccessToastMessage':
        'Transfer Rp 10.000 dari test ke wallet 2 telah tercatat',
    'transferFailureToastTitle': 'Gagal mencatat transfer',
    'transferFailureToastMessage': 'Terjadi kesalahan internal',
  },
  'en': {
    'transferSuccessToastTitle': 'Transfer recorded',
    'transferSuccessToastMessage':
        'Rp 10,000 transfer from test to wallet 2 have been recorded',
    'transferFailureToastTitle': 'Failed to record transfer',
    'transferFailureToastMessage': 'Internal exception error',
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
  late AddTransactionBloc mockAddTransactionBloc;

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

    mockAddTransactionBloc = MockAddTransactionBloc();
    whenListen(
      mockAddTransactionBloc,
      const Stream<AddTransactionState>.empty(),
      initialState: const AddTransactionState.initial(),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    required TransactionType type,
    Locale locale = const Locale('en'),
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: mockWalletsBloc),
          BlocProvider.value(value: mockAddTransactionBloc),
        ],
        child: AddTransactionView(type: type),
      ),
    );
  }

  group('transfer', () {
    final transferTransaction = Transaction.testTransfer(
      amount: Decimal.fromInt(10000),
      date: DateTime.now(),
      fee: Decimal.zero,
    );
    group('Render', () {
      testWidgets(
        'shows correct TransferMoneyForm',
        (tester) async {
          await pumpWidget(tester, type: TransactionType.transfer);

          final formFinder = find.byType(TransferMoneyForm);
          expect(formFinder, findsOneWidget);

          final widget = tester.widget<TransferMoneyForm>(formFinder);
          expect(widget.isProcessing, false);
          expect(widget.onTransferPressed, isNotNull);
        },
      );

      testWidgets(
        'set onTransferPressed=null and isProcessing=true on TransferMoneyForm '
        'when state is loading',
        (tester) async {
          whenListen(
            mockAddTransactionBloc,
            Stream<AddTransactionState>.value(
              const AddTransactionState.loading(),
            ),
            initialState: const AddTransactionState.initial(),
          );
          await pumpWidget(tester, type: TransactionType.transfer);
          await tester.pumpAndSettle();

          final formFinder = find.byType(TransferMoneyForm);
          expect(formFinder, findsOneWidget);

          final widget = tester.widget<TransferMoneyForm>(formFinder);
          expect(widget.isProcessing, true);
          expect(widget.onTransferPressed, isNull);
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'add correct AddTransactionEvent.transfer when onTransferPressed',
        (tester) async {
          await pumpWidget(tester, type: TransactionType.transfer);

          final now = DateTime.now();
          final finder = find.byType(TransferMoneyForm);
          final widget = tester.widget<TransferMoneyForm>(finder);
          widget.onTransferPressed!(
            source: wallets[0],
            destination: wallets[1],
            amount: Decimal.parse('100'),
            fee: Decimal.parse('1'),
            date: DateTime(now.year, now.month, now.day),
            notes: 'test',
          );

          verify(
            () => mockAddTransactionBloc.add(
              AddTransactionEvent.transfer(
                source: wallets[0],
                destination: wallets[1],
                amount: Decimal.parse('100'),
                fee: Decimal.parse('1'),
                date: DateTime(now.year, now.month, now.day),
                notes: 'test',
              ),
            ),
          ).called(1);
        },
      );
    });

    group('SideEffects', () {
      for (final locale in AppLocalizations.supportedLocales) {
        final translations = expectedTranslations[locale.languageCode]!;

        final transferSuccessToastTitle =
            translations['transferSuccessToastTitle']!;
        testWidgets(
          'shows correct toast title when transfer succeeded '
          'for ${locale.languageCode}',
          (tester) async {
            whenListen(
              mockAddTransactionBloc,
              Stream.value(AddTransactionState.added(transferTransaction)),
              initialState: const AddTransactionState.initial(),
            );
            await pumpWidget(
              tester,
              type: TransactionType.transfer,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(find.text(transferSuccessToastTitle), findsOneWidget);
            await tester.pumpAndSettle(kToastDuration);
          },
        );

        final transferSuccessToastMessage =
            translations['transferSuccessToastMessage']!;
        testWidgets(
          'shows correct toast description when transfer succeeded '
          'for ${locale.languageCode}',
          (tester) async {
            whenListen(
              mockAddTransactionBloc,
              Stream.value(
                AddTransactionState.added(transferTransaction),
              ),
              initialState: const AddTransactionState.initial(),
            );
            await pumpWidget(
              tester,
              type: TransactionType.transfer,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(find.text(transferSuccessToastMessage), findsOneWidget);
            await tester.pumpAndSettle(kToastDuration);
          },
        );

        final transferFailureToastTitle =
            translations['transferFailureToastTitle']!;
        testWidgets(
          'shows correct toast title when transfer failed '
          'for ${locale.languageCode}',
          (tester) async {
            whenListen(
              mockAddTransactionBloc,
              Stream.value(
                AddTransactionState.failure(
                  AppException.test(),
                ),
              ),
              initialState: const AddTransactionState.initial(),
            );
            await pumpWidget(
              tester,
              type: TransactionType.transfer,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(find.text(transferFailureToastTitle), findsOneWidget);
            await tester.pumpAndSettle(kToastDuration);
          },
        );

        final transferFailureToastMessage =
            translations['transferFailureToastMessage']!;
        testWidgets(
          'shows correct toast description when transfer failed '
          'for ${locale.languageCode}',
          (tester) async {
            whenListen(
              mockAddTransactionBloc,
              Stream.value(
                AddTransactionState.failure(
                  AppException.test(),
                ),
              ),
              initialState: const AddTransactionState.initial(),
            );
            await pumpWidget(
              tester,
              type: TransactionType.transfer,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(find.text(transferFailureToastMessage), findsOneWidget);
            await tester.pumpAndSettle(kToastDuration);
          },
        );
      }
    });

    group('a11y', () {
      for (final locale in AppLocalizations.supportedLocales) {
        final translations = expectedTranslations[locale.languageCode]!;

        final transferSuccessToastTitle =
            translations['transferSuccessToastTitle']!;
        final transferSuccessToastMessage =
            translations['transferSuccessToastMessage']!;
        testWidgets(
          'has correct semantics on toast when transfer succeeded '
          'for ${locale.languageCode}',
          (tester) async {
            whenListen(
              mockAddTransactionBloc,
              Stream.value(
                AddTransactionState.added(transferTransaction),
              ),
              initialState: const AddTransactionState.initial(),
            );
            await pumpWidget(
              tester,
              type: TransactionType.transfer,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(
              find.bySemanticsLabel(
                '$transferSuccessToastTitle\n$transferSuccessToastMessage',
              ),
              findsOneWidget,
            );
            await tester.pumpAndSettle(kToastDuration);
          },
        );

        final transferFailureToastTitle =
            translations['transferFailureToastTitle']!;
        final transferFailureToastMessage =
            translations['transferFailureToastMessage']!;
        testWidgets(
          'has correct semantics on toast when transfer failed '
          'for ${locale.languageCode}',
          (tester) async {
            whenListen(
              mockAddTransactionBloc,
              Stream.value(
                AddTransactionState.failure(
                  AppException.test(),
                ),
              ),
              initialState: const AddTransactionState.initial(),
            );
            await pumpWidget(
              tester,
              type: TransactionType.transfer,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(
              find.bySemanticsLabel(
                '$transferFailureToastTitle\n$transferFailureToastMessage',
              ),
              findsOneWidget,
            );
            await tester.pumpAndSettle(kToastDuration);
          },
        );
      }
    });
  });
}
