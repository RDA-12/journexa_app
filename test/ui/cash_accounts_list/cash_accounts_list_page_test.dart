import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/cash_accounts_list/bloc/cash_accounts_bloc.dart';
import 'package:journexa_app/ui/cash_accounts_list/cash_accounts_list_page.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/cash_accounts_list_view.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:mocktail/mocktail.dart';

import '../util.dart';

class MockCashAccountsBloc extends Mock implements CashAccountsBloc {}

final expectedTranslations = {
  'id': {
    'title': 'Daftar Kas',
  },
  'en': {
    'title': 'Cash List',
  },
};

void main() {
  late CashAccountsBloc mockCashAccountsBloc;

  setUp(() {
    mockCashAccountsBloc = MockCashAccountsBloc();
    whenListen(
      mockCashAccountsBloc,
      const Stream<CashAccountsState>.empty(),
      initialState: const CashAccountsState.initial(),
    );
    when(mockCashAccountsBloc.close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) {
    return pumpForPageTest(
      tester,
      initialLocation: '/cash-accounts',
      routes: {
        '/cash-accounts': CashAccountsListPage(
          cashAccountsBloc: mockCashAccountsBloc,
        ),
      },
      locale: locale,
    );
  }

  group('Init', () {
    testWidgets(
      'add CashAccountsEvent.load event on start',
      (tester) async {
        await pumpWidget(tester);

        verify(
          () => mockCashAccountsBloc.add(const CashAccountsEvent.load()),
        ).called(1);
      },
    );
  });

  group('Render', () {
    testWidgets(
      'provides CashAccountsBloc',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<CashAccountsBloc>), findsOneWidget);
      },
    );

    for (final locale in AppLocalizations.supportedLocales) {
      final expectedTitle =
          expectedTranslations[locale.languageCode]!['title']!;
      testWidgets(
        'shows $expectedTitle title for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.text(expectedTitle), findsOneWidget);
        },
      );
    }

    testWidgets(
      'has CashAccountsListView',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byType(CashAccountsListView), findsOneWidget);
      },
    );
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedTitle =
          expectedTranslations[locale.languageCode]!['title']!;
      testWidgets(
        'has $expectedTitle title semantically for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.bySemanticsLabel(expectedTitle), findsOneWidget);
        },
      );
    }
  });
}
