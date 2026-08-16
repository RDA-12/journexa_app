import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/journal.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/cash_accounts_list/bloc/cash_accounts_bloc.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/cash_accounts_list_view.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/widgets.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
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
  },
  'en': {
    'errorTitle': 'Failed to get cash data',
    'errorDesc': 'Internal exception error',
    'semanticsLoading': 'Loading cash data',
    'searchLabel': 'Search Cash',
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

  late CashAccountsBloc mockCashAccountsBloc;

  setUp(() {
    mockCashAccountsBloc = MockCashAccountsBloc();
    whenListen(
      mockCashAccountsBloc,
      const Stream<CashAccountsState>.empty(),
      initialState: const CashAccountsState.initial(),
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
        value: mockCashAccountsBloc,
        child: const CashAccountsListView(),
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows LoadingIndicator when state is initial',
      (tester) async {
        whenListen(
          mockCashAccountsBloc,
          const Stream<CashAccountsState>.empty(),
          initialState: const CashAccountsState.initial(),
        );

        await pumpWidget(tester);

        expect(find.byType(LoadingIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'shows LoadingIndicator when state is loading',
      (tester) async {
        whenListen(
          mockCashAccountsBloc,
          const Stream<CashAccountsState>.empty(),
          initialState: const CashAccountsState.loading(),
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
          initialState: CashAccountsState.loaded(accountBalances),
        );

        await pumpWidget(tester);

        final finder = find.byType(CashAccountsList);
        expect(finder, findsOneWidget);
        final widget = tester.widget<CashAccountsList>(finder);
        expect(widget.accountBalances, accountBalances);
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
            initialState: CashAccountsState.failure(AppException.test()),
          );

          await pumpWidget(tester, locale: locale);

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.title, expectedTitle);
          expect(widget.description, expectedDesc);
        },
      );
    }

    for (final locale in AppLocalizations.supportedLocales) {
      final expectedSearchLabel =
          expectedTranslations[locale.languageCode]!['searchLabel']!;
      testWidgets(
        'shows input with $expectedSearchLabel label',
        (tester) async {
          whenListen(
            mockCashAccountsBloc,
            const Stream<CashAccountsState>.empty(),
            initialState: CashAccountsState.loaded(accountBalances),
          );

          await pumpWidget(tester, locale: locale);

          final finder = find.byType(AppFormField);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppFormField>(finder);
          expect(widget.label, expectedSearchLabel);
        },
      );
    }
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
            Stream.fromIterable([const CashAccountsState.loading()]),
          );

          await pumpWidget(tester, locale: locale);

          expect(find.bySemanticsLabel(expectedSemantics), findsOneWidget);
        },
      );
    }

    for (final locale in AppLocalizations.supportedLocales) {
      final expectedSearchLabel =
          expectedTranslations[locale.languageCode]!['searchLabel']!;
      testWidgets(
        'has $expectedSearchLabel label semantically',
        (tester) async {
          whenListen(
            mockCashAccountsBloc,
            const Stream<CashAccountsState>.empty(),
            initialState: CashAccountsState.loaded(accountBalances),
          );

          await pumpWidget(tester, locale: locale);

          expect(
            find.bySemanticsLabel(expectedSearchLabel),
            findsOneWidget,
          );
        },
      );
    }
  });
}
