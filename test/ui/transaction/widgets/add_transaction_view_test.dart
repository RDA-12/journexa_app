import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/expense_categories/bloc/expense_categories_bloc.dart';
import 'package:journexa_app/ui/income_categories/bloc/income_categories_bloc.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/transactions/bloc/add_transaction_bloc.dart';
import 'package:journexa_app/ui/transactions/widgets/add_transaction_view.dart';
import 'package:journexa_app/ui/transactions/widgets/expense_form.dart';
import 'package:journexa_app/ui/transactions/widgets/income_form.dart';
import 'package:journexa_app/ui/transactions/widgets/transfer_money_form.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockWalletsBloc extends Mock implements WalletsBloc;

class MockIncomeCategoriesBloc extends Mock implements IncomeCategoriesBloc;

class MockExpenseCategoriesBloc extends Mock implements ExpenseCategoriesBloc;

class MockAddTransactionBloc extends Mock implements AddTransactionBloc;

final expectedTranslations = {
  'id': {
    'transferSuccessToastTitle': 'Transfer tercatat',
    'transferSuccessToastMessage':
        'Transfer Rp 10.000 dari wallet 0 ke wallet 1 telah tercatat',
    'transferFailureToastTitle': 'Gagal mencatat transfer',
    'transferFailureToastMessage': 'Terjadi kesalahan internal',
    'incomeSuccessToastTitle': 'Pendapatan tercatat',
    'incomeSuccessToastMessage':
        'Pendapatan Rp 10.000 ke wallet 0 untuk category 0 telah tercatat',
    'incomeFailureToastTitle': 'Gagal mencatat pendapatan',
    'incomeFailureToastMessage': 'Terjadi kesalahan internal',
    'expenseSuccessToastTitle': 'Pengeluaran tercatat',
    'expenseSuccessToastMessage':
        'Pengeluaran Rp 10.000 dari wallet 0 untuk category 0 telah tercatat',
    'expenseFailureToastTitle': 'Gagal mencatat pengeluaran',
    'expenseFailureToastMessage': 'Terjadi kesalahan internal',
  },
  'en': {
    'transferSuccessToastTitle': 'Transfer recorded',
    'transferSuccessToastMessage':
        'Rp 10,000 transfer from wallet 0 to wallet 1 have been recorded',
    'transferFailureToastTitle': 'Failed to record transfer',
    'transferFailureToastMessage': 'Internal exception error',
    'incomeSuccessToastTitle': 'Income recorded',
    'incomeSuccessToastMessage':
        'Rp 10,000 income to wallet 0 for category 0 have been recorded',
    'incomeFailureToastTitle': 'Failed to record income',
    'incomeFailureToastMessage': 'Internal exception error',
    'expenseSuccessToastTitle': 'Expense recorded',
    'expenseSuccessToastMessage':
        'Rp 10,000 expense from wallet 0 for category 0 have been recorded',
    'expenseFailureToastTitle': 'Failed to record expense',
    'expenseFailureToastMessage': 'Internal exception error',
  },
};

