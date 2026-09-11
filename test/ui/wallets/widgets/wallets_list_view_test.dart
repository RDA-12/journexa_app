import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:journexa_app/ui/wallets/widgets/delete_wallet_button.dart';
import 'package:journexa_app/ui/wallets/widgets/update_wallet_button.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_form.dart';
import 'package:journexa_app/ui/wallets/widgets/wallets_list_view.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockWalletsBloc extends Mock implements WalletsBloc {}

final expectedTranslations = {
  'id': {
    'errorTitle': 'Gagal mendapatkan data dompet',
    'errorDesc': 'Terjadi kesalahan internal',
    'semanticsLoading': 'Memuat data dompet',
    'searchLabel': 'Cari Dompet',
    'emptyTitle': 'Data Tidak Ditemukan',
    'emptyDescription': 'Tidak ada data dompet yang ditemukan',
    'semanticsAddButton': 'Tambah Dompet Baru',
    'deleteSuccessToastMessage': 'asset 0 telah dihapus',
    'deleteFailureToastTitle': 'Gagal menghapus data dompet',
    'deleteFailureToastMessage': 'Terjadi kesalahan internal',
  },
  'en': {
    'errorTitle': 'Failed to get wallet data',
    'errorDesc': 'Internal exception error',
    'semanticsLoading': 'Loading wallet data',
    'searchLabel': 'Search Wallet',
    'emptyTitle': 'Data Not Found',
    'emptyDescription': 'No wallet data was found',
    'semanticsAddButton': 'Add New Wallet',
    'deleteSuccessToastMessage': 'asset 0 has been deleted',
    'deleteFailureToastTitle': 'Failed to delete wallet data',
    'deleteFailureToastMessage': 'Internal exception error',
  },
};

