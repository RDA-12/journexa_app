import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/home/widgets/wallet_home_card.dart';
import 'package:journexa_app/ui/home/widgets/wallets_home_carousel.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockWalletsBloc extends Mock implements WalletsBloc {}

final expectedTranslations = {
  'id': {
    'errorTitle': 'Gagal mendapatkan data dompet',
    'errorDesc': 'Terjadi kesalahan internal',
    'semanticsLoading': 'Memuat data dompet',
    'emptyDescription': 'Tidak ada data dompet yang ditemukan',
  },
  'en': {
    'errorTitle': 'Failed to get wallets data',
    'errorDesc': 'Internal exception error',
    'semanticsLoading': 'Loading wallets data',
    'emptyDescription': 'No wallets data was found',
  },
};

void main() {
  final assetParent = SystemDefinedAccount.rootAsset;
  final walletsData = List.generate(5, (idx) {
    return WalletUIModel(
      wallet: Wallet(
        id: '$idx',
        name: 'asset $idx',
        account: Account(
          code: '10.000${idx + 1}',
          name: 'asset $idx',
          type: AccountType.asset,
          parent: assetParent,
        ),
      ),
      balance: Decimal.zero,
    );
  });

  late WalletsBloc mockWalletsBloc;

  setUp(() {
    mockWalletsBloc = MockWalletsBloc();
    whenListen(
      mockWalletsBloc,
      const Stream<WalletsState>.empty(),
      initialState: const WalletsState(),
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
        value: mockWalletsBloc,
        child: const WalletsHomeCarousel(),
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows LoadingIndicator when state is loading',
      (tester) async {
        whenListen(
          mockWalletsBloc,
          const Stream<WalletsState>.empty(),
          initialState: const WalletsState(
            status: WalletsUIStatus.loading,
          ),
        );

        await pumpWidget(tester);

        expect(find.byType(LoadingIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'shows CarouselView with WalletHomeCard when state is loaded',
      (tester) async {
        whenListen(
          mockWalletsBloc,
          const Stream<WalletsState>.empty(),
          initialState: WalletsState(
            status: WalletsUIStatus.loaded,
            wallets: walletsData,
          ),
        );

        await pumpWidget(tester);

        expect(find.byType(CarouselView), findsOneWidget);
        expect(find.byType(WalletHomeCard), findsWidgets);
      },
    );

    for (final locale in AppLocalizations.supportedLocales) {
      final expectedTranslation = expectedTranslations[locale.languageCode]!;
      testWidgets(
        'shows AppExceptionBox when state is failure for ${locale.languageCode}',
        (tester) async {
          final expectedTitle = expectedTranslation['errorTitle']!;
          final expectedDesc = expectedTranslation['errorDesc']!;

          whenListen(
            mockWalletsBloc,
            const Stream<WalletsState>.empty(),
            initialState: WalletsState(
              status: WalletsUIStatus.failure,
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

      final expectedEmptyDesc = expectedTranslation['emptyDescription']!;
      testWidgets(
        'shows AppEmptyBox with $expectedEmptyDesc description '
        'for ${locale.languageCode}',
        (tester) async {
          whenListen(
            mockWalletsBloc,
            const Stream<WalletsState>.empty(),
            initialState: const WalletsState(
              status: WalletsUIStatus.loaded,
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
            mockWalletsBloc,
            const Stream<WalletsState>.empty(),
            initialState: const WalletsState(
              status: WalletsUIStatus.loading,
            ),
          );

          await pumpWidget(tester, locale: locale);

          expect(find.bySemanticsLabel(expectedSemantics), findsOneWidget);
        },
      );
    }
  });
}
