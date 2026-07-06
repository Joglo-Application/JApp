import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../router/app_routes.dart';
import 'app_drawer_divider.dart';
import 'app_drawer_item.dart';
import 'ganti_role_sheet.dart';

/// Role-agnostic bottom section shown in every app drawer.
/// Includes: Absensi · Pengaturan · Ganti Role · Keluar.
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
          icon: Icons.switch_account_rounded,
          label: 'Ganti Role',
          onTap: () => _showGantiRole(context),
        ),
        AppDrawerItem(
          icon: Icons.logout_rounded,
          label: 'Keluar',
          onTap: () => _logout(context),
        ),
      ],
    );
  }

  void _showGantiRole(BuildContext context) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    GantiRoleSheet.show(
      context,
      // TODO: replace with real API accounts
      accounts: const [
        GantiRoleAccount(namaUser: 'Supervisor01', roleCode: 'SPV1'),
        GantiRoleAccount(namaUser: 'Kasir01', roleCode: 'KASIR01'),
        GantiRoleAccount(namaUser: 'Dapur01', roleCode: 'DAPUR01'),
        GantiRoleAccount(namaUser: 'Gudang01', roleCode: 'GUDANG01'),
        GantiRoleAccount(namaUser: 'Owner01', roleCode: 'OWNER01'),
      ],
      onSelect: (account) {
        final route = switch (account.roleCode) {
          'SPV1' || 'KASIR01' => AppRoutes.pos,
          'DAPUR01' => AppRoutes.kitchenDapur,
          'OWNER01' => AppRoutes.ownerDashboard,
          'GUDANG01' => AppRoutes.supplierGudang,
          _ => null,
        };
        if (route != null) router.go(route);
      },
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
