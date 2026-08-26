import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/app_dialog.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';

import '../../util.dart';

final expectedTranslations = {
  'id': {
    'confirmLabel': 'OK',
    'cancelLabel': 'Batal',
  },
  'en': {
    'confirmLabel': 'OK',
    'cancelLabel': 'Cancel',
  },
};

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    Widget? title,
    Widget? content,
    List<Widget>? actions,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: AppDialog(
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows title when provided',
      (tester) async {
        await pumpWidget(
          tester,
          title: const Placeholder(
            key: ValueKey('title'),
          ),
        );

        expect(find.byKey(const ValueKey('title')), findsOneWidget);
      },
    );

    testWidgets(
      'shows content when provided',
      (tester) async {
        await pumpWidget(
          tester,
          content: const Placeholder(
            key: ValueKey('content'),
          ),
        );

        expect(find.byKey(const ValueKey('content')), findsOneWidget);
      },
    );

    testWidgets(
      'shows actions when provided',
      (tester) async {
        await pumpWidget(
          tester,
          actions: const [
            SizedBox(
              key: ValueKey('actions_1'),
            ),
            SizedBox(
              key: ValueKey('actions_2'),
            ),
          ],
        );

        expect(find.byKey(const ValueKey('actions_1')), findsOneWidget);
        expect(find.byKey(const ValueKey('actions_2')), findsOneWidget);
      },
    );
  });

  group('BuildContext.showConfirmationDialog', () {
    const testTitle = 'title';
    const testContent = 'content';

    Future<void> pumpWidgetForConfirmation(
      WidgetTester tester, {
      Locale locale = const Locale('en'),
      void Function({required bool result})? onResult,
      String? confirmLabel,
      String? cancelLabel,
    }) {
      return pumpForWidgetTest(
        tester,
        locale: locale,
        widget: Builder(
          builder: (context) {
            return AppButton(
              onPressed: () async {
                final result = await context.showConfirmationDialog(
                  title: testTitle,
                  content: testContent,
                  confirmLabel: confirmLabel,
                  cancelLabel: cancelLabel,
                );
                if (!context.mounted) return;
                onResult?.call(result: result ?? false);
              },
              label: 'show',
            );
          },
        ),
      );
    }

    group('Render', () {
      testWidgets(
        'shows title',
        (tester) async {
          await pumpWidgetForConfirmation(tester);

          await tester.tap(find.text('show'));
          await tester.pumpAndSettle();

          expect(find.text(testTitle), findsOneWidget);
        },
      );

      testWidgets(
        'shows content',
        (tester) async {
          await pumpWidgetForConfirmation(tester);

          await tester.tap(find.text('show'));
          await tester.pumpAndSettle();

          expect(find.text(testContent), findsOneWidget);
        },
      );

      for (final locale in AppLocalizations.supportedLocales) {
        final confirmLabel =
            expectedTranslations[locale.languageCode]!['confirmLabel']!;
        testWidgets(
          'shows $confirmLabel when confirmLabel not provided',
          (tester) async {
            await pumpWidgetForConfirmation(tester, locale: locale);

            await tester.tap(find.text('show'));
            await tester.pumpAndSettle();

            expect(find.text(confirmLabel), findsOneWidget);
          },
        );

        final cancelLabel =
            expectedTranslations[locale.languageCode]!['cancelLabel']!;
        testWidgets(
          'shows $cancelLabel when cancelLabel not provided',
          (tester) async {
            await pumpWidgetForConfirmation(tester, locale: locale);

            await tester.tap(find.text('show'));
            await tester.pumpAndSettle();

            expect(find.text(cancelLabel), findsOneWidget);
          },
        );
      }

      testWidgets(
        'shows cancelLabel provided provided',
        (tester) async {
          await pumpWidgetForConfirmation(tester, cancelLabel: 'dudu');

          await tester.tap(find.text('show'));
          await tester.pumpAndSettle();

          expect(find.text('dudu'), findsOneWidget);
        },
      );

      testWidgets(
        'shows confirmLabel provided provided',
        (tester) async {
          await pumpWidgetForConfirmation(tester, confirmLabel: 'dudu');

          await tester.tap(find.text('show'));
          await tester.pumpAndSettle();

          expect(find.text('dudu'), findsOneWidget);
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'returns true when confirmLabel is pressed',
        (tester) async {
          bool? res;

          await pumpWidgetForConfirmation(
            tester,
            onResult: ({required result}) {
              res = result;
            },
          );

          await tester.tap(find.text('show'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();

          expect(res, true);
        },
      );

      testWidgets(
        'returns false when cancelLabel is pressed',
        (tester) async {
          bool? res;

          await pumpWidgetForConfirmation(
            tester,
            onResult: ({required result}) {
              res = result;
            },
          );

          await tester.tap(find.text('show'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();

          expect(res, false);
        },
      );
    });

    group('a11y', () {
      for (final locale in AppLocalizations.supportedLocales) {
        final expectedConfirmLabel =
            expectedTranslations[locale.languageCode]!['confirmLabel']!;
        testWidgets(
          'has correct $expectedConfirmLabel confirm label semantically '
          'for ${locale.languageCode} when not provided',
          (tester) async {
            await pumpWidgetForConfirmation(tester, locale: locale);

            await tester.tap(find.text('show'));
            await tester.pumpAndSettle();

            expect(
              tester.getSemantics(find.text(expectedConfirmLabel)),
              isSemantics(isButton: true),
            );
          },
        );

        final expectedCancelLabel =
            expectedTranslations[locale.languageCode]!['cancelLabel']!;
        testWidgets(
          'has correct $expectedCancelLabel cancel label semantically '
          'for ${locale.languageCode} when not provided',
          (tester) async {
            await pumpWidgetForConfirmation(tester, locale: locale);

            await tester.tap(find.text('show'));
            await tester.pumpAndSettle();

            expect(
              tester.getSemantics(find.text(expectedCancelLabel)),
              isSemantics(isButton: true),
            );
          },
        );
      }

      testWidgets(
        'has correct title+content semantically when provided',
        (tester) async {
          await pumpWidgetForConfirmation(tester);

          await tester.tap(find.text('show'));
          await tester.pumpAndSettle();

          final finder = find.bySemanticsLabel('$testTitle\n$testContent');
          expect(finder, findsOneWidget);
        },
      );

      testWidgets(
        'has correct confirm label semantically when provided',
        (tester) async {
          await pumpWidgetForConfirmation(
            tester,
            confirmLabel: 'Done',
          );

          await tester.tap(find.text('show'));
          await tester.pumpAndSettle();

          expect(find.bySemanticsLabel('Done'), findsOneWidget);
        },
      );

      testWidgets(
        'has correct cancel label semantically when provided',
        (tester) async {
          await pumpWidgetForConfirmation(
            tester,
            cancelLabel: 'No',
          );

          await tester.tap(find.text('show'));
          await tester.pumpAndSettle();

          expect(find.bySemanticsLabel('No'), findsOneWidget);
        },
      );
    });
  });
}
