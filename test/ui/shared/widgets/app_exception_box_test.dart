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
}
