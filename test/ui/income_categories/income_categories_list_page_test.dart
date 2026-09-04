import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/income_categories/add_income_categories_list_page.dart';
import 'package:journexa_app/ui/income_categories/bloc/income_categories_bloc.dart';
import 'package:journexa_app/ui/income_categories/widgets/income_categories_list_view.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_icon_button.dart';
import 'package:mocktail/mocktail.dart';

import '../util.dart';

class MockIncomeCategoriesBloc extends Mock implements IncomeCategoriesBloc {}

final expectedTranslations = {
  'id': {
    'title': 'Daftar Kategori Pendapatan',
  },
  'en': {
    'title': 'Income Categories List',
  },
};

void main() {
  late IncomeCategoriesBloc mockIncomeCategoriesBloc;

  setUp(() {
    mockIncomeCategoriesBloc = MockIncomeCategoriesBloc();
    whenListen(
      mockIncomeCategoriesBloc,
      const Stream<IncomeCategoriesState>.empty(),
      initialState: const IncomeCategoriesState(),
    );
    when(mockIncomeCategoriesBloc.close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Map<String, Widget> nextRoutes = const {},
  }) {
    return pumpForPageTest(
      tester,
      initialLocation: '/income-categories',
      routes: {
        '/income-categories': IncomeCategoriesListPage(
          incomeCategoriesBloc: mockIncomeCategoriesBloc,
        ),
        ...nextRoutes,
      },
      locale: locale,
    );
  }

  group('Init', () {
    testWidgets(
      'add IncomeCategoriesEvent.subscriptionRequested event on start',
      (tester) async {
        await pumpWidget(tester);

        verify(
          () => mockIncomeCategoriesBloc.add(
            const IncomeCategoriesEvent.subscriptionRequested(),
          ),
        ).called(1);
      },
    );
  });

  group('Render', () {
    testWidgets(
      'provides IncomeCategoriesBloc',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<IncomeCategoriesBloc>), findsOneWidget);
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
      'has IncomeCategoriesListView',
      (tester) async {
        await pumpWidget(tester);

        expect(find.byType(IncomeCategoriesListView), findsOneWidget);
      },
    );
  });

  group('Interactions', () {
    testWidgets(
      'navigates to /add-income-category when add button pressed',
      (tester) async {
        await pumpWidget(
          tester,
          nextRoutes: {
            '/add-income-category': const Placeholder(),
          },
        );

        final finder = find.byType(AppIconButton);
        await tester.tap(finder);
        await tester.pumpAndSettle();

        expect(find.byType(Placeholder), findsOneWidget);
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

  group('Side Effects', () {
    testWidgets(
      'add IncomeCategoriesBlocEvent.subscriptionRequested '
      'after going back from add income category page',
      (tester) async {
        await pumpWidget(
          tester,
          nextRoutes: {
            '/add-income-category': Scaffold(
              key: const ValueKey('add-income-category-page'),
              appBar: AppBar(),
            ),
          },
        );

        final finder = find.byType(AppIconButton);
        await tester.tap(finder);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('add-income-category-page')),
          findsOneWidget,
        );

        await tester.tap(find.backButton());
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('add-income-category-page')),
          findsNothing,
        );

        verify(
          () => mockIncomeCategoriesBloc.add(
            const IncomeCategoriesEvent.subscriptionRequested(),
          ),
        ).called(2);
      },
    );
  });
}
