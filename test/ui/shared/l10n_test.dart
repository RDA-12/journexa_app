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
    AppExceptionCode.accountAlreadyExists:
        'Dompet dengan nama tersebut sudah ada',
    AppExceptionCode.accountNotFound:
        'Akun dengan kode 1234 tidak dapat ditemukan',
    AppExceptionCode.walletNameAlreadyExists:
        'Dompet dengan nama Dompet sudah ada',
  },
  'en': {
    AppExceptionCode.internalException: 'Internal exception error',
    AppExceptionCode.loginCanceled: 'Login process was canceled',
    AppExceptionCode.serverException: 'Server exception error',
    AppExceptionCode.unauthenticated:
        'You are not logged in. Please login to continue.',
    AppExceptionCode.accountAlreadyExists:
        'Dompet with provided name already exists',
    AppExceptionCode.accountNotFound: 'Account with code 1234 not found',
    AppExceptionCode.walletNameAlreadyExists:
        'Wallet with name Dompet already exists',
  },
};

final additionalData = <AppExceptionCode, Map<String, dynamic>>{
  AppExceptionCode.accountAlreadyExists: {
    'name': 'Dompet',
  },
  AppExceptionCode.walletNameAlreadyExists: {
    'name': 'Dompet',
  },
  AppExceptionCode.accountNotFound: {
    'code': '1234',
  },
};

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    required Locale locale,
    required AppExceptionCode code,
    Map<String, dynamic> data = const {},
  }) {
    return pumpForWidgetTest(
      tester,
      widget: Builder(
        builder: (context) => Text(code.toLocalizedString(context, data: data)),
      ),
      locale: locale,
    );
  }

  group('AppExceptionCode.toLocalizeString', () {
    for (final locale in AppLocalizations.supportedLocales) {
      for (final code in AppExceptionCode.values) {
        final expected = expectedTranslations[locale.languageCode]![code]!;
        final data = additionalData[code];
        testWidgets(
          '$code translated to $expected for ${locale.languageCode}',
          (tester) async {
            await pumpWidget(
              tester,
              code: code,
              locale: locale,
              data: data ?? {},
            );

            expect(find.text(expected), findsOneWidget);
          },
        );
      }
    }
  });
}
