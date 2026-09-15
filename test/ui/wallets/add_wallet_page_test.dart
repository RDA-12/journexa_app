import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/wallets/add_wallet_page.dart';
import 'package:journexa_app/ui/wallets/bloc/add_wallet_bloc.dart';
import 'package:journexa_app/ui/wallets/widgets/add_wallet_view.dart';
import 'package:mocktail/mocktail.dart';

import '../util.dart';

class MockAddWalletBloc extends Mock implements AddWalletBloc;

const expectedTranslations = {
  'id': {'title': 'Tambah Dompet Baru'},
  'en': {'title': 'Add New Wallet'},
};

void main() {
  late AddWalletBloc mockAddWalletBloc;

  setUp(() {
    mockAddWalletBloc = MockAddWalletBloc();
    whenListen(
      mockAddWalletBloc,
      const Stream<AddWalletState>.empty(),
      initialState: const AddWalletState.initial(),
    );
    when(mockAddWalletBloc.close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Map<String, Widget> nextRoutes = const {},
  }) {
    return pumpForPageTest(
      tester,
      initialLocation: '/add-wallet-account',
      routes: {
        '/add-wallet-account': AddWalletPage(addWalletBloc: mockAddWalletBloc),
        ...nextRoutes,
      },
      locale: locale,
    );
  }

  group('Render', () {
    testWidgets('provides AddWalletBloc', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(BlocProvider<AddWalletBloc>), findsOneWidget);
    });

    testWidgets('has AddWalletView', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(AddWalletView), findsOneWidget);
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
  });
}
