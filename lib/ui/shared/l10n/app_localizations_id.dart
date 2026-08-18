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
  String get loginSuccessMessage => 'Mengarahkan ke proses inisialisasi...';

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

  @override
  String get appLogoLabel => 'Logo Journexa';

  @override
  String get splashBoxLabel => 'Membuka aplikasi Journexa';

  @override
  String errorAccountAlreadyExists(String name) {
    return '$name dengan nama tersebut sudah ada';
  }

  @override
  String get formErrorRequired => 'Harus diisi';

  @override
  String get addCashAccountNameLabel => 'Nama';

  @override
  String get addCashAccountButtonLabel => 'Tambah Kas';

  @override
  String get commonCash => 'Kas';

  @override
  String get addCashAccountSuccessMessage => 'Kas ditambahkan';

  @override
  String get addCashAccountSuccessTitle => 'Kas berhasil ditambahkan';

  @override
  String get addCashAccountFailureTitle => 'Gagal menambahkan kas';

  @override
  String get commonRequired => 'Wajib';

  @override
  String get addCashAccountTitle => 'Tambah Kas Baru';

  @override
  String errorAccountNotFound(String code) {
    return 'Akun dengan kode $code tidak dapat ditemukan';
  }

  @override
  String get cashAccountsListFailureTitle => 'Gagal mendapatkan data kas';

  @override
  String get cashAccountsListLoadingSemantics => 'Memuat data kas';

  @override
  String get cashAccountsListTitle => 'Daftar Kas';

  @override
  String get cashAccountsListSearchLabel => 'Cari Kas';

  @override
  String get commonEmptyTitle => 'Data Tidak Ditemukan';

  @override
  String get cashAccountsListEmptyDescription =>
      'Tidak ada data kas yang ditemukan';

  @override
  String get cashAccountsListAddButtonSemantics => 'Tambah Kas Baru';

  @override
  String get commonConfirmLabel => 'OK';

  @override
  String get commonCancelLabel => 'Batal';

  @override
  String deleteCashAccountDialogTitle(String name) {
    return 'Hapus $name?';
  }

  @override
  String deleteCashAccountDialogContent(String name) {
    return 'Data yang terikat dengan $name akan tetap ada. Tapi, $name tidak akan bisa digunakan lagi untuk transaksi selanjutnya';
  }

  @override
  String get deleteCashAccountDialogConfirmLabel => 'Hapus';

  @override
  String get commonDelete => 'Hapus';

  @override
  String deleteCashAccountSemantics(String name) {
    return 'Hapus $name';
  }

  @override
  String get commonDeletingLabel => 'Menghapus';

  @override
  String deleteCashAccountDeletingSemanticsLabel(String name) {
    return 'Menghapus $name';
  }
}
