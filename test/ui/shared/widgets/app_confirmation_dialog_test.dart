import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';
import 'package:journexa_app/ui/shared/widgets/app_confirmation_dialog.dart';

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
    Locale locale = const Locale('en'),
    String? title,
    String? content,
    String? confirmLabel,
    String? cancelLabel,
    VoidCallback? onConfirmPressed,
    VoidCallback? onCancelPressed,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: locale,
      widget: AppConfirmationDialog(
        title: title ?? 'title',
        content: content ?? 'content',
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirmPressed: onConfirmPressed,
        onCancelPressed: onCancelPressed,
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows title when provided',
      (tester) async {
        await pumpWidget(
          tester,
          title: 'title',
        );

        expect(find.text('title'), findsOneWidget);
      },
    );

    testWidgets(
      'shows content when provided',
      (tester) async {
        await pumpWidget(
          tester,
          content: 'content',
        );

        expect(find.text('content'), findsOneWidget);
      },
    );

    for (final locale in AppLocalizations.supportedLocales) {
      final expectedConfirmLabel =
          expectedTranslations[locale.languageCode]!['confirmLabel']!;
      testWidgets(
        'shows default $expectedConfirmLabel confirm label '
        'for ${locale.languageCode} when not provided',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.text(expectedConfirmLabel), findsOneWidget);
        },
      );

      final expectedCancelLabel =
          expectedTranslations[locale.languageCode]!['cancelLabel']!;
      testWidgets(
        'shows default $expectedCancelLabel cancel label '
        'for ${locale.languageCode} when not provided',
        (tester) async {
          await pumpWidget(tester, locale: locale);

          expect(find.text(expectedCancelLabel), findsOneWidget);
        },
      );
    }

    testWidgets(
      'shows confirm label when provided',
      (tester) async {
        await pumpWidget(
          tester,
          confirmLabel: 'confirm',
        );

        expect(find.text('confirm'), findsOneWidget);
      },
    );

    testWidgets(
      'shows cancel label when provided',
      (tester) async {
        await pumpWidget(
          tester,
          cancelLabel: 'cancel',
        );

        expect(find.text('cancel'), findsOneWidget);
      },
    );
  });

  group('Interactions', () {
    testWidgets(
      'calls onConfirmPressed when confirm button is pressed',
      (tester) async {
        var isPressed = false;
        await pumpWidget(
          tester,
          confirmLabel: 'OK',
          onConfirmPressed: () {
            isPressed = true;
          },
        );

        await tester.tap(find.text('OK'));
        await tester.pump();

        expect(isPressed, isTrue);
      },
    );

    testWidgets(
      'calls onCancelPressed when cancel button is pressed',
      (tester) async {
        var isPressed = false;
        await pumpWidget(
          tester,
          cancelLabel: 'Cancel',
          onCancelPressed: () {
            isPressed = true;
          },
        );

        await tester.tap(find.text('Cancel'));
        await tester.pump();

        expect(isPressed, isTrue);
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
          await pumpWidget(tester, locale: locale);

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
          await pumpWidget(tester, locale: locale);

          expect(
            tester.getSemantics(find.text(expectedConfirmLabel)),
            isSemantics(isButton: true),
          );
        },
      );
    }

    testWidgets(
      'has correct title semantically when provided',
      (tester) async {
        await pumpWidget(
          tester,
          title: 'title',
        );

        final finder = find.bySemanticsLabel('title');
        expect(finder, findsOneWidget);
        expect(
          tester.getSemantics(finder),
          isSemantics(isHeader: true),
        );
      },
    );

    testWidgets(
      'has correct content semantically when provided',
      (tester) async {
        await pumpWidget(
          tester,
          content: 'content',
        );

        expect(
          find.bySemanticsLabel('content'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'has correct confirm label semantically when provided',
      (tester) async {
        await pumpWidget(
          tester,
          confirmLabel: 'Done',
        );

        expect(find.bySemanticsLabel('Done'), findsOneWidget);
      },
    );

    testWidgets(
      'has correct cancel label semantically when provided',
      (tester) async {
        await pumpWidget(
          tester,
          cancelLabel: 'No',
        );

        expect(find.bySemanticsLabel('No'), findsOneWidget);
      },
    );
  });

  group('AppConfirmationDialog.show', () {
    const title = 'title';
    const content = 'content';
    const confirmLabel = 'Done';
    const cancelLabel = 'No';
    Future<void> pumpButtonToShow(
      WidgetTester tester, {
      ValueChanged<bool>? onResult,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return AppButton(
                  onPressed: () async {
                    final result = await AppConfirmationDialog.show(
                      context,
                      title: title,
                      content: content,
                      confirmLabel: confirmLabel,
                      cancelLabel: cancelLabel,
                    );
                    if (!context.mounted) return;
                    onResult?.call(result ?? false);
                  },
                  label: 'show',
                );
              },
            ),
          ),
        ),
      );
    }

    testWidgets(
      'shows correct AppConfirmationDialog',
      (tester) async {
        await pumpButtonToShow(tester);

        await tester.tap(find.text('show'));
        await tester.pump();

        final finder = find.byType(AppConfirmationDialog);
        expect(finder, findsOneWidget);
        final widget = tester.widget<AppConfirmationDialog>(finder);
        expect(widget.title, title);
        expect(widget.content, content);
        expect(widget.confirmLabel, confirmLabel);
        expect(widget.cancelLabel, cancelLabel);
      },
    );

    group('Interactions', () {
      testWidgets(
        'returns true when confirm button is pressed',
        (tester) async {
          bool? result;
          await pumpButtonToShow(tester, onResult: (v) => result = v);

          await tester.tap(find.text('show'));
          await tester.pump();
          expect(find.byType(AppConfirmationDialog), findsOneWidget);

          await tester.tap(find.text('Done'));
          await tester.pump();

          expect(find.byType(AppConfirmationDialog), findsNothing);
          expect(result, isTrue);
        },
      );

      testWidgets(
        'returns false when cancel button is pressed',
        (tester) async {
          bool? result;
          await pumpButtonToShow(tester, onResult: (v) => result = v);

          await tester.tap(find.text('show'));
          await tester.pump();
          expect(find.byType(AppConfirmationDialog), findsOneWidget);

          await tester.tap(find.text('No'));
          await tester.pump();

          expect(find.byType(AppConfirmationDialog), findsNothing);
          expect(result, isFalse);
        },
      );
    });
  });
}
