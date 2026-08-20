import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/accounts/bloc/cash_accounts_bloc.dart';
import 'package:journexa_app/ui/accounts/widgets/cash_account_form.dart';
import 'package:journexa_app/ui/accounts/widgets/cash_accounts_list.dart';
import 'package:journexa_app/ui/accounts/widgets/cash_accounts_list_view.dart';
import 'package:journexa_app/ui/accounts/widgets/delete_cash_button.dart';
import 'package:journexa_app/ui/accounts/widgets/update_cash_button.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/app_confirmation_dialog.dart';
import 'package:journexa_app/ui/shared/widgets/app_empty_box.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockCashAccountsBloc extends Mock implements CashAccountsBloc {}

final expectedTranslations = {
  'id': {
    'errorTitle': 'Gagal mendapatkan data kas',
    'errorDesc': 'Terjadi kesalahan internal',
    'semanticsLoading': 'Memuat data kas',
    'searchLabel': 'Cari Kas',
    'emptyTitle': 'Data Tidak Ditemukan',
    'emptyDescription': 'Tidak ada data kas yang ditemukan',
    'semanticsAddButton': 'Tambah Kas Baru',
  },
  'en': {
    'errorTitle': 'Failed to get cash data',
    'errorDesc': 'Internal exception error',
    'semanticsLoading': 'Loading cash data',
    'searchLabel': 'Search Cash',
    'emptyTitle': 'Data Not Found',
    'emptyDescription': 'No cash data was found',
    'semanticsAddButton': 'Add New Cash',
  },
};

