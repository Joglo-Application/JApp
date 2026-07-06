import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/drawer/app_drawer_item.dart';
import '../../../../../core/widgets/drawer/app_drawer_shared_footer.dart';
import '../../../../../core/widgets/drawer/app_drawer_user_header.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

enum SpvDrawerPage {
  transaksi,
  inventori,
  stokGudang,
  shiftKas,
  laporan,
  absensiKaryawan,
  absensi,
}

class SpvDrawer extends StatelessWidget {
  const SpvDrawer({super.key, this.activePage});

  /// Null when the current page has no drawer item (e.g. landing on POS).
  final SpvDrawerPage? activePage;

  @override
  Widget build(BuildContext context) {
    final name = context.select<AuthProvider, String>(
      (a) => a.user?.namaUser.isNotEmpty == true
          ? a.user!.namaUser
          : '[NAMA SPV/MANAGER]',
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
                  icon: Icons.receipt_long_rounded,
                  label: 'Transaksi',
                  active: activePage == SpvDrawerPage.transaksi,
                  onTap: () => _navigateTo(context, SpvDrawerPage.transaksi),
                ),
                AppDrawerItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Inventori',
                  active: activePage == SpvDrawerPage.inventori,
                  onTap: () => _navigateTo(context, SpvDrawerPage.inventori),
                ),
                AppDrawerItem(
                  icon: Icons.account_tree_rounded,
                  label: 'Stok Gudang',
                  active: activePage == SpvDrawerPage.stokGudang,
                  onTap: () => _navigateTo(context, SpvDrawerPage.stokGudang),
                ),
                AppDrawerItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Shift Kas Kasir',
                  active: activePage == SpvDrawerPage.shiftKas,
                  onTap: () => _navigateTo(context, SpvDrawerPage.shiftKas),
                ),
                AppDrawerItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Laporan',
                  active: activePage == SpvDrawerPage.laporan,
                  onTap: () => _navigateTo(context, SpvDrawerPage.laporan),
                ),
                AppDrawerSharedFooter(
                  absensiActive: activePage == SpvDrawerPage.absensi,
                  leadingItems: [
                    AppDrawerItem(
                      icon: Icons.account_circle_rounded,
                      label: 'Absensi Karyawan',
                      active: activePage == SpvDrawerPage.absensiKaryawan,
                      onTap: () =>
                          _navigateTo(context, SpvDrawerPage.absensiKaryawan),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, SpvDrawerPage destination) {
    Navigator.of(context).pop(); // close drawer
    if (activePage == destination) return; // already here

    switch (destination) {
      case SpvDrawerPage.transaksi:
        context.go(AppRoutes.spvTransaksi);
      case SpvDrawerPage.inventori:
        context.go(AppRoutes.spvInventori);
      case SpvDrawerPage.stokGudang:
        context.go(AppRoutes.spvStokGudang);
      case SpvDrawerPage.shiftKas:
        context.go(AppRoutes.spvShiftKas);
      case SpvDrawerPage.laporan:
        context.go(AppRoutes.spvLaporan);
      case SpvDrawerPage.absensiKaryawan:
        context.go(AppRoutes.spvAbsensiKaryawan);
      case SpvDrawerPage.absensi:
        // handled by AppDrawerSharedFooter
        break;
    }
  }
}
