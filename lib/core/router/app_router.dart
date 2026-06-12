import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/pos/presentation/pages/inventori_page.dart';
import '../../features/pos/presentation/pages/pos_page.dart';
import '../../features/pos/presentation/pages/shift_kas_kasir_page.dart';
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
  ],
);
