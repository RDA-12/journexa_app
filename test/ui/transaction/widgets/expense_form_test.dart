import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/ui/expense_categories/bloc/expense_categories_bloc.dart';
import 'package:journexa_app/ui/expense_categories/widgets/expense_category_selector.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/transactions/widgets/expense_form.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_selector.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockWalletsBloc extends Mock implements WalletsBloc;

class MockExpenseCategoriesBloc extends Mock implements ExpenseCategoriesBloc;

final expectedTranslations = {
  'id': {
    'walletLabel': 'Dompet',
    'categoryLabel': 'Kategori',
    'dateLabel': 'Tanggal',
    'amountLabel': 'Jumlah',
    'notesLabel': 'Catatan',
    'submitButton': 'Pengeluaran',
  },
  'en': {
    'walletLabel': 'Wallet',
    'categoryLabel': 'Category',
    'dateLabel': 'Date',
    'amountLabel': 'Amount',
    'notesLabel': 'Notes',
    'submitButton': 'Expense',
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

  final categories = List.generate(5, (index) {
    return ExpenseCategory.test()
        .update(name: 'category $index')
        .copyWith(id: '$index');
  }).toList();
  final blocCategories = categories;

  late WalletsBloc mockWalletsBloc;
  late ExpenseCategoriesBloc mockExpenseCategoriesBloc;

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

    mockExpenseCategoriesBloc = MockExpenseCategoriesBloc();
    whenListen(
      mockExpenseCategoriesBloc,
      Stream<ExpenseCategoriesState>.value(
        ExpenseCategoriesState(
          status: ExpenseCategoriesUIStatus.loaded,
          categories: blocCategories,
        ),
      ),
      initialState: const ExpenseCategoriesState(),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool isProcessing = false,
    OnAddExpensePressed? onAddExpensePressed,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: mockWalletsBloc),
          BlocProvider.value(value: mockExpenseCategoriesBloc),
        ],
        child: ExpenseForm(
          isProcessing: isProcessing,
          onAddExpensePressed: onAddExpensePressed,
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

      final walletLabel = translations['walletLabel']!;
      testWidgets(
        'shows WalletSelector for wallet with label $walletLabel '
        'for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          final labelFinder = find.text('$walletLabel *');
          expect(labelFinder, findsOneWidget);

          final selectorFinder = find.ancestor(
            of: labelFinder,
            matching: find.byType(WalletSelector),
          );
          expect(selectorFinder, findsOneWidget);
        },
      );

      final categoryLabel = translations['categoryLabel']!;
      testWidgets(
        'shows ExpenseCategorySelector for category with label $categoryLabel '
        'for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          final labelFinder = find.text('$categoryLabel *');
          expect(labelFinder, findsOneWidget);

          final selectorFinder = find.ancestor(
            of: labelFinder,
            matching: find.byType(ExpenseCategorySelector),
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
      'submit button disabled when onAddExpensePressed null',
      (tester) async {
        // ignore: avoid_redundant_argument_values for testing purposes
        await pumpWidget(tester, onAddExpensePressed: null);

        final buttonFinder = find.byType(AppButton);
        expect(buttonFinder, findsOneWidget);

        final button = tester.widget<AppButton>(buttonFinder);
        expect(button.onPressed, isNull);
      },
    );
  });

  group('Interactions', () {
    testWidgets(
      'calls onAddExpensePressed when submit button pressed',
      (tester) async {
        final now = DateTime.now();
        final expected = {
          'wallet': wallets[0],
          'category': categories[0],
          'amount': Decimal.parse('100'),
          'date': DateTime(now.year, now.month, now.day),
          'notes': 'test',
        };
        final args = <String, Object?>{};
        await pumpWidget(
          tester,
          onAddExpensePressed:
              ({
                required wallet,
                required category,
                required amount,
                required date,
                notes,
              }) {
                args['wallet'] = wallet;
                args['category'] = category;
                args['amount'] = amount;
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

        final walletSelectorFinder = find.ancestor(
          of: find.text('Wallet *'),
          matching: find.byType(WalletSelector),
        );
        await tester.tap(walletSelectorFinder);
        await tester.pumpAndSettle();
        await tester.tap(find.text(wallets[0].name));
        await tester.pumpAndSettle();

        final categorySelectorFinder = find.ancestor(
          of: find.text('Category *'),
          matching: find.byType(ExpenseCategorySelector),
        );
        await tester.tap(categorySelectorFinder);
        await tester.pumpAndSettle();
        await tester.tap(find.text(categories[0].name));
        await tester.pumpAndSettle();

        final amountFormFinder = find.ancestor(
          of: find.text('Amount *'),
          matching: find.byType(AppDecimalFormField),
        );
        await tester.enterText(amountFormFinder, '100');

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
