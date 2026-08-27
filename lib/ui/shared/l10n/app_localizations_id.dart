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
  String get splashBoxLabel => 'Membuka aplidompeti Journexa';

  @override
  String errorAccountAlreadyExists(String name) {
    return '$name dengan nama tersebut sudah ada';
  }

  @override
  String get formErrorRequired => 'Harus diisi';

  @override
  String get addWalletNameLabel => 'Nama';

  @override
  String get commonSaveLabel => 'Simpan';

  @override
  String get commonWallet => 'Dompet';

  @override
  String get addWalletSuccessMessage => 'Dompet ditambahkan';

  @override
  String get addWalletSuccessTitle => 'Dompet berhasil ditambahkan';

  @override
  String get addWalletFailureTitle => 'Gagal menambahkan dompet';

  @override
  String get commonRequired => 'Wajib';

  @override
  String get addWalletTitle => 'Tambah Dompet Baru';

  @override
  String errorAccountNotFound(String code) {
    return 'Akun dengan kode $code tidak dapat ditemukan';
  }

  @override
  String get walletsListFailureTitle => 'Gagal mendapatkan data dompet';

  @override
  String get walletsListLoadingSemantics => 'Memuat data dompet';

  @override
  String get walletsListTitle => 'Daftar Dompet';

  @override
  String get walletsListSearchLabel => 'Cari Dompet';

  @override
  String get commonEmptyTitle => 'Data Tidak Ditemukan';

  @override
  String get walletsListEmptyDescription =>
      'Tidak ada data dompet yang ditemukan';

  @override
  String get walletsListAddButtonSemantics => 'Tambah Dompet Baru';

  @override
  String get commonConfirmLabel => 'OK';

  @override
  String get commonCancelLabel => 'Batal';

  @override
  String deleteWalletDialogTitle(String name) {
    return 'Hapus $name?';
  }

  @override
  String deleteWalletDialogContent(String name) {
    return 'Data yang terikat dengan $name akan tetap ada. Tapi, $name tidak akan bisa digunakan lagi untuk transaksi selanjutnya';
  }

  @override
  String get deleteWalletDialogConfirmLabel => 'Hapus';

  @override
  String get commonDelete => 'Hapus';

  @override
  String deleteWalletSemantics(String name) {
    return 'Hapus $name';
  }

  @override
  String get commonDeletingLabel => 'Menghapus';

  @override
  String deleteWalletDeletingSemanticsLabel(String name) {
    return 'Menghapus $name';
  }

  @override
  String walletAccountCardSemantics(String name, String balance) {
    return '$name, Saldo $balance';
  }

  @override
  String deleteAccountToastMessage(String name) {
    return '$name telah dihapus';
  }

  @override
  String get commonUpdateLabel => 'Perbarui';

  @override
  String updateWalletSemantics(String name) {
    return 'Perbarui $name';
  }

  @override
  String get commonUpdatingLabel => 'Memperbarui';

  @override
  String updateWalletUpdatingSemanticsLabel(String name) {
    return 'Memperbarui $name';
  }

  @override
  String updateAccountToastMessage(String name) {
    return '$name telah diperbarui';
  }

  @override
  String get deleteWalletToastFailureTitle => 'Gagal menghapus data dompet';

  @override
  String get updateWalletToastFailureTitle => 'Gagal memperbarui data dompet';

  @override
  String get addIncomeCategoryNameLabel => 'Nama';

  @override
  String get addIncomeCategorySuccessMessage =>
      'Kategori pendapatan berhasil ditambahkan';

  @override
  String get addIncomeCategorySuccessTitle =>
      'Kategori pendapatan berhasil ditambahkan';

  @override
  String get addIncomeCategoryFailureTitle =>
      'Gagal menambahkan kategori pendapatan';

  @override
  String get addIncomeCategoryTitle => 'Tambah Kategori Pendapatan';

  @override
  String errorWalletNameAlreadyExists(String name) {
    return 'Dompet dengan nama $name sudah ada';
  }

  @override
  String errorCategoryAlreadyExists(String name) {
    return 'Kategori dengan nama $name sudah ada';
  }

  @override
  String get incomeCategoriesListFailureTitle =>
      'Gagal mendapatkan data kategori pendapatan';

  @override
  String get incomeCategoriesListLoadingSemantics =>
      'Memuat data kategori pendapatan';

  @override
  String get incomeCategoriesListTitle => 'Daftar Kategori Pendapatan';

  @override
  String get incomeCategoriesListSearchLabel => 'Cari Kategori Pendapatan';

  @override
  String get incomeCategoriesListEmptyDescription =>
      'Tidak ada data kategori pendapatan yang ditemukan';

  @override
  String get incomeCategoriesListAddButtonSemantics =>
      'Tambah Kategori Pendapatan';

  @override
  String deleteIncomeCategoryDialogTitle(String name) {
    return 'Hapus $name?';
  }

  @override
  String deleteIncomeCategoryDialogContent(String name) {
    return 'Data yang terikat dengan kategori pendapatan $name akan tetap ada. Tapi, kategori pendapatan $name tidak akan bisa digunakan lagi untuk data pendapatan selanjutnya';
  }

  @override
  String get deleteIncomeCategoryDialogConfirmLabel => 'Hapus';

  @override
  String deleteIncomeCategorySemantics(String name) {
    return 'Hapus $name';
  }

  @override
  String deleteIncomeCategoryDeletingSemanticsLabel(String name) {
    return 'Menghapus $name';
  }

  @override
  String deleteIncomeCategoryToastMessage(String name) {
    return '$name telah dihapus';
  }

  @override
  String updateIncomeCategorySemantics(String name) {
    return 'Perbarui $name';
  }

  @override
  String updateIncomeCategoryUpdatingSemanticsLabel(String name) {
    return 'Memperbarui $name';
  }

  @override
  String updateIncomeCategoryToastMessage(String name) {
    return '$name telah diperbarui';
  }

  @override
  String get deleteIncomeCategoryToastFailureTitle =>
      'Gagal menghapus kategori pendapatan';

  @override
  String get updateIncomeCategoryToastFailureTitle =>
      'Gagal memperbarui kategori pendapatan';

  @override
  String get addExpenseCategoryNameLabel => 'Nama';

  @override
  String get addExpenseCategorySuccessMessage =>
      'Kategori pengeluaran berhasil ditambahkan';

  @override
  String get addExpenseCategorySuccessTitle =>
      'Kategori pengeluaran berhasil ditambahkan';

  @override
  String get addExpenseCategoryFailureTitle =>
      'Gagal menambahkan kategori pengeluaran';

  @override
  String get addExpenseCategoryTitle => 'Tambah Kategori Pengeluaran';
}
