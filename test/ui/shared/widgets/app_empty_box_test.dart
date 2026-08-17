import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/widgets/app_empty_box.dart';

import '../../util.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    String? title,
    String? description,
  }) {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: AppEmptyBox(
        title: title,
        description: description,
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
  });
}
