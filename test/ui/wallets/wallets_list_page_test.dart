import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_icon_button.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:journexa_app/ui/wallets/wallets_list_page.dart';
import 'package:journexa_app/ui/wallets/widgets/wallets_list_view.dart';
import 'package:mocktail/mocktail.dart';

import '../util.dart';

class MockWalletsBloc extends Mock implements WalletsBloc;

final expectedTranslations = {
  'id': {'title': 'Daftar Dompet'},
  'en': {'title': 'Wallet List'},
};

void main() {
  late WalletsBloc mockWalletsBloc;

  setUp(() {
    mockWalletsBloc = MockWalletsBloc();
    whenListen(
      mockWalletsBloc,
      const Stream<WalletsState>.empty(),
      initialState: const WalletsState(),
    );
    when(mockWalletsBloc.close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    List<RouteBase> nextRoutes = const [],
  }) {
    return pumpForPageTest(
      tester,
      initialLocation: '/wallet-accounts',
      routes: [
        GoRoute(
          path: '/wallet-accounts',
          builder: (context, state) => WalletsListPage(
            walletsBloc: mockWalletsBloc,
          ),
        ),
        ...nextRoutes,
      ],
      locale: locale,
    );
  }

  group('Init', () {
    testWidgets('add WalletsEvent.subscriptionRequested event on start', (
      tester,
    ) async {
      await pumpWidget(tester);

      verify(
        () => mockWalletsBloc.add(const WalletsEvent.subscriptionRequested()),
      ).called(1);
    });
  });

  group('Render', () {
    testWidgets('provides WalletsBloc', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(BlocProvider<WalletsBloc>), findsOneWidget);
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

    testWidgets('has WalletsListView', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(WalletsListView), findsOneWidget);
    });
  });

  group('Interactions', () {
    testWidgets('navigates to /wallet-accounts when add button pressed', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        nextRoutes: [
          GoRoute(
            path: '/add-wallet-account',
            builder: (context, state) => const Placeholder(),
          ),
        ],
      );

      final finder = find.byType(AppIconButton);
      await tester.tap(finder);
      await tester.pumpAndSettle();

      expect(find.byType(Placeholder), findsOneWidget);
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

  group('Side Effects', () {
    testWidgets('add WalletsBlocEvent.subscriptionRequested '
        'after going back from add wallet page', (tester) async {
      await pumpWidget(
        tester,
        nextRoutes: [
          GoRoute(
            path: '/add-wallet-account',
            builder: (context, state) => Scaffold(
              key: const ValueKey('add-wallet-page'),
              appBar: AppBar(),
            ),
          ),
        ],
      );

      final finder = find.byType(AppIconButton);
      await tester.tap(finder);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('add-wallet-page')), findsOneWidget);

      await tester.tap(find.backButton());
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('add-wallet-page')), findsNothing);

      verify(
        () => mockWalletsBloc.add(const WalletsEvent.subscriptionRequested()),
      ).called(2);
    });
  });
}
