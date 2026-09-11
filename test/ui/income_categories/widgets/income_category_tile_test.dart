import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/ui/income_categories/widgets/income_category_form.dart';
import 'package:journexa_app/ui/income_categories/widgets/income_category_tile.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';

import '../../util.dart';

final expectedTranslations = {
  'id': {
    'updateLabel': 'Perbarui',
    'updateSemantics': 'Perbarui name',
    'updateUpdatingSemanticsLabel': 'Memperbarui name',
    'deleteLabel': 'Hapus',
    'deleteSemantics': 'Hapus name',
    'deleteDeletingSemanticsLabel': 'Menghapus name',
    'deleteDialogTitle': 'Hapus name?',
    'deleteDialogContent':
        'Data yang terikat dengan '
        'kategori pendapatan name akan tetap ada. '
        'Tapi, kategori pendapatan name tidak akan bisa digunakan lagi '
        'untuk data pendapatan selanjutnya',
    'deleteDialogConfirmLabel': 'Hapus',
    'deleteDialogCancelLabel': 'Batal',
  },
  'en': {
    'updateLabel': 'Update',
    'updateSemantics': 'Update name',
    'updateUpdatingSemanticsLabel': 'Updating name',
    'deleteLabel': 'Delete',
    'deleteSemantics': 'Delete name',
    'deleteDeletingSemanticsLabel': 'Deleting name',
    'deleteDialogTitle': 'Delete name?',
    'deleteDialogContent':
        'Data related to name income category will still exist. '
        'But, name income category will no longer be able to be used '
        'for future income data',
    'deleteDialogConfirmLabel': 'Delete',
    'deleteDialogCancelLabel': 'Cancel',
  },
};

