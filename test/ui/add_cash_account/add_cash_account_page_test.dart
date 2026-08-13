import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/add_cash_account/add_cash_account_page.dart';
import 'package:journexa_app/ui/add_cash_account/bloc/add_cash_account_bloc.dart';
import 'package:journexa_app/ui/add_cash_account/widgets/add_cash_account_form.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:mocktail/mocktail.dart';

import '../util.dart';

class MockAddCashAccountBloc extends Mock implements AddCashAccountBloc {}

const expectedTranslations = {
  'id': {
    'title': 'Tambah Kas Baru',
  },
  'en': {
    'title': 'Add New Cash',
  },
};

void main() {
  late AddCashAccountBloc mockAddCashAccountBloc;

  setUp(() {
    mockAddCashAccountBloc = MockAddCashAccountBloc();
    whenListen(
      mockAddCashAccountBloc,
      const Stream<AddCashAccountState>.empty(),
      initialState: const AddCashAccountState.initial(),
    );
    when(mockAddCashAccountBloc.close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Map<String, Widget> nextRoutes = const {},
  }) {
    return pumpForPageTest(
      tester,
      initialLocation: '/add-cash-account',
      routes: {
        '/add-cash-account': AddCashAccountPage(
          addCashAccountBloc: mockAddCashAccountBloc,
        ),
        ...nextRoutes,
      },
      locale: locale,
    );
  }

  group('Render', () {
    testWidgets(
      'provides AddCashAccountBloc',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<AddCashAccountBloc>), findsOneWidget);
      },
    );

    testWidgets(
      'has AddCashAccountForm',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byType(AddCashAccountForm), findsOneWidget);
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
  });
}