void main() {
  final accountBalances = List.generate(5, (idx) {
    return AccountBalance(
      account: Account(
        code: '10.000${idx + 1}',
        name: 'asset $idx',
        type: AccountType.asset,
      ),
      balance: Decimal.zero,
    );
  });
  final accountBalancesWithState = accountBalances
      .map((it) => AccountBalanceWithState(accountBalance: it))
      .toList();

  late CashAccountsBloc mockCashAccountsBloc;

  setUp(() {
    mockCashAccountsBloc = MockCashAccountsBloc();
    whenListen(
      mockCashAccountsBloc,
      const Stream<CashAccountsState>.empty(),
      initialState: const CashAccountsState(),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    VoidCallback? onAddPressed,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: BlocProvider.value(
        value: mockCashAccountsBloc,
        child: CashAccountsListView(
          onAddPressed: onAddPressed,
        ),
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows LoadingIndicator when state is loading',
      (tester) async {
        whenListen(
          mockCashAccountsBloc,
          const Stream<CashAccountsState>.empty(),
          initialState: const CashAccountsState(
            status: CashAccountsStatus.loading,
          ),
        );

        await pumpWidget(tester);

        expect(find.byType(LoadingIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'shows CashAccountList with correct accounts balance '
      'when state is loaded',
      (tester) async {
        whenListen(
          mockCashAccountsBloc,
          const Stream<CashAccountsState>.empty(),
          initialState: CashAccountsState(
            status: CashAccountsStatus.loaded,
            accountBalances: accountBalancesWithState,
          ),
        );

        await pumpWidget(tester);

        final finder = find.byType(CashAccountsList);
        expect(finder, findsOneWidget);
        final widget = tester.widget<CashAccountsList>(finder);
        expect(widget.data, accountBalancesWithState);
      },
    );

    for (final locale in AppLocalizations.supportedLocales) {
      final expectedTranslation = expectedTranslations[locale.languageCode]!;
      testWidgets(
        'shows AppExceptionBox when state is failure',
        (tester) async {
          final expectedTitle = expectedTranslation['errorTitle']!;
          final expectedDesc = expectedTranslation['errorDesc']!;

          whenListen(
            mockCashAccountsBloc,
            const Stream<CashAccountsState>.empty(),
            initialState: CashAccountsState(
              status: CashAccountsStatus.failure,
              exception: AppException.test(),
            ),
          );

          await pumpWidget(tester, locale: locale);

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.title, expectedTitle);
          expect(widget.description, expectedDesc);
        },
      );

      final expectedSearchLabel = expectedTranslation['searchLabel']!;
      testWidgets(
        'shows input with $expectedSearchLabel label',
        (tester) async {
          whenListen(
            mockCashAccountsBloc,
            const Stream<CashAccountsState>.empty(),
            initialState: CashAccountsState(
              status: CashAccountsStatus.loaded,
              accountBalances: accountBalancesWithState,
            ),
          );

          await pumpWidget(tester, locale: locale);

          final finder = find.byType(AppFormField);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppFormField>(finder);
          expect(widget.label, expectedSearchLabel);
        },
      );

      final expectedEmptyTitle = expectedTranslation['emptyTitle']!;
      testWidgets(
        'shows AppEmptyBox with $expectedEmptyTitle title',
        (tester) async {
          whenListen(
            mockCashAccountsBloc,
            const Stream<CashAccountsState>.empty(),
            initialState: const CashAccountsState(
              status: CashAccountsStatus.loaded,
            ),
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
        'shows AppEmptyBox with $expectedEmptyDesc description',
        (tester) async {
          whenListen(
            mockCashAccountsBloc,
            const Stream<CashAccountsState>.empty(),
            initialState: const CashAccountsState(
              status: CashAccountsStatus.loaded,
            ),
          );

          await pumpWidget(tester, locale: locale);

          final finder = find.byType(AppEmptyBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppEmptyBox>(finder);
          expect(widget.description, expectedEmptyDesc);
        },
      );
    }

    testWidgets(
      'shows 1 AppIconButton with correct icon',
      (tester) async {
        await pumpWidget(tester);

        final finder = find.byType(AppIconButton);
        expect(finder, findsOneWidget);
        final widget = tester.widget<AppIconButton>(finder);
        expect(
          widget.icon,
          isA<Icon>().having((e) => e.icon, 'icon', Icons.add_rounded),
        );
      },
    );
  });

  group('Interaction', () {
    testWidgets(
      'add CashAccountEvent.search with correct query',
      (tester) async {
        await pumpWidget(tester);

        final finder = find.byType(TextFormField);
        await tester.enterText(finder, 'query');
        expect(find.text('query'), findsOneWidget);

        verify(
          () => mockCashAccountsBloc.add(
            const CashAccountsEvent.search(query: 'query'),
          ),
        ).called(1);
      },
    );

    for (final locale in AppLocalizations.supportedLocales) {
      final expectedTooltip =
          expectedTranslations[locale.languageCode]!['semanticsAddButton']!;
      testWidgets(
        'shows $expectedTooltip tooltip on long press to AppIconButton',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          final finder = find.byType(AppIconButton);
          await tester.longPress(finder);
          await tester.pump();

          expect(find.text(expectedTooltip), findsOneWidget);
        },
      );
    }

    testWidgets(
      'calls onAddPressed when AppIconButton pressed',
      (tester) async {
        var isPressed = false;
        await pumpWidget(
          tester,
          onAddPressed: () {
            isPressed = true;
          },
        );

        final finder = find.byType(AppIconButton);
        await tester.tap(finder);

        expect(isPressed, isTrue);
      },
    );

    testWidgets(
      'add CashAccountsEvent.delete when DeleteCashButton pressed',
      (tester) async {
        whenListen(
          mockCashAccountsBloc,
          const Stream<CashAccountsState>.empty(),
          initialState: CashAccountsState(
            status: CashAccountsStatus.loaded,
            accountBalances: accountBalancesWithState,
          ),
        );
        await pumpWidget(tester);

        final expectedAccount = accountBalances.first.account;

        final deleteButtonFinder = find.byType(DeleteCashButton).first;
        await tester.tap(deleteButtonFinder);
        await tester.pump();

        final confirmButtonFinder = find.descendant(
          of: find.byType(AppConfirmationDialog),
          matching: find.text('Delete'),
        );
        expect(confirmButtonFinder, findsOneWidget);
        await tester.tap(confirmButtonFinder);
        await tester.pump();

        verify(
          () => mockCashAccountsBloc.add(
            CashAccountsEvent.delete(expectedAccount),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'add CashAccountsEvent.update when UpdateCashButton pressed',
      (tester) async {
        const expectedName = 'test';
        whenListen(
          mockCashAccountsBloc,
          const Stream<CashAccountsState>.empty(),
          initialState: CashAccountsState(
            status: CashAccountsStatus.loaded,
            accountBalances: accountBalancesWithState,
          ),
        );
        await pumpWidget(tester);

        final expectedAccount = accountBalances.first.account;

        final updateButtonFinder = find.byType(UpdateCashButton).first;
        await tester.tap(updateButtonFinder);
        await tester.pumpAndSettle();

        final formFinder = find.byType(CashAccountForm);
        expect(formFinder, findsOneWidget);
        await tester.enterText(
          find.descendant(of: formFinder, matching: find.byType(TextFormField)),
          expectedName,
        );
        final saveButtonFinder = find.descendant(
          of: formFinder,
          matching: find.byType(AppButton),
        );
        expect(saveButtonFinder, findsOneWidget);
        await tester.tap(saveButtonFinder);
        await tester.pumpAndSettle();

        verify(
          () => mockCashAccountsBloc.add(
            CashAccountsEvent.update(
              expectedAccount,
              name: expectedName,
            ),
          ),
        ).called(1);
      },
    );
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedTranslation = expectedTranslations[locale.languageCode]!;
      final expectedSemantics = expectedTranslation['semanticsLoading']!;
      testWidgets(
        'has $expectedSemantics '
        'when state is loading for ${locale.languageCode}',
        (tester) async {
          whenListen(
            mockCashAccountsBloc,
            const Stream<CashAccountsState>.empty(),
            initialState: const CashAccountsState(
              status: CashAccountsStatus.loading,
            ),
          );

          await pumpWidget(tester, locale: locale);

          expect(find.bySemanticsLabel(expectedSemantics), findsOneWidget);
        },
      );

      final expectedSearchLabel = expectedTranslation['searchLabel']!;
      testWidgets(
        'has $expectedSearchLabel label semantically',
        (tester) async {
          whenListen(
            mockCashAccountsBloc,
            const Stream<CashAccountsState>.empty(),
            initialState: CashAccountsState(
              status: CashAccountsStatus.loaded,
              accountBalances: accountBalancesWithState,
            ),
          );

          await pumpWidget(tester, locale: locale);

          expect(
            find.bySemanticsLabel(expectedSearchLabel),
            findsOneWidget,
          );
        },
      );

      final expectedTooltip = expectedTranslation['semanticsAddButton']!;
      testWidgets(
        'has $expectedTooltip tooltip',
        (tester) async {
          whenListen(
            mockCashAccountsBloc,
            const Stream<CashAccountsState>.empty(),
            initialState: CashAccountsState(
              status: CashAccountsStatus.loaded,
              accountBalances: accountBalancesWithState,
            ),
          );

          await pumpWidget(tester, locale: locale);

          expect(find.byTooltip(expectedTooltip), findsOneWidget);
        },
      );
    }

    // TODO(RDA): expect to shows toast semantically on delete succeeded/failed
  });

  group('Side Effects', () {
    // TODO(RDA): expect to shows toast on delete succeeded/failed
  });
}
