import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/income_categories/bloc/income_categories_bloc.dart';
import 'package:journexa_app/ui/income_categories/widgets/income_categories_list_view.dart';
import 'package:journexa_app/ui/income_categories/widgets/income_category_form.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/app_empty_box.dart';
import 'package:journexa_app/ui/shared/widgets/app_exception_box.dart';
import 'package:journexa_app/ui/shared/widgets/app_form_field.dart';
import 'package:journexa_app/ui/shared/widgets/app_icon_button.dart';
import 'package:journexa_app/ui/shared/widgets/app_list_view.dart';
import 'package:journexa_app/ui/shared/widgets/loading_indicator.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockIncomeCategoriesBloc extends Mock implements IncomeCategoriesBloc {}

final expectedTranslations = {
  'id': {
    'errorTitle': 'Gagal mendapatkan data kategori pendapatan',
    'errorDesc': 'Terjadi kesalahan internal',
    'semanticsLoading': 'Memuat data kategori pendapatan',
    'searchLabel': 'Cari Kategori Pendapatan',
    'emptyTitle': 'Data Tidak Ditemukan',
    'emptyDescription': 'Tidak ada data kategori pendapatan yang ditemukan',
    'semanticsAddButton': 'Tambah Kategori Pendapatan',
  },
  'en': {
    'errorTitle': 'Failed to get income categories data',
    'errorDesc': 'Internal exception error',
    'semanticsLoading': 'Loading income categories data',
    'searchLabel': 'Search Income Category',
    'emptyTitle': 'Data Not Found',
    'emptyDescription': 'No income categories data was found',
    'semanticsAddButton': 'Add Income Category',
  },
};

void main() {
  final categories = List.generate(3, (index) {
    return IncomeCategory(
      id: '$index',
      name: 'name $index',
      icon: 'icon',
      account: Account.user(
        parent: SystemDefinedAccount.rootRevenue,
        name: 'name $index',
        currentChildrenCount: index,
      ),
    );
  });
  final categoriesState = categories
      .map((it) => IncomeCategoryWithState(category: it))
      .toList();

  late IncomeCategoriesBloc mockIncomeCategoriesBloc;

  setUp(() {
    mockIncomeCategoriesBloc = MockIncomeCategoriesBloc();
    whenListen(
      mockIncomeCategoriesBloc,
      const Stream<IncomeCategoriesState>.empty(),
      initialState: const IncomeCategoriesState(),
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
        value: mockIncomeCategoriesBloc,
        child: IncomeCategoriesListView(
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
          mockIncomeCategoriesBloc,
          const Stream<IncomeCategoriesState>.empty(),
          initialState: const IncomeCategoriesState(
            status: IncomeCategoriesStatus.loading,
          ),
        );

        await pumpWidget(tester);

        expect(find.byType(LoadingIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'shows AppListView with correct categories '
      'when state is loaded',
      (tester) async {
        whenListen(
          mockIncomeCategoriesBloc,
          const Stream<IncomeCategoriesState>.empty(),
          initialState: IncomeCategoriesState(
            status: IncomeCategoriesStatus.loaded,
            categories: categoriesState,
          ),
        );

        await pumpWidget(tester);

        final finder = find.byType(AppListView<IncomeCategoryWithState>);
        expect(finder, findsOneWidget);
        final widget = tester.widget<AppListView<IncomeCategoryWithState>>(
          finder,
        );
        expect(widget.items, categoriesState);
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
            mockIncomeCategoriesBloc,
            const Stream<IncomeCategoriesState>.empty(),
            initialState: IncomeCategoriesState(
              status: IncomeCategoriesStatus.failure,
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
            mockIncomeCategoriesBloc,
            const Stream<IncomeCategoriesState>.empty(),
            initialState: IncomeCategoriesState(
              status: IncomeCategoriesStatus.loaded,
              categories: categoriesState,
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
            mockIncomeCategoriesBloc,
            const Stream<IncomeCategoriesState>.empty(),
            initialState: const IncomeCategoriesState(
              status: IncomeCategoriesStatus.loaded,
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
            mockIncomeCategoriesBloc,
            const Stream<IncomeCategoriesState>.empty(),
            initialState: const IncomeCategoriesState(
              status: IncomeCategoriesStatus.loaded,
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
      'add IncomeCategoriesEvent.subscriptionRequested with correct query',
      (tester) async {
        await pumpWidget(tester);

        final finder = find.byType(TextFormField);
        await tester.enterText(finder, 'query');
        expect(find.text('query'), findsOneWidget);

        verify(
          () => mockIncomeCategoriesBloc.add(
            const IncomeCategoriesEvent.subscriptionRequested(query: 'query'),
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
      'add IncomeCategoriesEvent.delete with correct category '
      'when a category is deleted',
      (tester) async {
        whenListen(
          mockIncomeCategoriesBloc,
          const Stream<IncomeCategoriesState>.empty(),
          initialState: IncomeCategoriesState(
            status: IncomeCategoriesStatus.loaded,
            categories: categoriesState,
          ),
        );

        await pumpWidget(tester);

        final firstCategory = categories.first;
        await tester.tap(find.text(firstCategory.name));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        verify(
          () => mockIncomeCategoriesBloc.add(
            IncomeCategoriesEvent.delete(firstCategory),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'add IncomeCategoriesEvent.update with correct category '
      'and updated data when a category is updated',
      (tester) async {
        whenListen(
          mockIncomeCategoriesBloc,
          const Stream<IncomeCategoriesState>.empty(),
          initialState: IncomeCategoriesState(
            status: IncomeCategoriesStatus.loaded,
            categories: categoriesState,
          ),
        );

        await pumpWidget(tester);

        final firstCategory = categories.first;
        await tester.tap(find.text(firstCategory.name));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Update'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.descendant(
            of: find.byType(IncomeCategoryForm),
            matching: find.byType(TextFormField),
          ),
          'new name',
        );
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        verify(
          () => mockIncomeCategoriesBloc.add(
            IncomeCategoriesEvent.update(firstCategory, name: 'new name'),
          ),
        ).called(1);
      },
    );
  });

  group('a11y', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final expectedTranslation = expectedTranslations[locale.languageCode]!;
      final expectedSemantics = expectedTranslation['semanticsLoading']!;
      testWidgets(
        'has $expectedSemantics '
        'when state is loading for ${locale.languageCode}',
        (tester) async {
          whenListen(
            mockIncomeCategoriesBloc,
            const Stream<IncomeCategoriesState>.empty(),
            initialState: const IncomeCategoriesState(
              status: IncomeCategoriesStatus.loading,
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
            mockIncomeCategoriesBloc,
            const Stream<IncomeCategoriesState>.empty(),
            initialState: IncomeCategoriesState(
              status: IncomeCategoriesStatus.loaded,
              categories: categoriesState,
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
            mockIncomeCategoriesBloc,
            const Stream<IncomeCategoriesState>.empty(),
            initialState: IncomeCategoriesState(
              status: IncomeCategoriesStatus.loaded,
              categories: categoriesState,
            ),
          );

          await pumpWidget(tester, locale: locale);

          expect(find.byTooltip(expectedTooltip), findsOneWidget);
        },
      );
    }
  });
}
