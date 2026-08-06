import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';

import '../util.dart';

const Map<String, Map<AppExceptionCode, String>> expectedTranslations = {
  'id': {
    AppExceptionCode.internalException: 'Terjadi kesalahan internal',
    AppExceptionCode.loginCanceled: 'Proses login dibatalkan',
    AppExceptionCode.serverException: 'Terjadi kesalahan di server',
    AppExceptionCode.unauthenticated:
        'Anda belum login. Silakan login untuk melanjutkan.',
  },
  'en': {
    AppExceptionCode.internalException: 'Internal exception error',
    AppExceptionCode.loginCanceled: 'Login process was canceled',
    AppExceptionCode.serverException: 'Server exception error',
    AppExceptionCode.unauthenticated:
        'You are not logged in. Please login to continue.',
  },
};

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    required Locale locale,
    required AppExceptionCode code,
  }) {
    return pumpForWidgetTest(
      tester,
      widget: Builder(
        builder: (context) => Text(code.toLocalizedString(context)),
      ),
      locale: locale,
    );
  }

  group('AppExceptionCode.toLocalizeString', () {
    for (final locale in AppLocalizations.supportedLocales) {
      for (final code in AppExceptionCode.values) {
        final expected = expectedTranslations[locale.languageCode]![code]!;
        testWidgets(
          '$code translated to $expected for ${locale.languageCode}',
          (tester) async {
            await pumpWidget(tester, code: code, locale: locale);

            expect(find.text(expected), findsOneWidget);
          },
        );
      }
    }
  });
}
