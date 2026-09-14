import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/ui/home/bloc/home_bloc.dart';
import 'package:journexa_app/ui/home/home_page.dart';
import 'package:journexa_app/ui/home/widgets/mtd_section.dart';
import 'package:journexa_app/ui/home/widgets/wallets_home_carousel.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../util.dart';

class MockHomeBloc extends Mock implements HomeBloc {}

final expectedTranslations = {
  'en': {
    'mtdTitle': 'This month balance',
  },
  'id': {
    'mtdTitle': 'Saldo bulan ini',
  },
};

void main() {
  late HomeBloc mockHomeBloc;

  setUp(() {
    mockHomeBloc = MockHomeBloc();
    whenListen(
      mockHomeBloc,
      const Stream<HomeState>.empty(),
      initialState: HomeState(),
    );
    when(mockHomeBloc.close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Map<String, Widget> nextRoutes = const {},
  }) {
    return pumpForPageTest(
      tester,
      initialLocation: '/home',
      routes: {
        '/home': HomePage(
          homeBloc: mockHomeBloc,
        ),
        ...nextRoutes,
      },
      locale: locale,
    );
  }

  group('Init', () {
    testWidgets(
      'add HomeEvent.subscriptionsRequested event on start',
      (tester) async {
        await pumpWidget(tester);

        verify(
          () => mockHomeBloc.add(
            const HomeEvent.walletsSubscriptionRequested(),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'add HomeEvent.mtdSubscriptionRequested event on start '
      'with current date',
      (tester) async {
        final now = DateTime.now();
        await withClock(Clock.fixed(now), () async {
          await pumpWidget(tester);

          verify(
            () => mockHomeBloc.add(
              HomeEvent.mtdSubscriptionRequested(targetDate: now),
            ),
          ).called(1);
        });
      },
    );
  });

  group('Render', () {
    testWidgets(
      'provides HomeBloc',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<HomeBloc>), findsOneWidget);
      },
    );

    testWidgets(
      'has WalletsHomeCarousel',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byType(WalletsHomeCarousel), findsOneWidget);
      },
    );

    testWidgets(
      'has MTDSection',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byType(MTDSection), findsOneWidget);
      },
    );

    for (final locale in AppLocalizations.supportedLocales) {
      final translations = expectedTranslations[locale.languageCode]!;

      final mtdTitle = translations['mtdTitle']!;
      testWidgets(
        'shows $mtdTitle for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.text(mtdTitle), findsOneWidget);
        },
      );
    }
  });

  group('Interactions', () {
    testWidgets(
      'add HomeBloc.mtdSubscriptionRequested '
      'when wallet changed on WalletsHomeCarouse',
      (tester) async {
        final now = DateTime.now();
        final wallet = Wallet.test();
        whenListen(
          mockHomeBloc,
          const Stream<HomeState>.empty(),
          initialState: HomeState(
            wallets: HomeWalletsUIModel(
              status: HomeUIStatus.loaded,
              wallets: [
                HomeWalletUIModel(
                  wallet: wallet,
                  balance: Decimal.zero,
                ),
                HomeWalletUIModel(
                  wallet: wallet.copyWith(id: '1'),
                  balance: Decimal.zero,
                ),
                HomeWalletUIModel(
                  wallet: wallet.copyWith(id: '2'),
                  balance: Decimal.zero,
                ),
              ],
            ),
            mtdData: HomeMTDDataUIModel(
              totalIncome: Decimal.zero,
              totalExpense: Decimal.zero,
              status: HomeUIStatus.loaded,
            ),
          ),
        );

        await withClock(Clock.fixed(now), () async {
          await pumpWidget(tester);

          final carouselFinder = find.byType(WalletsHomeCarousel);
          expect(carouselFinder, findsOneWidget);
          await tester.fling(carouselFinder, const Offset(-300, 0), 1000);
          await tester.pumpAndSettle();

          verify(
            () => mockHomeBloc.add(
              HomeEvent.mtdSubscriptionRequested(
                targetDate: now,
                wallet: wallet,
              ),
            ),
          ).called(1);
        });
      },
    );
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final translations = expectedTranslations[locale.languageCode]!;

      final mtdTitle = translations['mtdTitle']!;
      testWidgets(
        'has correct title for MTDSection for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.bySemanticsLabel(mtdTitle), findsOneWidget);
        },
      );
    }
  });
}
