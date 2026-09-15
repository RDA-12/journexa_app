import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/ui/expense_categories/bloc/expense_categories_bloc.dart';
import 'package:journexa_app/ui/income_categories/bloc/income_categories_bloc.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/transactions/add_transaction_page.dart';
import 'package:journexa_app/ui/transactions/bloc/add_transaction_bloc.dart';
import 'package:journexa_app/ui/transactions/widgets/add_transaction_view.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../util.dart';

class MockWalletsBloc extends Mock implements WalletsBloc;

class MockIncomeCategoriesBloc extends Mock implements IncomeCategoriesBloc;

class MockExpenseCategoriesBloc extends Mock implements ExpenseCategoriesBloc;

class MockAddTransactionBloc extends Mock implements AddTransactionBloc;

final expectedTranslations = {
  'id': {'title': 'Catat transaksi baru'},
  'en': {'title': 'Record new transaction'},
};

void main() {
  late WalletsBloc mockWalletsBloc;
  late IncomeCategoriesBloc mockIncomeCategoriesBloc;
  late ExpenseCategoriesBloc mockExpenseCategoriesBloc;
  late AddTransactionBloc mockAddTransactionBloc;

  setUp(() {
    mockWalletsBloc = MockWalletsBloc();
    whenListen(
      mockWalletsBloc,
      const Stream<WalletsState>.empty(),
      initialState: const WalletsState(),
    );
    when(mockWalletsBloc.close).thenAnswer((_) async {});

    mockIncomeCategoriesBloc = MockIncomeCategoriesBloc();
    whenListen(
      mockIncomeCategoriesBloc,
      const Stream<IncomeCategoriesState>.empty(),
      initialState: const IncomeCategoriesState(),
    );
    when(mockIncomeCategoriesBloc.close).thenAnswer((_) async {});

    mockExpenseCategoriesBloc = MockExpenseCategoriesBloc();
    whenListen(
      mockExpenseCategoriesBloc,
      const Stream<ExpenseCategoriesState>.empty(),
      initialState: const ExpenseCategoriesState(),
    );
    when(mockExpenseCategoriesBloc.close).thenAnswer((_) async {});

    mockAddTransactionBloc = MockAddTransactionBloc();
    whenListen(
      mockAddTransactionBloc,
      const Stream<AddTransactionState>.empty(),
      initialState: const AddTransactionState.initial(),
    );
    when(mockAddTransactionBloc.close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    required TransactionType type,
    Locale locale = const Locale('en'),
  }) async {
    return await pumpForPageTest(
      tester,
      routes: {
        '/': AddTransactionPage(
          type: type,
          walletsBloc: mockWalletsBloc,
          incomeCategoriesBloc: mockIncomeCategoriesBloc,
          expenseCategoriesBloc: mockExpenseCategoriesBloc,
          addTransactionBloc: mockAddTransactionBloc,
        ),
      },
      locale: locale,
    );
  }

  group('Render', () {
    testWidgets('provides WalletsBloc', (tester) async {
      await pumpWidget(tester, type: TransactionType.income);

      expect(find.byType(BlocProvider<WalletsBloc>), findsOneWidget);
    });

    testWidgets('provides IncomeCategoriesBloc', (tester) async {
      await pumpWidget(tester, type: TransactionType.income);

      expect(find.byType(BlocProvider<IncomeCategoriesBloc>), findsOneWidget);
    });

    testWidgets('provides ExpenseCategoriesBloc', (tester) async {
      await pumpWidget(tester, type: TransactionType.income);

      expect(find.byType(BlocProvider<ExpenseCategoriesBloc>), findsOneWidget);
    });

    testWidgets('provides AddTransactionBloc', (tester) async {
      await pumpWidget(tester, type: TransactionType.income);

      expect(find.byType(BlocProvider<AddTransactionBloc>), findsOneWidget);
    });

    for (final type in TransactionType.values) {
      testWidgets('has correct AddTransactionView for $type', (tester) async {
        await pumpWidget(tester, type: type);

        final finder = find.byType(AddTransactionView);
        expect(finder, findsOneWidget);

        final widget = tester.widget<AddTransactionView>(finder);
        expect(widget.type, type);
      });
    }

    for (final locale in AppLocalizations.supportedLocales) {
      final translations = expectedTranslations[locale.languageCode]!;

      final title = translations['title']!;
      testWidgets('shows $title title for ${locale.languageCode}', (
        tester,
      ) async {
        await pumpWidget(tester, type: TransactionType.income, locale: locale);

        expect(find.text(title), findsOneWidget);
      });
    }
  });
}