void main() {
  final wallets = List.generate(5, (index) {
    return Wallet.test().update(name: 'wallet $index').copyWith(id: '$index');
  }).toList();
  final blocWallets = wallets.map((it) {
    return WalletUIModel(
      wallet: it,
      balance: Decimal.zero,
    );
  }).toList();

  final incomeCategories = List.generate(5, (index) {
    return IncomeCategory.test()
        .update(name: 'category $index')
        .copyWith(id: '$index');
  }).toList();
  final blocIncomeCategories = incomeCategories.map((it) {
    return IncomeCategoryUIModel(category: it);
  }).toList();

  final expenseCategories = List.generate(5, (index) {
    return ExpenseCategory.test()
        .update(name: 'category $index')
        .copyWith(id: '$index');
  }).toList();
  final blocExpenseCategories = expenseCategories.map((it) {
    return ExpenseCategoryUIModel(category: it);
  }).toList();

  late WalletsBloc mockWalletsBloc;
  late IncomeCategoriesBloc mockIncomeCategoriesBloc;
  late ExpenseCategoriesBloc mockExpenseCategoriesBloc;
  late AddTransactionBloc mockAddTransactionBloc;

  setUp(() {
    mockWalletsBloc = MockWalletsBloc();
    whenListen(
      mockWalletsBloc,
      Stream<WalletsState>.value(
        WalletsState(
          status: WalletsUIStatus.loaded,
          wallets: blocWallets,
        ),
      ),
      initialState: const WalletsState(),
    );

    mockIncomeCategoriesBloc = MockIncomeCategoriesBloc();
    whenListen(
      mockIncomeCategoriesBloc,
      Stream<IncomeCategoriesState>.value(
        IncomeCategoriesState(
          status: IncomeCategoriesUIStatus.loaded,
          categories: blocIncomeCategories,
        ),
      ),
      initialState: const IncomeCategoriesState(),
    );

    mockExpenseCategoriesBloc = MockExpenseCategoriesBloc();
    whenListen(
      mockExpenseCategoriesBloc,
      Stream<ExpenseCategoriesState>.value(
        ExpenseCategoriesState(
          status: ExpenseCategoriesUIStatus.loaded,
          categories: blocExpenseCategories,
        ),
      ),
      initialState: const ExpenseCategoriesState(),
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
          BlocProvider.value(value: mockIncomeCategoriesBloc),
          BlocProvider.value(value: mockExpenseCategoriesBloc),
          BlocProvider.value(value: mockAddTransactionBloc),
        ],
        child: AddTransactionView(type: type),
      ),
    );
  }

  group('transfer', () {
    final transferNotice = TransactionAddedNotice.transferAdded(
      source: wallets.first,
      destination: wallets[1],
      amount: Decimal.fromInt(10000),
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
              Stream.value(AddTransactionState.added(transferNotice)),
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
                AddTransactionState.added(transferNotice),
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
                AddTransactionState.added(transferNotice),
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

  group('income', () {
    final incomeNotice = TransactionAddedNotice.incomeAdded(
      wallet: wallets.first,
      category: incomeCategories.first,
      amount: Decimal.fromInt(10000),
    );
    group('Render', () {
      testWidgets(
        'shows correct IncomeForm',
        (tester) async {
          await pumpWidget(tester, type: TransactionType.income);

          final formFinder = find.byType(IncomeForm);
          expect(formFinder, findsOneWidget);

          final widget = tester.widget<IncomeForm>(formFinder);
          expect(widget.isProcessing, false);
          expect(widget.onAddIncomePressed, isNotNull);
        },
      );

      testWidgets(
        'set onAddIncomePressed=null and isProcessing=true on IncomeForm '
        'when state is loading',
        (tester) async {
          whenListen(
            mockAddTransactionBloc,
            Stream<AddTransactionState>.value(
              const AddTransactionState.loading(),
            ),
            initialState: const AddTransactionState.initial(),
          );
          await pumpWidget(tester, type: TransactionType.income);
          await tester.pumpAndSettle();

          final formFinder = find.byType(IncomeForm);
          expect(formFinder, findsOneWidget);

          final widget = tester.widget<IncomeForm>(formFinder);
          expect(widget.isProcessing, true);
          expect(widget.onAddIncomePressed, isNull);
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'add correct AddTransactionEvent.income when onAddIncomePressed',
        (tester) async {
          await pumpWidget(tester, type: TransactionType.income);

          final now = DateTime.now();
          final finder = find.byType(IncomeForm);
          final widget = tester.widget<IncomeForm>(finder);
          widget.onAddIncomePressed!(
            wallet: wallets[0],
            category: incomeCategories[0],
            amount: Decimal.parse('100'),
            date: DateTime(now.year, now.month, now.day),
            notes: 'test',
          );

          verify(
            () => mockAddTransactionBloc.add(
              AddTransactionEvent.income(
                wallet: wallets[0],
                category: incomeCategories[0],
                amount: Decimal.parse('100'),
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

        final incomeSuccessToastTitle =
            translations['incomeSuccessToastTitle']!;
        testWidgets(
          'shows correct toast title when income succeeded '
          'for ${locale.languageCode}',
          (tester) async {
            whenListen(
              mockAddTransactionBloc,
              Stream.value(AddTransactionState.added(incomeNotice)),
              initialState: const AddTransactionState.initial(),
            );
            await pumpWidget(
              tester,
              type: TransactionType.income,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(find.text(incomeSuccessToastTitle), findsOneWidget);
            await tester.pumpAndSettle(kToastDuration);
          },
        );

        final incomeSuccessToastMessage =
            translations['incomeSuccessToastMessage']!;
        testWidgets(
          'shows correct toast description when income succeeded '
          'for ${locale.languageCode}',
          (tester) async {
            whenListen(
              mockAddTransactionBloc,
              Stream.value(
                AddTransactionState.added(incomeNotice),
              ),
              initialState: const AddTransactionState.initial(),
            );
            await pumpWidget(
              tester,
              type: TransactionType.income,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(find.text(incomeSuccessToastMessage), findsOneWidget);
            await tester.pumpAndSettle(kToastDuration);
          },
        );

        final incomeFailureToastTitle =
            translations['incomeFailureToastTitle']!;
        testWidgets(
          'shows correct toast title when income failed '
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
              type: TransactionType.income,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(find.text(incomeFailureToastTitle), findsOneWidget);
            await tester.pumpAndSettle(kToastDuration);
          },
        );

        final incomeFailureToastMessage =
            translations['incomeFailureToastMessage']!;
        testWidgets(
          'shows correct toast description when income failed '
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
              type: TransactionType.income,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(find.text(incomeFailureToastMessage), findsOneWidget);
            await tester.pumpAndSettle(kToastDuration);
          },
        );
      }
    });

    group('a11y', () {
      for (final locale in AppLocalizations.supportedLocales) {
        final translations = expectedTranslations[locale.languageCode]!;

        final incomeSuccessToastTitle =
            translations['incomeSuccessToastTitle']!;
        final incomeSuccessToastMessage =
            translations['incomeSuccessToastMessage']!;
        testWidgets(
          'has correct semantics on toast when income succeeded '
          'for ${locale.languageCode}',
          (tester) async {
            whenListen(
              mockAddTransactionBloc,
              Stream.value(
                AddTransactionState.added(incomeNotice),
              ),
              initialState: const AddTransactionState.initial(),
            );
            await pumpWidget(
              tester,
              type: TransactionType.income,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(
              find.bySemanticsLabel(
                '$incomeSuccessToastTitle\n$incomeSuccessToastMessage',
              ),
              findsOneWidget,
            );
            await tester.pumpAndSettle(kToastDuration);
          },
        );

        final incomeFailureToastTitle =
            translations['incomeFailureToastTitle']!;
        final incomeFailureToastMessage =
            translations['incomeFailureToastMessage']!;
        testWidgets(
          'has correct semantics on toast when income failed '
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
              type: TransactionType.income,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(
              find.bySemanticsLabel(
                '$incomeFailureToastTitle\n$incomeFailureToastMessage',
              ),
              findsOneWidget,
            );
            await tester.pumpAndSettle(kToastDuration);
          },
        );
      }
    });
  });

  group('expense', () {
    final expenseNotice = TransactionAddedNotice.expenseAdded(
      wallet: wallets.first,
      category: expenseCategories.first,
      amount: Decimal.fromInt(10000),
    );
    group('Render', () {
      testWidgets(
        'shows correct ExpenseForm',
        (tester) async {
          await pumpWidget(tester, type: TransactionType.expense);

          final formFinder = find.byType(ExpenseForm);
          expect(formFinder, findsOneWidget);

          final widget = tester.widget<ExpenseForm>(formFinder);
          expect(widget.isProcessing, false);
          expect(widget.onAddExpensePressed, isNotNull);
        },
      );

      testWidgets(
        'set onAddExpensePressed=null and isProcessing=true on ExpenseForm '
        'when state is loading',
        (tester) async {
          whenListen(
            mockAddTransactionBloc,
            Stream<AddTransactionState>.value(
              const AddTransactionState.loading(),
            ),
            initialState: const AddTransactionState.initial(),
          );
          await pumpWidget(tester, type: TransactionType.expense);
          await tester.pumpAndSettle();

          final formFinder = find.byType(ExpenseForm);
          expect(formFinder, findsOneWidget);

          final widget = tester.widget<ExpenseForm>(formFinder);
          expect(widget.isProcessing, true);
          expect(widget.onAddExpensePressed, isNull);
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'add correct AddTransactionEvent.expense when onAddExpensePressed',
        (tester) async {
          await pumpWidget(tester, type: TransactionType.expense);

          final now = DateTime.now();
          final finder = find.byType(ExpenseForm);
          final widget = tester.widget<ExpenseForm>(finder);
          widget.onAddExpensePressed!(
            wallet: wallets[0],
            category: expenseCategories[0],
            amount: Decimal.parse('100'),
            date: DateTime(now.year, now.month, now.day),
            notes: 'test',
          );

          verify(
            () => mockAddTransactionBloc.add(
              AddTransactionEvent.expense(
                wallet: wallets[0],
                category: expenseCategories[0],
                amount: Decimal.parse('100'),
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

        final expenseSuccessToastTitle =
            translations['expenseSuccessToastTitle']!;
        testWidgets(
          'shows correct toast title when expense succeeded '
          'for ${locale.languageCode}',
          (tester) async {
            whenListen(
              mockAddTransactionBloc,
              Stream.value(AddTransactionState.added(expenseNotice)),
              initialState: const AddTransactionState.initial(),
            );
            await pumpWidget(
              tester,
              type: TransactionType.expense,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(find.text(expenseSuccessToastTitle), findsOneWidget);
            await tester.pumpAndSettle(kToastDuration);
          },
        );

        final expenseSuccessToastMessage =
            translations['expenseSuccessToastMessage']!;
        testWidgets(
          'shows correct toast description when expense succeeded '
          'for ${locale.languageCode}',
          (tester) async {
            whenListen(
              mockAddTransactionBloc,
              Stream.value(
                AddTransactionState.added(expenseNotice),
              ),
              initialState: const AddTransactionState.initial(),
            );
            await pumpWidget(
              tester,
              type: TransactionType.expense,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(find.text(expenseSuccessToastMessage), findsOneWidget);
            await tester.pumpAndSettle(kToastDuration);
          },
        );

        final expenseFailureToastTitle =
            translations['expenseFailureToastTitle']!;
        testWidgets(
          'shows correct toast title when expense failed '
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
              type: TransactionType.expense,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(find.text(expenseFailureToastTitle), findsOneWidget);
            await tester.pumpAndSettle(kToastDuration);
          },
        );

        final expenseFailureToastMessage =
            translations['expenseFailureToastMessage']!;
        testWidgets(
          'shows correct toast description when expense failed '
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
              type: TransactionType.expense,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(find.text(expenseFailureToastMessage), findsOneWidget);
            await tester.pumpAndSettle(kToastDuration);
          },
        );
      }
    });

    group('a11y', () {
      for (final locale in AppLocalizations.supportedLocales) {
        final translations = expectedTranslations[locale.languageCode]!;

        final expenseSuccessToastTitle =
            translations['expenseSuccessToastTitle']!;
        final expenseSuccessToastMessage =
            translations['expenseSuccessToastMessage']!;
        testWidgets(
          'has correct semantics on toast when expense succeeded '
          'for ${locale.languageCode}',
          (tester) async {
            whenListen(
              mockAddTransactionBloc,
              Stream.value(
                AddTransactionState.added(expenseNotice),
              ),
              initialState: const AddTransactionState.initial(),
            );
            await pumpWidget(
              tester,
              type: TransactionType.expense,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(
              find.bySemanticsLabel(
                '$expenseSuccessToastTitle\n$expenseSuccessToastMessage',
              ),
              findsOneWidget,
            );
            await tester.pumpAndSettle(kToastDuration);
          },
        );

        final expenseFailureToastTitle =
            translations['expenseFailureToastTitle']!;
        final expenseFailureToastMessage =
            translations['expenseFailureToastMessage']!;
        testWidgets(
          'has correct semantics on toast when expense failed '
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
              type: TransactionType.expense,
              locale: locale,
            );
            await tester.pumpAndSettle();

            expect(
              find.bySemanticsLabel(
                '$expenseFailureToastTitle\n$expenseFailureToastMessage',
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
