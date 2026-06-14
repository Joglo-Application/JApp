import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/owner/presentation/pages/owner_dashboard_page.dart';
import '../../features/owner/presentation/pages/owner_placeholder_page.dart';
import '../../features/owner/presentation/pages/owner_stok_gudang_page.dart';
import '../../features/owner/presentation/widgets/navigation/owner_drawer.dart';
import '../../features/pos/presentation/pages/inventori_page.dart';
import '../../features/pos/presentation/pages/pos_page.dart';
import '../../features/pos/presentation/pages/shift_kas_kasir_page.dart';
import '../../features/pos/presentation/pages/absensi_page.dart';
import '../../features/pos/presentation/pages/laporan_page.dart';
import '../../features/pos/presentation/pages/pengaturan_page.dart';
import '../../features/pos/presentation/pages/transaksi_page.dart';
import 'app_routes.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
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
      builder: (context, state) =>
          const OwnerPlaceholderPage(title: 'Kelola Stok'),
    ),
    GoRoute(
      path: AppRoutes.ownerLaporan,
      builder: (context, state) =>
          const OwnerPlaceholderPage(title: 'Laporan & Pembukuan'),
    ),
    GoRoute(
      path: AppRoutes.ownerTransaksi,
      builder: (context, state) =>
          const OwnerPlaceholderPage(title: 'Transaksi & Pembayaran'),
    ),
    GoRoute(
      path: AppRoutes.ownerPegawai,
      builder: (context, state) =>
          const OwnerPlaceholderPage(title: 'Pegawai'),
    ),
  ],
);
