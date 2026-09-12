import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/home/bloc/home_bloc.dart';
import 'package:journexa_app/ui/home/widgets/wallet_home_card.dart';
import 'package:journexa_app/ui/home/widgets/wallets_home_carousel.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockHomeBloc extends Mock implements HomeBloc {}

final expectedTranslations = {
  'id': {
    'errorTitle': 'Gagal mendapatkan data dompet',
    'errorDesc': 'Terjadi kesalahan internal',
    'semanticsLoading': 'Memuat data dompet',
    'emptyDescription': 'Tidak ada data dompet yang ditemukan',
    'totalBalanceLabel': 'Total Saldo',
    'totalBalanceFormatted': 'Rp 60.000',
  },
  'en': {
    'errorTitle': 'Failed to get wallets data',
    'errorDesc': 'Internal exception error',
    'semanticsLoading': 'Loading wallets data',
    'emptyDescription': 'No wallets data was found',
    'totalBalanceLabel': 'Total Balance',
    'totalBalanceFormatted': 'Rp 60,000',
  },
};

void main() {
  final assetParent = SystemDefinedAccount.walletParent;
  final walletsData = List.generate(3, (idx) {
    return HomeWalletUIModel(
      wallet: Wallet(
        id: '$idx',
        name: 'asset $idx',
        account: Account.sub(
          name: 'asset $idx',
          parent: assetParent,
          currentChildrenCount: idx,
        ),
      ),
      balance: Decimal.fromInt((idx + 1) * 10000),
    );
  });

  final expectedTotalBalance = Decimal.fromInt(60000);

  late HomeBloc mockHomeBloc;

  setUp(() {
    mockHomeBloc = MockHomeBloc();
    whenListen(
      mockHomeBloc,
      const Stream<HomeState>.empty(),
      initialState: HomeState(),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: BlocProvider<HomeBloc>.value(
        value: mockHomeBloc,
        child: const WalletsHomeCarousel(),
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows LoadingIndicator when state is loading',
      (tester) async {
        whenListen(
          mockHomeBloc,
          const Stream<HomeState>.empty(),
          initialState: HomeState(
            wallets: const HomeWalletsUIModel(
              status: HomeUIStatus.loading,
            ),
          ),
        );

        await pumpWidget(tester);

        expect(find.byType(LoadingIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'shows CarouselView with total balance at index 0 and wallets thereafter',
      (tester) async {
        whenListen(
          mockHomeBloc,
          const Stream<HomeState>.empty(),
          initialState: HomeState(
            wallets: HomeWalletsUIModel(
              status: HomeUIStatus.loaded,
              wallets: walletsData,
            ),
          ),
        );

        await pumpWidget(tester);

        final carouselFinder = find.byType(CarouselView);
        expect(carouselFinder, findsOneWidget);

        final carouselWidgets = tester.widget<CarouselView>(carouselFinder);
        expect(carouselWidgets.itemCount, walletsData.length + 1);

        final cardFinder = find.byType(WalletHomeCard);
        expect(cardFinder, findsAtLeastNWidgets(1));
        final cardWidget = tester.widget<WalletHomeCard>(cardFinder.first);
        expect(cardWidget.name, 'Total Balance');
        expect(cardWidget.balance, expectedTotalBalance);
      },
    );

    for (final locale in AppLocalizations.supportedLocales) {
      final expectedTranslation = expectedTranslations[locale.languageCode]!;

      testWidgets(
        'shows total balance card '
        'with correct localized label and formatted balance '
        'for ${locale.languageCode}',
        (tester) async {
          whenListen(
            mockHomeBloc,
            const Stream<HomeState>.empty(),
            initialState: HomeState(
              wallets: HomeWalletsUIModel(
                status: HomeUIStatus.loaded,
                wallets: walletsData,
              ),
            ),
          );

          await pumpWidget(tester, locale: locale);

          expect(
            find.text(expectedTranslation['totalBalanceLabel']!),
            findsOneWidget,
          );
          expect(
            find.text(expectedTranslation['totalBalanceFormatted']!),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows AppExceptionBox when state is failure '
        'for ${locale.languageCode}',
        (tester) async {
          final expectedTitle = expectedTranslation['errorTitle']!;
          final expectedDesc = expectedTranslation['errorDesc']!;

          whenListen(
            mockHomeBloc,
            const Stream<HomeState>.empty(),
            initialState: HomeState(
              wallets: HomeWalletsUIModel(
                status: HomeUIStatus.failure,
                exception: AppException.test(),
              ),
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

      final expectedEmptyDesc = expectedTranslation['emptyDescription']!;
      testWidgets(
        'shows AppEmptyBox with $expectedEmptyDesc description '
        'for ${locale.languageCode}',
        (tester) async {
          whenListen(
            mockHomeBloc,
            const Stream<HomeState>.empty(),
            initialState: HomeState(
              wallets: const HomeWalletsUIModel(
                status: HomeUIStatus.loaded,
              ),
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
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedTranslation = expectedTranslations[locale.toLanguageTag()]!;
      final expectedSemantics = expectedTranslation['semanticsLoading']!;
      testWidgets(
        'has $expectedSemantics '
        'when state is loading for ${locale.languageCode}',
        (tester) async {
          whenListen(
            mockHomeBloc,
            const Stream<HomeState>.empty(),
            initialState: HomeState(
              wallets: const HomeWalletsUIModel(
                status: HomeUIStatus.loading,
              ),
            ),
          );

          await pumpWidget(tester, locale: locale);

          expect(find.bySemanticsLabel(expectedSemantics), findsOneWidget);
        },
      );
    }
  });
}