void main() {
  final category = IncomeCategory(
    id: 'id',
    name: 'name',
    icon: 'icon',
    account: Account.sub(
      parent: SystemDefinedAccount.incomeParent,
      name: 'name',
      currentChildrenCount: 0,
    ),
  );

  Future<void> pumpWidget(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    VoidCallback? onDeletePressed,
    bool isUpdating = false,
    bool isDeleting = false,
    void Function({required String icon, required String name})?
    onUpdatePressed,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: IncomeCategoryTile(
        category: category,
        isDeleting: isDeleting,
        isUpdating: isUpdating,
        onDeletePressed: onDeletePressed,
        onUpdatePressed: onUpdatePressed,
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows correct category name',
      (tester) async {
        await pumpWidget(tester);

        expect(find.text(category.name), findsOneWidget);
      },
    );

    for (final locale in AppLocalizations.supportedLocales) {
      final expected = expectedTranslations[locale.languageCode]!;

      final expectedUpdatingName = expected['updateUpdatingSemanticsLabel']!;
      testWidgets(
        'shows correct name when isUpdating true',
        (tester) async {
          await pumpWidget(tester, locale: locale, isUpdating: true);

          expect(find.text(expectedUpdatingName), findsOneWidget);
        },
      );

      final expectedDeletingName = expected['deleteDeletingSemanticsLabel']!;
      testWidgets(
        'shows correct name when isDeleting true',
        (tester) async {
          await pumpWidget(tester, locale: locale, isDeleting: true);

          expect(find.text(expectedDeletingName), findsOneWidget);
        },
      );

      group('ActionSheet - ${locale.languageCode}', () {
        Future<void> actionSheetInit(WidgetTester tester) async {
          await pumpWidget(tester, locale: locale);

          await tester.tap(find.byType(IncomeCategoryTile));
          await tester.pumpAndSettle();
        }

        final expectedUpdateLabel = expected['updateLabel']!;
        testWidgets(
          'shows $expectedUpdateLabel '
          'for ${locale.languageCode} on Actions sheet',
          (tester) async {
            await actionSheetInit(tester);

            expect(find.text(expectedUpdateLabel), findsOneWidget);
          },
        );

        final expectedDeleteLabel = expected['deleteLabel']!;
        testWidgets(
          'shows $expectedDeleteLabel '
          'for ${locale.languageCode} on Actions sheet',
          (tester) async {
            await actionSheetInit(tester);

            expect(find.text(expectedDeleteLabel), findsOneWidget);
          },
        );
      });

      group('DeleteDialog - ${locale.languageCode}', () {
        final deleteLabel = expected['deleteLabel']!;

        Future<void> deleteDialogInit(WidgetTester tester) async {
          await pumpWidget(tester, locale: locale);

          await tester.tap(find.byType(IncomeCategoryTile));
          await tester.pumpAndSettle();

          await tester.tap(find.text(deleteLabel));
          await tester.pumpAndSettle();
        }

        final expectedDeleteTitle = expected['deleteDialogTitle']!;
        testWidgets(
          'shows correct title on delete dialog for ${locale.languageCode}',
          (tester) async {
            await deleteDialogInit(tester);

            expect(find.text(expectedDeleteTitle), findsOneWidget);
          },
        );

        final expectedDeleteContent = expected['deleteDialogContent']!;
        testWidgets(
          'shows correct content on delete dialog for ${locale.languageCode}',
          (tester) async {
            await deleteDialogInit(tester);

            expect(find.text(expectedDeleteContent), findsOneWidget);
          },
        );

        final expectedDeleteConfirmLabel =
            expected['deleteDialogConfirmLabel']!;
        testWidgets(
          'shows correct confirm label on delete dialog '
          'for ${locale.languageCode}',
          (tester) async {
            await deleteDialogInit(tester);

            expect(find.text(expectedDeleteConfirmLabel), findsOneWidget);
          },
        );

        final expectedDeleteCancelLabel = expected['deleteDialogCancelLabel']!;
        testWidgets(
          'shows correct cancel label on delete dialog '
          'for ${locale.languageCode}',
          (tester) async {
            await deleteDialogInit(tester);

            expect(find.text(expectedDeleteCancelLabel), findsOneWidget);
          },
        );
      });
    }
  });

  group('Interactions', () {
    testWidgets(
      'shows IncomeCategoryForm when update action pressed',
      (tester) async {
        await pumpWidget(tester);

        await tester.tap(find.byType(IncomeCategoryTile));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Update'));
        await tester.pumpAndSettle();

        expect(find.byType(IncomeCategoryForm), findsOneWidget);
      },
    );

    testWidgets(
      'calls onUpdatePressed when update action pressed',
      (tester) async {
        Object? data;

        await pumpWidget(
          tester,
          onUpdatePressed: ({required icon, required name}) {
            data = {'name': name, 'icon': icon};
          },
        );

        await tester.tap(find.byType(IncomeCategoryTile));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Update'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).first, 'new name');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(data, {'name': 'new name', 'icon': category.icon});
      },
    );

    testWidgets(
      'calls onDeletePressed when delete action pressed',
      (tester) async {
        var called = false;

        await pumpWidget(
          tester,
          onDeletePressed: () {
            called = true;
          },
        );

        await tester.tap(find.byType(IncomeCategoryTile));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(called, isTrue);
      },
    );
  });

  group('a11y', () {
    testWidgets(
      'has correct category name semantically',
      (tester) async {
        await pumpWidget(tester);

        expect(find.bySemanticsLabel(category.name), findsOneWidget);
      },
    );

    for (final locale in AppLocalizations.supportedLocales) {
      final expected = expectedTranslations[locale.languageCode]!;

      final expectedUpdateUpdatingSemanticsLabel =
          expected['updateUpdatingSemanticsLabel']!;
      testWidgets(
        'has correct update updating semantics label '
        'for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale, isUpdating: true);

          expect(
            find.bySemanticsLabel(expectedUpdateUpdatingSemanticsLabel),
            findsOneWidget,
          );
        },
      );

      final expectedDeleteDeletingSemanticsLabel =
          expected['deleteDeletingSemanticsLabel']!;
      testWidgets(
        'has correct delete deleting semantics label '
        'for ${locale.languageCode}',
        (tester) async {
          await pumpWidget(tester, locale: locale, isDeleting: true);

          expect(
            find.bySemanticsLabel(expectedDeleteDeletingSemanticsLabel),
            findsOneWidget,
          );
        },
      );

      group('ActionSheet - ${locale.languageCode}', () {
        Future<void> initActionSheet(WidgetTester tester) async {
          await pumpWidget(tester, locale: locale);
          await tester.tap(find.byType(IncomeCategoryTile));
          await tester.pumpAndSettle();
        }

        final expectedUpdateSemantics = expected['updateSemantics']!;
        testWidgets(
          'has correct update semantics for ${locale.languageCode}',
          (tester) async {
            await initActionSheet(tester);

            expect(
              find.bySemanticsLabel(expectedUpdateSemantics),
              findsOneWidget,
            );
          },
        );

        final expectedDeleteSemantics = expected['deleteSemantics']!;
        testWidgets(
          'has correct delete semantics for ${locale.languageCode}',
          (tester) async {
            await initActionSheet(tester);

            expect(
              find.bySemanticsLabel(expectedDeleteSemantics),
              findsOneWidget,
            );
          },
        );
      });

      group('DeleteDialog - ${locale.languageCode}', () {
        final deleteLabel = expected['deleteLabel']!;
        Future<void> initDeleteDialog(WidgetTester tester) async {
          await pumpWidget(tester, locale: locale);

          await tester.tap(find.byType(IncomeCategoryTile));
          await tester.pumpAndSettle();

          await tester.tap(find.text(deleteLabel));
          await tester.pumpAndSettle();
        }

        final expectedDeleteDialogTitle = expected['deleteDialogTitle']!;
        final expectedDeleteDialogContent = expected['deleteDialogContent']!;
        testWidgets(
          'has correct delete dialog semantics for ${locale.languageCode}',
          (tester) async {
            await initDeleteDialog(tester);

            expect(
              find.bySemanticsLabel(
                '$expectedDeleteDialogTitle\n$expectedDeleteDialogContent',
              ),
              findsOneWidget,
            );
          },
        );

        final expectedDeleteDialogConfirmLabel =
            expected['deleteDialogConfirmLabel']!;
        testWidgets(
          'has correct delete dialog confirm label for ${locale.languageCode}',
          (tester) async {
            await initDeleteDialog(tester);

            expect(
              find.bySemanticsLabel(expectedDeleteDialogConfirmLabel),
              findsOneWidget,
            );
          },
        );

        final expectedDeleteDialogCancelLabel =
            expected['deleteDialogCancelLabel']!;
        testWidgets(
          'has correct delete dialog cancel label for ${locale.languageCode}',
          (tester) async {
            await initDeleteDialog(tester);

            expect(
              find.bySemanticsLabel(expectedDeleteDialogCancelLabel),
              findsOneWidget,
            );
          },
        );
      });
    }
  });
}
