import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/pos/presentation/providers/menu_provider.dart';
import 'features/pos/presentation/providers/order_provider.dart';
import 'features/pos/presentation/providers/pos_ui_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // On any 401 the token is cleared; send the user back to login.
  ApiClient.instance.onUnauthorized = () => appRouter.go(AppRoutes.login);

  runApp(
    MultiProvider(
      providers: [
        // Eager: bootstrap sesi jalan saat app start (bukan menunggu diakses),
        // agar user tersedia walau masuk lewat deep-link/refresh di web.
        ChangeNotifierProvider(create: (_) => AuthProvider(), lazy: false),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => PosUiProvider()),
      ],
      child: const JApp(),
    ),
  );
}

class JApp extends StatelessWidget {
  const JApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Dashboard',
          style: AppTypography.textTheme.headlineMedium?.copyWith(
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}
