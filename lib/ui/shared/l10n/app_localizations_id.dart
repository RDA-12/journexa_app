// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get loginButtonGoogleLabel => 'Masuk dengan Google';

  @override
  String get commonAppName => 'Journexa';

  @override
  String get commonAppTagline => 'Partner finansial pribadi Anda';

  @override
  String get loginSuccessTitle => 'Login berhasil';

  @override
  String get loginSuccessMessage => 'Mengarahkan ke halaman utama...';

  @override
  String get loginFailedTitle => 'Login gagal';

  @override
  String get errorInternalException => 'Terjadi kesalahan internal';

  @override
  String get errorLoginCanceled => 'Proses login dibatalkan';

  @override
  String get errorServerException => 'Terjadi kesalahan di server';

  @override
  String get errorUnauthenticated =>
      'Anda belum login. Silakan login untuk melanjutkan.';

  @override
  String get initializeLoadingText => 'Menginisialisasi...';

  @override
  String get initializeErrorTitle => 'Inisialisasi gagal';
}
