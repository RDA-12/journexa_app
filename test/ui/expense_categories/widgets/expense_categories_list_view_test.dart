import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/expense_categories/bloc/expense_categories_bloc.dart';
import 'package:journexa_app/ui/expense_categories/widgets/expense_categories_list_view.dart';
import 'package:journexa_app/ui/expense_categories/widgets/expense_category_form.dart';
import 'package:journexa_app/ui/expense_categories/widgets/expense_category_tile.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/app_empty_box.dart';
import 'package:journexa_app/ui/shared/widgets/app_exception_box.dart';
import 'package:journexa_app/ui/shared/widgets/app_form_field.dart';
import 'package:journexa_app/ui/shared/widgets/app_icon_button.dart';
import 'package:journexa_app/ui/shared/widgets/app_list_view.dart';
import 'package:journexa_app/ui/shared/widgets/loading_indicator.dart';
import 'package:mocktail/mocktail.dart';

import '../../util.dart';

class MockExpenseCategoriesBloc extends Mock implements ExpenseCategoriesBloc;

final expectedTranslations = {
  'id': {
    'errorTitle': 'Gagal mendapatkan data kategori pengeluaran',
    'errorDesc': 'Terjadi kesalahan internal',
    'semanticsLoading': 'Memuat data kategori pengeluaran',
    'searchLabel': 'Cari Kategori Pengeluaran',
    'emptyTitle': 'Data Tidak Ditemukan',
    'emptyDescription': 'Tidak ada data kategori pengeluaran yang ditemukan',
    'semanticsAddButton': 'Tambah Kategori Pengeluaran',
  },
  'en': {
    'errorTitle': 'Failed to get expense categories data',
    'errorDesc': 'Internal exception error',
    'semanticsLoading': 'Loading expense categories data',
    'searchLabel': 'Search Expense Category',
    'emptyTitle': 'Data Not Found',
    'emptyDescription': 'No expense categories data was found',
    'semanticsAddButton': 'Add Expense Category',
  },
};

void main() {
  final categories = List.generate(3, (index) {
    return ExpenseCategory(
      id: '$index',
      name: 'name $index',
      icon: 'icon',
      account: Account.sub(
        parent: SystemDefinedAccount.expenseParent,
        name: 'name $index',
        currentChildrenCount: index,
      ),
    );
  });
  final categoriesState = categories;

  late ExpenseCategoriesBloc mockExpenseCategoriesBloc;

  setUp(() {
    mockExpenseCategoriesBloc = MockExpenseCategoriesBloc();
    whenListen(
      mockExpenseCategoriesBloc,
      const Stream<ExpenseCategoriesState>.empty(),
      initialState: const ExpenseCategoriesState(),
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
        value: mockExpenseCategoriesBloc,
        child: ExpenseCategoriesListView(
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
          mockExpenseCategoriesBloc,
          const Stream<ExpenseCategoriesState>.empty(),
          initialState: const ExpenseCategoriesState(
            status: ExpenseCategoriesUIStatus.loading,
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
          mockExpenseCategoriesBloc,
          const Stream<ExpenseCategoriesState>.empty(),
          initialState: ExpenseCategoriesState(
            status: ExpenseCategoriesUIStatus.loaded,
            categories: categoriesState,
            deletingIds: {categoriesState.first.id},
            updatingIds: {categoriesState[1].id},
          ),
        );

        await pumpWidget(tester);

        final finder = find.byType(AppListView<ExpenseCategory>);
        expect(finder, findsOneWidget);
        final widget = tester.widget<AppListView<ExpenseCategory>>(
          finder,
        );
        expect(widget.items, categoriesState);

        final categoryTilesFinder = find.descendant(
          of: finder,
          matching: find.byType(ExpenseCategoryTile),
        );
        for (var i = 0; i < categoriesState.length; i++) {
          final tileFinder = categoryTilesFinder.at(i);
          final widget = tester.widget<ExpenseCategoryTile>(tileFinder);
          final item = categoriesState[i];
          expect(widget.category, item);
          expect(widget.isDeleting, i == 0 ? isTrue : isFalse);
          expect(widget.isUpdating, i == 1 ? isTrue : isFalse);
        }
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
            mockExpenseCategoriesBloc,
            const Stream<ExpenseCategoriesState>.empty(),
            initialState: ExpenseCategoriesState(
              status: ExpenseCategoriesUIStatus.failure,
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
            mockExpenseCategoriesBloc,
            const Stream<ExpenseCategoriesState>.empty(),
            initialState: ExpenseCategoriesState(
              status: ExpenseCategoriesUIStatus.loaded,
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
            mockExpenseCategoriesBloc,
            const Stream<ExpenseCategoriesState>.empty(),
            initialState: const ExpenseCategoriesState(
              status: ExpenseCategoriesUIStatus.loaded,
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
            mockExpenseCategoriesBloc,
            const Stream<ExpenseCategoriesState>.empty(),
            initialState: const ExpenseCategoriesState(
              status: ExpenseCategoriesUIStatus.loaded,
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
      'add ExpenseCategoriesEvent.subscriptionRequested with correct query',
      (tester) async {
        await pumpWidget(tester);

        final finder = find.byType(TextFormField);
        await tester.enterText(finder, 'query');
        expect(find.text('query'), findsOneWidget);

        verify(
          () => mockExpenseCategoriesBloc.add(
            const ExpenseCategoriesEvent.subscriptionRequested(query: 'query'),
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
      'add ExpenseCategoriesEvent.delete with correct category '
      'when a category is deleted',
      (tester) async {
        whenListen(
          mockExpenseCategoriesBloc,
          const Stream<ExpenseCategoriesState>.empty(),
          initialState: ExpenseCategoriesState(
            status: ExpenseCategoriesUIStatus.loaded,
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
          () => mockExpenseCategoriesBloc.add(
            ExpenseCategoriesEvent.delete(firstCategory),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'add ExpenseCategoriesEvent.update with correct category '
      'and updated data when a category is updated',
      (tester) async {
        whenListen(
          mockExpenseCategoriesBloc,
          const Stream<ExpenseCategoriesState>.empty(),
          initialState: ExpenseCategoriesState(
            status: ExpenseCategoriesUIStatus.loaded,
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
            of: find.byType(ExpenseCategoryForm),
            matching: find.byType(TextFormField),
          ),
          'new name',
        );
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        verify(
          () => mockExpenseCategoriesBloc.add(
            ExpenseCategoriesEvent.update(firstCategory, name: 'new name'),
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
            mockExpenseCategoriesBloc,
            const Stream<ExpenseCategoriesState>.empty(),
            initialState: const ExpenseCategoriesState(
              status: ExpenseCategoriesUIStatus.loading,
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
            mockExpenseCategoriesBloc,
            const Stream<ExpenseCategoriesState>.empty(),
            initialState: ExpenseCategoriesState(
              status: ExpenseCategoriesUIStatus.loaded,
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
            mockExpenseCategoriesBloc,
            const Stream<ExpenseCategoriesState>.empty(),
            initialState: ExpenseCategoriesState(
              status: ExpenseCategoriesUIStatus.loaded,
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
