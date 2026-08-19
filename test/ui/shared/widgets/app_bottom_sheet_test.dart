import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/widgets/app_bottom_sheet.dart';

import '../../util.dart';

void main() {
  Future<void> pumpWidget(WidgetTester tester) {
    return pumpForWidgetTest(
      tester,
      locale: const Locale('en'),
      widget: Builder(
        builder: (context) {
          return FilledButton(
            onPressed: () async {
              await context.showBottomModal<void>(
                builder: (context) {
                  return const Placeholder(
                    key: ValueKey('modal'),
                  );
                },
              );
            },
            child: const Text('show'),
          );
        },
      ),
    );
  }

  group('BuildContext.showBottomModal', () {
    testWidgets(
      'shows child provided in the builder',
      (tester) async {
        await pumpWidget(tester);

        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('modal')), findsOneWidget);
      },
    );
  });
}
