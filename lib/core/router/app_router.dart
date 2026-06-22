import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/owner/presentation/pages/owner_dashboard_page.dart';
import '../../features/owner/presentation/pages/owner_laporan_page.dart';
import '../../features/owner/presentation/pages/owner_diskon_voucher_page.dart';
import '../../features/owner/presentation/pages/owner_edit_voucher_page.dart';
import '../../features/owner/presentation/pages/owner_loyalty_point_page.dart';
import '../../features/owner/presentation/pages/owner_tambah_loyalty_diskon_page.dart';
import '../../features/owner/presentation/pages/owner_tambah_loyalty_produk_gratis_page.dart';
import '../../features/owner/presentation/pages/owner_metode_pembayaran_page.dart';
import '../../features/owner/presentation/pages/owner_tambah_metode_pembayaran_page.dart';
import '../../features/owner/presentation/pages/owner_pegawai_page.dart';
import '../../features/owner/presentation/pages/owner_pengaturan_page.dart';
import '../../features/owner/presentation/pages/owner_pengaturan_toko_page.dart';
import '../../features/owner/presentation/pages/owner_pengaturan_pos_page.dart';
import '../../features/owner/presentation/pages/owner_pengaturan_pajak_page.dart';
import '../../features/owner/presentation/pages/owner_pilih_produk_page.dart';
import '../../features/owner/presentation/pages/owner_tambah_voucher_page.dart';
import '../../features/owner/presentation/pages/owner_transaksi_list_page.dart';
import '../../features/owner/presentation/pages/owner_transaksi_page.dart';
import '../../features/owner/presentation/pages/owner_kelola_stok_page.dart';
import '../../features/owner/presentation/pages/owner_stok_gudang_page.dart';
import '../../features/kitchen/presentation/pages/kitchen_dapur_page.dart';
import '../../features/kitchen/presentation/pages/kitchen_transaksi_page.dart';
import '../../features/kitchen/presentation/widgets/navigation/kitchen_drawer.dart';
import '../../features/owner/presentation/widgets/navigation/owner_drawer.dart';
import '../../features/pos/presentation/pages/inventori_page.dart';
import '../../features/pos/presentation/pages/inventori_pilih_bahan_page.dart';
import '../../features/pos/presentation/pages/inventori_tambah_produk_page.dart';
import '../../features/pos/presentation/pages/pos_page.dart';
import '../../features/pos/presentation/pages/shift_kas_kasir_page.dart';
import '../../features/pos/presentation/pages/absensi_page.dart';
import '../../features/pos/presentation/pages/laporan_page.dart';
import '../../features/pos/presentation/pages/pengaturan_page.dart';
import '../../features/pos/presentation/pages/transaksi_page.dart';
import 'app_routes.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.kitchenDapur,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const PosPage(),
    ),
    GoRoute(
      path: AppRoutes.transaksi,
      builder: (context, state) => const TransaksiPage(),
    ),
    GoRoute(
      path: AppRoutes.inventori,
      builder: (context, state) => const InventoriPage(),
    ),
    GoRoute(
      path: AppRoutes.shiftKas,
      builder: (context, state) => const ShiftKasKasirPage(),
    ),
    GoRoute(
      path: AppRoutes.laporan,
      builder: (context, state) => const LaporanPage(),
    ),
    GoRoute(
      path: AppRoutes.absensi,
      builder: (context, state) => const AbsensiPage(),
    ),
    GoRoute(
      path: AppRoutes.pengaturan,
      builder: (context, state) => const PengaturanPage(),
    ),

    // ── Owner ────────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.ownerDashboard,
      builder: (context, state) => const OwnerDashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerInventori,
      builder: (context, state) => const InventoriPage(
        drawer: OwnerDrawer(activePage: OwnerDrawerPage.inventori),
      ),
    ),
    GoRoute(
      path: AppRoutes.ownerStokGudang,
      builder: (context, state) => const OwnerStokGudangPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerKelolaStok,
      builder: (context, state) => const OwnerKelolaStokPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerLaporan,
      builder: (context, state) => const OwnerLaporanPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerTransaksi,
      builder: (context, state) => const OwnerTransaksiPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerTransaksiList,
      builder: (context, state) => const OwnerTransaksiListPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerDiskonVoucher,
      builder: (context, state) => const OwnerDiskonVoucherPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerTambahVoucher,
      builder: (context, state) => const OwnerTambahVoucherPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerEditVoucher,
      builder: (context, state) => OwnerEditVoucherPage(
        args: state.extra as VoucherEditArgs,
      ),
    ),
    GoRoute(
      path: AppRoutes.ownerLoyaltyPoint,
      builder: (context, state) => const OwnerLoyaltyPointPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerTambahLoyaltyDiskon,
      builder: (context, state) => const OwnerTambahLoyaltyDiskonPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerTambahLoyaltyProdukGratis,
      builder: (context, state) => const OwnerTambahLoyaltyProdukGratisPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerMetodePembayaran,
      builder: (context, state) => const OwnerMetodePembayaranPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerTambahMetodePembayaran,
      builder: (context, state) => const OwnerTambahMetodePembayaranPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerPilihProduk,
      builder: (context, state) => const OwnerPilihProdukPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerPegawai,
      builder: (context, state) => const OwnerPegawaiPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerPengaturan,
      builder: (context, state) => const OwnerPengaturanPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerPengaturanToko,
      builder: (context, state) => const OwnerPengaturanTokoPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerPengaturanPos,
      builder: (context, state) => const OwnerPengaturanPosPage(),
    ),
    GoRoute(
      path: AppRoutes.ownerPengaturanPajak,
      builder: (context, state) => const OwnerPengaturanPajakPage(),
    ),

    // ── Kitchen ──────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.kitchenDapur,
      builder: (context, state) => const KitchenDapurPage(),
    ),
    GoRoute(
      path: AppRoutes.kitchenTransaksi,
      builder: (context, state) => const KitchenTransaksiPage(),
    ),
    GoRoute(
      path: AppRoutes.kitchenInventori,
      builder: (context, state) => const InventoriPage(
        drawer: KitchenDrawer(activePage: KitchenDrawerPage.inventori),
      ),
    ),
    GoRoute(
      path: AppRoutes.kitchenKelolaStok,
      builder: (context, state) => const OwnerKelolaStokPage(
        drawer: KitchenDrawer(activePage: KitchenDrawerPage.kelolaStok),
      ),
    ),
    GoRoute(
      path: AppRoutes.kitchenStokGudang,
      builder: (context, state) => const OwnerStokGudangPage(
        drawer: KitchenDrawer(activePage: KitchenDrawerPage.stokGudang),
      ),
    ),

    // ── Shared ───────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.inventoriTambahProduk,
      builder: (context, state) => const InventoriTambahProdukPage(),
    ),
    GoRoute(
      path: AppRoutes.inventoriPilihBahan,
      builder: (context, state) => const InventoriPilihBahanPage(),
    ),
  ],
);
