import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/income_categories/add_income_category_page.dart';
import 'package:journexa_app/ui/income_categories/bloc/add_income_category_bloc.dart';
import 'package:journexa_app/ui/income_categories/widgets/add_income_category_view.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:mocktail/mocktail.dart';

import '../util.dart';

class MockAddIncomeCategoryBloc extends Mock implements AddIncomeCategoryBloc;

const expectedTranslations = {
  'id': {'title': 'Tambah Kategori Pendapatan'},
  'en': {'title': 'Add Income Category'},
};

void main() {
  late AddIncomeCategoryBloc mockAddIncomeCategoryBloc;

  setUp(() {
    mockAddIncomeCategoryBloc = MockAddIncomeCategoryBloc();
    whenListen(
      mockAddIncomeCategoryBloc,
      const Stream<AddIncomeCategoryState>.empty(),
      initialState: const AddIncomeCategoryState.initial(),
    );
    when(mockAddIncomeCategoryBloc.close).thenAnswer((_) async {});
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
        '/add-wallet-account': AddIncomeCategoryPage(
          addIncomeCategoryBloc: mockAddIncomeCategoryBloc,
        ),
        ...nextRoutes,
      },
      locale: locale,
    );
  }

  group('Render', () {
    testWidgets('provides AddIncomeCategoryBloc', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(BlocProvider<AddIncomeCategoryBloc>), findsOneWidget);
    });

    testWidgets('has AddIncomeCategoryView', (tester) async {
      await pumpWidget(tester);

      expect(find.byType(AddIncomeCategoryView), findsOneWidget);
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
