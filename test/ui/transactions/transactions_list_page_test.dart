import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/transactions/bloc/transactions_bloc.dart';
import 'package:journexa_app/ui/transactions/transactions_list_page.dart';
import 'package:journexa_app/ui/transactions/widgets/transactions_list_view.dart';
import 'package:mocktail/mocktail.dart';

import '../util.dart';

class MockTransactionsBloc extends Mock implements TransactionsBloc;

final expectedTranslations = {
  'id': {'title': 'Daftar Transaksi'},
  'en': {'title': 'Transactions List'},
};

void main() {
  late TransactionsBloc mockTransactionsBloc;

  setUp(() {
    mockTransactionsBloc = MockTransactionsBloc();
    whenListen(
      mockTransactionsBloc,
      const Stream<TransactionsState>.empty(),
      initialState: const TransactionsState.initial(),
    );
    when(mockTransactionsBloc.close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    List<RouteBase> nextRoutes = const [],
  }) {
    return pumpForPageTest(
      tester,
      initialLocation: '/transactions',
      routes: [
        GoRoute(
          path: '/transactions',
          builder: (context, state) => TransactionsListPage(
            transactionsBloc: mockTransactionsBloc,
          ),
        ),
        ...nextRoutes,
      ],
      locale: locale,
    );
  }

  group('Init', () {
    testWidgets('add TransactionsEvent.subscriptionRequested event on start', (
      tester,
    ) async {
      await pumpWidget(tester);

      verify(
        () => mockTransactionsBloc.add(
          const TransactionsEvent.subscriptionRequested(),
        ),
      ).called(1);
    });
  });

  group('Render', () {
    testWidgets('provides TransactionsBloc', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(BlocProvider<TransactionsBloc>), findsOneWidget);
    });

    for (final locale in AppLocalizations.supportedLocales) {
      final expectedTitle =
          expectedTranslations[locale.languageCode]!['title']!;
      testWidgets('shows $expectedTitle title for ${locale.languageCode}', (
        tester,
      ) async {
        await pumpWidget(tester, locale: locale);

        expect(find.text(expectedTitle), findsOneWidget);
      });
    }

    testWidgets('has TransactionsListView', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(TransactionsListView), findsOneWidget);
    });
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