void main() {
  final assetParent = SystemDefinedAccount.walletParent;
  final walletsData = List.generate(5, (idx) {
    return WalletUIModel(
      wallet: Wallet(
        id: '$idx',
        name: 'asset $idx',
        account: Account.sub(
          name: 'asset $idx',
          parent: assetParent,
          currentChildrenCount: idx,
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
    VoidCallback? onAddPressed,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: BlocProvider.value(
        value: mockWalletsBloc,
        child: WalletsListView(
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
      'shows AppListView with correct wallets '
      'when state is loaded',
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

        final finder = find.byType(AppListView<WalletUIModel>);
        expect(finder, findsOneWidget);
        final widget = tester.widget<AppListView<WalletUIModel>>(
          finder,
        );
        expect(widget.items, walletsData);
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

      final expectedSearchLabel = expectedTranslation['searchLabel']!;
      testWidgets(
        'shows input with $expectedSearchLabel label',
        (tester) async {
          whenListen(
            mockWalletsBloc,
            const Stream<WalletsState>.empty(),
            initialState: WalletsState(
              status: WalletsUIStatus.loaded,
              wallets: walletsData,
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
          expect(widget.title, expectedEmptyTitle);
        },
      );

      final expectedEmptyDesc = expectedTranslation['emptyDescription']!;
      testWidgets(
        'shows AppEmptyBox with $expectedEmptyDesc description',
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
      'add WalletEvent.subscriptionRequested with correct query',
      (tester) async {
        await pumpWidget(tester);

        final finder = find.byType(TextFormField);
        await tester.enterText(finder, 'query');
        expect(find.text('query'), findsOneWidget);

        verify(
          () => mockWalletsBloc.add(
            const WalletsEvent.subscriptionRequested(query: 'query'),
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
      'add WalletsEvent.delete when DeleteWalletButton pressed',
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
        await tester.pumpAndSettle();

        final expectedWallet = walletsData.first.wallet;

        final deleteButtonFinder = find.byType(DeleteWalletButton).first;
        await tester.tap(deleteButtonFinder);
        await tester.pump();

        final confirmButtonFinder = find.descendant(
          of: find.byType(AppDialog),
          matching: find.text('Delete'),
        );
        expect(confirmButtonFinder, findsOneWidget);
        await tester.tap(confirmButtonFinder);
        await tester.pump();

        verify(
          () => mockWalletsBloc.add(
            WalletsEvent.delete(expectedWallet),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'add WalletsEvent.update when UpdateWalletButton pressed',
      (tester) async {
        const expectedName = 'test';
        whenListen(
          mockWalletsBloc,
          const Stream<WalletsState>.empty(),
          initialState: WalletsState(
            status: WalletsUIStatus.loaded,
            wallets: walletsData,
          ),
        );
        await pumpWidget(tester);
        await tester.pumpAndSettle();

        final expectedWallet = walletsData.first.wallet;

        final updateButtonFinder = find.byType(UpdateWalletButton).first;
        await tester.tap(updateButtonFinder);
        await tester.pumpAndSettle();

        final formFinder = find.byType(WalletForm);
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
          () => mockWalletsBloc.add(
            WalletsEvent.update(
              expectedWallet,
              name: expectedName,
            ),
          ),
        ).called(1);
      },
    );
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

      final expectedSearchLabel = expectedTranslation['searchLabel']!;
      testWidgets(
        'has $expectedSearchLabel label semantically',
        (tester) async {
          whenListen(
            mockWalletsBloc,
            const Stream<WalletsState>.empty(),
            initialState: WalletsState(
              status: WalletsUIStatus.loaded,
              wallets: walletsData,
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
            mockWalletsBloc,
            const Stream<WalletsState>.empty(),
            initialState: WalletsState(
              status: WalletsUIStatus.loaded,
              wallets: walletsData,
            ),
          );

          await pumpWidget(tester, locale: locale);

          expect(find.byTooltip(expectedTooltip), findsOneWidget);
        },
      );

      final expectedDeleteSuccessToastMessage =
          expectedTranslation['deleteSuccessToastMessage']!;
      testWidgets(
        'has correct semantics on toast when delete is succeeded '
        'for locale $locale',
        (tester) async {
          whenListen(
            mockWalletsBloc,
            Stream<WalletsState>.fromIterable([
              WalletsState(
                status: WalletsUIStatus.loaded,
                wallets: walletsData,
                notice: WalletUINotice.recentlyDeleted(
                  wallet: walletsData.first.wallet,
                ),
              ),
            ]),
            initialState: WalletsState(
              status: WalletsUIStatus.loaded,
              wallets: walletsData,
            ),
          );

          await pumpWidget(tester, locale: locale);
          await tester.pumpAndSettle();

          expect(
            find.bySemanticsLabel(expectedDeleteSuccessToastMessage),
            findsOneWidget,
          );

          await tester.pumpAndSettle(kToastDuration);
        },
      );

      final expectedDeleteFailureToastTitle =
          expectedTranslation['deleteFailureToastTitle']!;
      final expectedDeleteFailureToastMessage =
          expectedTranslation['deleteFailureToastMessage']!;
      testWidgets(
        'has correct semantics on toast when delete is failed '
        'for locale $locale',
        (tester) async {
          whenListen(
            mockWalletsBloc,
            Stream<WalletsState>.fromIterable([
              WalletsState(
                status: WalletsUIStatus.loaded,
                wallets: walletsData,
                notice: WalletUINotice.deleteFailed(
                  wallet: walletsData.first.wallet,
                  exception: AppException.test(),
                ),
              ),
            ]),
            initialState: WalletsState(
              status: WalletsUIStatus.loaded,
              wallets: walletsData,
            ),
          );

          await pumpWidget(tester, locale: locale);
          await tester.pumpAndSettle();

          expect(
            find.bySemanticsLabel(
              '$expectedDeleteFailureToastTitle'
              '\n$expectedDeleteFailureToastMessage',
            ),
            findsOneWidget,
          );

          await tester.pumpAndSettle(kToastDuration);
        },
      );
    }
  });

  group('Side Effects', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedTranslation = expectedTranslations[locale.toLanguageTag()]!;
      final expectedDeleteSuccessToastMessage =
          expectedTranslation['deleteSuccessToastMessage']!;
      testWidgets(
        'shows correct toast when delete is succeeded '
        'for locale $locale',
        (tester) async {
          whenListen(
            mockWalletsBloc,
            Stream<WalletsState>.fromIterable([
              WalletsState(
                status: WalletsUIStatus.loaded,
                wallets: walletsData,
                notice: WalletUINotice.recentlyDeleted(
                  wallet: walletsData.first.wallet,
                ),
              ),
            ]),
            initialState: WalletsState(
              status: WalletsUIStatus.loaded,
              wallets: walletsData,
            ),
          );

          await pumpWidget(tester, locale: locale);
          await tester.pumpAndSettle();

          expect(find.text(expectedDeleteSuccessToastMessage), findsOneWidget);

          await tester.pumpAndSettle(kToastDuration);
        },
      );

      final expectedDeleteFailureToastTitle =
          expectedTranslation['deleteFailureToastTitle']!;
      final expectedDeleteFailureToastMessage =
          expectedTranslation['deleteFailureToastMessage']!;
      testWidgets(
        'shows correct toast when delete is failed '
        'for locale $locale',
        (tester) async {
          whenListen(
            mockWalletsBloc,
            Stream<WalletsState>.fromIterable([
              WalletsState(
                status: WalletsUIStatus.loaded,
                wallets: walletsData,
                notice: WalletUINotice.deleteFailed(
                  wallet: walletsData.first.wallet,
                  exception: AppException.test(),
                ),
              ),
            ]),
            initialState: WalletsState(
              status: WalletsUIStatus.loaded,
              wallets: walletsData,
            ),
          );

          await pumpWidget(tester, locale: locale);
          await tester.pumpAndSettle();

          expect(find.text(expectedDeleteFailureToastTitle), findsOneWidget);
          expect(find.text(expectedDeleteFailureToastMessage), findsOneWidget);

          await tester.pumpAndSettle(kToastDuration);
        },
      );
    }
  });
}
