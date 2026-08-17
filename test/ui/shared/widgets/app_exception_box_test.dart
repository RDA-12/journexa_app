import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/widgets/app_exception_box.dart';

import '../../util.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    String? title,
    String? description,
    Widget? bottom,
  }) async {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: AppExceptionBox(
        title: title,
        description: description,
        bottom: bottom,
      ),
    );
  }

  group('Render', () {
    testWidgets(
      'shows title when provided',
      (tester) async {
        const expectedTitle = 'Title';

        await pumpWidget(tester, title: expectedTitle);

        expect(find.text(expectedTitle), findsOneWidget);
      },
    );

    testWidgets(
      'shows description when provided',
      (tester) async {
        const expectedDescription = 'Description';

        await pumpWidget(tester, description: expectedDescription);

        expect(find.text(expectedDescription), findsOneWidget);
      },
    );

    testWidgets('shows bottom when provided', (tester) async {
      const expectedBottom = Text('Bottom');

      await pumpWidget(tester, bottom: expectedBottom);

      expect(find.byWidget(expectedBottom), findsOneWidget);
    });
  });

  group('a11y', () {
    testWidgets(
      'has correct title semantically',
      (tester) async {
        await pumpWidget(tester, title: 'title');

        expect(find.bySemanticsLabel('title'), findsOneWidget);
      },
    );

    testWidgets(
      'has header to true on title',
      (tester) async {
        await pumpWidget(tester, title: 'title');

        expect(
          tester.getSemantics(find.bySemanticsLabel('title')),
          isSemantics(isHeader: true),
        );
      },
    );

    testWidgets(
      'has correct description semantically',
      (tester) async {
        await pumpWidget(tester, description: 'description');

        expect(find.bySemanticsLabel('description'), findsOneWidget);
      },
    );

    testWidgets(
      'has liveRegion true on the widget',
      (tester) async {
        await pumpWidget(tester, title: 'title');

        final finder = find.byType(AppExceptionBox);
        final semantics = tester.getSemantics(finder);
        expect(semantics, isSemantics(isLiveRegion: true));
      },
    );
  });
}
