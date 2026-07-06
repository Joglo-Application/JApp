abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String pos = '/pos';
  static const String transaksi = '/transaksi';
  static const String inventori = '/inventori';
  static const String shiftKas = '/shift-kas';
  static const String laporan = '/laporan';
  static const String absensi = '/absensi';
  static const String pengaturan = '/pengaturan';

  // ── Owner ─────────────────────────────────────────────────────────────────
  static const String ownerDashboard = '/owner/dashboard';
  static const String ownerInventori = '/owner/inventori';
  static const String ownerStokGudang = '/owner/stok-gudang';
  static const String ownerKelolaStok = '/owner/kelola-stok';
  static const String ownerLaporan = '/owner/laporan';
  static const String ownerTransaksi = '/owner/transaksi';
  static const String ownerTransaksiList = '/owner/transaksi/list';
  static const String ownerDiskonVoucher = '/owner/transaksi/diskon-voucher';
  static const String ownerTambahVoucher = '/owner/transaksi/diskon-voucher/tambah';
  static const String ownerEditVoucher = '/owner/transaksi/diskon-voucher/edit';
  static const String ownerLoyaltyPoint = '/owner/transaksi/loyalty-point';
  static const String ownerTambahLoyaltyDiskon = '/owner/transaksi/loyalty-point/tambah-diskon';
  static const String ownerTambahLoyaltyProdukGratis = '/owner/transaksi/loyalty-point/tambah-produk-gratis';
  static const String ownerMetodePembayaran = '/owner/transaksi/metode-pembayaran';
  static const String ownerTambahMetodePembayaran = '/owner/transaksi/metode-pembayaran/tambah';
  static const String ownerPilihProduk = '/owner/pilih-produk';
  static const String ownerPegawai = '/owner/pegawai';
  static const String ownerPengaturan = '/owner/pengaturan';
  static const String ownerPengaturanToko = '/owner/pengaturan/toko';
  static const String ownerPengaturanPos = '/owner/pengaturan/pos';
  static const String ownerPengaturanPajak = '/owner/pengaturan/pajak';
  static const String ownerPengaturanMataUang = '/owner/pengaturan/mata-uang';
  static const String ownerPengaturanRingkasanShift =
      '/owner/pengaturan/ringkasan-shift';
  static const String ownerPengaturanLayoutToko =
      '/owner/pengaturan/layout-toko';
  static const String ownerPengaturanLayoutTokoEdit =
      '/owner/pengaturan/layout-toko/edit';
  static const String ownerPengaturanNotifikasi =
      '/owner/pengaturan/notifikasi';

  // ── Kitchen ───────────────────────────────────────────────────────────────
  static const String kitchenDapur = '/kitchen/dapur';
  static const String kitchenTransaksi = '/kitchen/transaksi';
  static const String kitchenInventori = '/kitchen/inventori';
  static const String kitchenKelolaStok = '/kitchen/kelola-stok';
  static const String kitchenStokGudang = '/kitchen/stok-gudang';

  // ── Supplier ──────────────────────────────────────────────────────────────
  static const String supplierGudang = '/supplier/gudang';
  static const String supplierInventori = '/supplier/inventori';
  static const String supplierStokGudang = '/supplier/stok-gudang';
  static const String supplierKategoriStokGudang = '/supplier/kategori-stok-gudang';

  // ── Shared ────────────────────────────────────────────────────────────────
  static const String inventoriTambahProduk = '/inventori/tambah-produk';
  static const String inventoriEditItem = '/inventori/edit-item';
  static const String inventoriPilihBahan = '/inventori/pilih-bahan';
}
