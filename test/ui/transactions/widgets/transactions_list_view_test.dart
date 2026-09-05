import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/transactions/bloc/transactions_bloc.dart';
import 'package:journexa_app/ui/transactions/widgets/transactions_list_view.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockTransactionsBloc extends Mock implements TransactionsBloc {}

final expectedTranslations = {
  'id': {
    'errorTitle': 'Gagal mendapatkan data transaksi',
    'errorDesc': 'Terjadi kesalahan internal',
    'semanticsLoading': 'Memuat data transaksi',
    'emptyTitle': 'Data Tidak Ditemukan',
    'emptyDescription': 'Tidak ada data transaksi yang ditemukan',
  },
  'en': {
    'errorTitle': 'Failed to get transactions data',
    'errorDesc': 'Internal exception error',
    'semanticsLoading': 'Loading transactions data',
    'emptyTitle': 'Data Not Found',
    'emptyDescription': 'No transactions data was found',
  },
};

void main() {
  final date = DateTime(2026, 9, 5, 12);
  final amount = Decimal.fromInt(50000);

  final wallet = Wallet.test().copyWith(
    name: 'Main Wallet',
    account: Account.test().copyWith(
      name: 'Main Wallet',
      parent: SystemDefinedAccount.rootAsset,
    ),
  );

  final category = IncomeCategory.test().copyWith(
    name: 'Salary',
    account: Account.test(AccountType.revenue).copyWith(
      name: 'Salary',
      parent: SystemDefinedAccount.rootRevenue,
    ),
  );

  final transactions = List.generate(3, (index) {
    return TransactionUIModel.income(
      id: '$index',
      wallet: wallet,
      category: category,
      amount: amount,
      date: date,
    );
  });

  late TransactionsBloc mockTransactionsBloc;

  setUp(() {
    mockTransactionsBloc = MockTransactionsBloc();
    whenListen(
      mockTransactionsBloc,
      const Stream<TransactionsState>.empty(),
      initialState: const TransactionsState.initial(),
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
        value: mockTransactionsBloc,
        child: const TransactionsListView(),
      ),
    );
  }

  group('Render', () {
    testWidgets('shows SizedBox.shrink when state is initial', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(LoadingIndicator), findsNothing);
      expect(find.byType(AppEmptyBox), findsNothing);
      expect(find.byType(AppExceptionBox), findsNothing);
      expect(find.byType(AppListView<TransactionUIModel>), findsNothing);
    });

    testWidgets('shows LoadingIndicator when state is loading', (tester) async {
      whenListen(
        mockTransactionsBloc,
        const Stream<TransactionsState>.empty(),
        initialState: const TransactionsState.loading(),
      );

      await pumpWidget(tester);

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets(
      'shows AppListView with correct transactions when state is loaded',
      (tester) async {
        whenListen(
          mockTransactionsBloc,
          const Stream<TransactionsState>.empty(),
          initialState: TransactionsState.loaded(transactions),
        );

        await pumpWidget(tester);

        final finder = find.byType(AppListView<TransactionUIModel>);
        expect(finder, findsOneWidget);
        final widget = tester.widget<AppListView<TransactionUIModel>>(finder);
        expect(widget.items, transactions);
      },
    );

    for (final locale in AppLocalizations.supportedLocales) {
      final expectedTranslation = expectedTranslations[locale.languageCode]!;

      testWidgets(
        'shows AppExceptionBox when state is failure '
        'for ${locale.languageCode}',
        (tester) async {
          final expectedTitle = expectedTranslation['errorTitle']!;
          final expectedDesc = expectedTranslation['errorDesc']!;

          whenListen(
            mockTransactionsBloc,
            const Stream<TransactionsState>.empty(),
            initialState: TransactionsState.failure(AppException.test()),
          );

          await pumpWidget(tester, locale: locale);

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.title, expectedTitle);
          expect(widget.description, expectedDesc);
        },
      );

      final expectedEmptyTitle = expectedTranslation['emptyTitle']!;
      testWidgets(
        'shows AppEmptyBox with $expectedEmptyTitle title '
        'for ${locale.languageCode}',
        (tester) async {
          whenListen(
            mockTransactionsBloc,
            const Stream<TransactionsState>.empty(),
            initialState: const TransactionsState.loaded([]),
          );

          await pumpWidget(tester, locale: locale);

          final finder = find.byType(AppEmptyBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppEmptyBox>(finder);
          expect(widget.title, expectedEmptyTitle);
        },
      );

      final expectedEmptyDesc = expectedTranslation['emptyDescription']!;
      testWidgets(
        'shows AppEmptyBox with $expectedEmptyDesc description '
        'for ${locale.languageCode}',
        (tester) async {
          whenListen(
            mockTransactionsBloc,
            const Stream<TransactionsState>.empty(),
            initialState: const TransactionsState.loaded([]),
          );

          await pumpWidget(tester, locale: locale);

          final finder = find.byType(AppEmptyBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppEmptyBox>(finder);
          expect(widget.description, expectedEmptyDesc);
        },
      );
    }
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedTranslation = expectedTranslations[locale.languageCode]!;
      final expectedSemantics = expectedTranslation['semanticsLoading']!;

      testWidgets(
        'has $expectedSemantics when state is loading '
        'for ${locale.languageCode}',
        (tester) async {
          whenListen(
            mockTransactionsBloc,
            const Stream<TransactionsState>.empty(),
            initialState: const TransactionsState.loading(),
          );

          await pumpWidget(tester, locale: locale);

          expect(find.bySemanticsLabel(expectedSemantics), findsOneWidget);
        },
      );
    }
  });
}
