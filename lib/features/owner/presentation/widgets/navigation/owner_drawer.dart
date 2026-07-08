import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/drawer/app_drawer_divider.dart';
import '../../../../../core/widgets/drawer/app_drawer_item.dart';
import '../../../../../core/widgets/drawer/app_drawer_user_header.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

enum OwnerDrawerPage {
  dashboard,
  inventori,
  stokGudang,
  kelolaStok,
  laporan,
  transaksi,
  pegawai,
}

class OwnerDrawer extends StatelessWidget {
  const OwnerDrawer({super.key, this.activePage = OwnerDrawerPage.dashboard});

  final OwnerDrawerPage activePage;

  @override
  Widget build(BuildContext context) {
    final name = context.select<AuthProvider, String>(
      (a) => a.user?.namaUser.isNotEmpty == true
          ? a.user!.namaUser
          : '[NAMA OWNER]',
    );

    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppDrawerUserHeader(name: name),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.x2),
              children: [
                AppDrawerItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  active: activePage == OwnerDrawerPage.dashboard,
                  onTap: () => _navigateTo(context, OwnerDrawerPage.dashboard),
                ),
                AppDrawerItem(
                  icon: Icons.desktop_windows_rounded,
                  label: 'Inventori',
                  active: activePage == OwnerDrawerPage.inventori,
                  onTap: () => _navigateTo(context, OwnerDrawerPage.inventori),
                ),
                AppDrawerItem(
                  icon: Icons.account_tree_rounded,
                  label: 'Stok Gudang',
                  active: activePage == OwnerDrawerPage.stokGudang,
                  onTap: () => _navigateTo(context, OwnerDrawerPage.stokGudang),
                ),
                AppDrawerItem(
                  icon: Icons.add_box_rounded,
                  label: 'Kelola Stok',
                  active: activePage == OwnerDrawerPage.kelolaStok,
                  onTap: () => _navigateTo(context, OwnerDrawerPage.kelolaStok),
                ),
                AppDrawerItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Laporan & Pembukuan',
                  active: activePage == OwnerDrawerPage.laporan,
                  onTap: () => _navigateTo(context, OwnerDrawerPage.laporan),
                ),
                AppDrawerItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Transaksi & Pembayaran',
                  active: activePage == OwnerDrawerPage.transaksi,
                  onTap: () => _navigateTo(context, OwnerDrawerPage.transaksi),
                ),
                AppDrawerItem(
                  icon: Icons.person_rounded,
                  label: 'Pegawai',
                  active: activePage == OwnerDrawerPage.pegawai,
                  onTap: () => _navigateTo(context, OwnerDrawerPage.pegawai),
                ),
                const AppDrawerDivider(),
                AppDrawerItem(
                  icon: Icons.settings_rounded,
                  label: 'Pengaturan',
                  onTap: () => _navigatePengaturan(context),
                ),
                AppDrawerItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Pusat Bantuan',
                  onTap: () {},
                ),
                const AppDrawerDivider(),
                AppDrawerItem(
                  icon: Icons.logout_rounded,
                  label: 'Keluar',
                  onTap: () => _logout(context),
                ),
                AppDrawerItem(
                  icon: Icons.info_outline_rounded,
                  label: 'App Version',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, OwnerDrawerPage destination) {
    Navigator.of(context).pop();
    if (activePage == destination) return;

    switch (destination) {
      case OwnerDrawerPage.dashboard:
        context.go(AppRoutes.ownerDashboard);
      case OwnerDrawerPage.inventori:
        context.go(AppRoutes.ownerInventori);
      case OwnerDrawerPage.stokGudang:
        context.go(AppRoutes.ownerStokGudang);
      case OwnerDrawerPage.kelolaStok:
        context.go(AppRoutes.ownerKelolaStok);
      case OwnerDrawerPage.laporan:
        context.go(AppRoutes.ownerLaporan);
      case OwnerDrawerPage.transaksi:
        context.go(AppRoutes.ownerTransaksi);
      case OwnerDrawerPage.pegawai:
        context.go(AppRoutes.ownerPegawai);
    }
  }

  void _navigatePengaturan(BuildContext context) {
    Navigator.of(context).pop();
    context.go(AppRoutes.ownerPengaturan);
  }

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    await auth.logout();
    router.go(AppRoutes.login);
  }

}
