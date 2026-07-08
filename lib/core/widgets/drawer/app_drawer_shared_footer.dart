import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../router/app_routes.dart';
import 'app_drawer_divider.dart';
import 'app_drawer_item.dart';

/// Role-agnostic bottom section shown in every app drawer.
/// Includes: Absensi · Pengaturan · Keluar.
class AppDrawerSharedFooter extends StatelessWidget {
  const AppDrawerSharedFooter({
    super.key,
    this.absensiActive = false,
    this.leadingItems = const [],
  });

  final bool absensiActive;

  /// Role-specific items rendered between the divider and Absensi
  /// (e.g. SPV's "Absensi Karyawan").
  final List<Widget> leadingItems;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppDrawerDivider(),
        ...leadingItems,
        AppDrawerItem(
          icon: Icons.face_retouching_natural_rounded,
          label: 'Absensi',
          active: absensiActive,
          onTap: () => _navigateAbsensi(context),
        ),
        AppDrawerItem(
          icon: Icons.settings_rounded,
          label: 'Pengaturan',
          onTap: () => _navigatePengaturan(context),
        ),
        AppDrawerItem(
          icon: Icons.logout_rounded,
          label: 'Keluar',
          onTap: () => _logout(context),
        ),
      ],
    );
  }

  void _navigatePengaturan(BuildContext context) {
    Navigator.of(context).pop();
    context.go(AppRoutes.pengaturan);
  }

  void _navigateAbsensi(BuildContext context) {
    Navigator.of(context).pop();
    if (!absensiActive) context.go(AppRoutes.absensi);
  }

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    await auth.logout();
    router.go(AppRoutes.login);
  }
}
