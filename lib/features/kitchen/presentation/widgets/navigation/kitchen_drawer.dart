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

enum KitchenDrawerPage {
  dapur,
  transaksi,
  inventori,
  kelolaStok,
  stokGudang,
}

class KitchenDrawer extends StatelessWidget {
  const KitchenDrawer({super.key, this.activePage = KitchenDrawerPage.dapur});

  final KitchenDrawerPage activePage;

  @override
  Widget build(BuildContext context) {
    final name = context.select<AuthProvider, String>(
      (a) => a.user?.namaUser.isNotEmpty == true
          ? a.user!.namaUser
          : '[NAMA DAPUR]',
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
                  icon: Icons.circle,
                  label: 'Dapur',
                  active: activePage == KitchenDrawerPage.dapur,
                  onTap: () => _navigateTo(context, KitchenDrawerPage.dapur),
                ),
                AppDrawerItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Transaksi',
                  active: activePage == KitchenDrawerPage.transaksi,
                  onTap: () =>
                      _navigateTo(context, KitchenDrawerPage.transaksi),
                ),
                AppDrawerItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Inventori',
                  active: activePage == KitchenDrawerPage.inventori,
                  onTap: () =>
                      _navigateTo(context, KitchenDrawerPage.inventori),
                ),
                AppDrawerItem(
                  icon: Icons.add_box_rounded,
                  label: 'Kelola Stok',
                  active: activePage == KitchenDrawerPage.kelolaStok,
                  onTap: () =>
                      _navigateTo(context, KitchenDrawerPage.kelolaStok),
                ),
                AppDrawerItem(
                  icon: Icons.account_tree_rounded,
                  label: 'Stok Gudang',
                  active: activePage == KitchenDrawerPage.stokGudang,
                  onTap: () =>
                      _navigateTo(context, KitchenDrawerPage.stokGudang),
                ),
                AppDrawerSharedFooter(
                  absensiActive: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, KitchenDrawerPage destination) {
    Navigator.of(context).pop();
    if (activePage == destination) return;

    switch (destination) {
      case KitchenDrawerPage.dapur:
        context.go(AppRoutes.kitchenDapur);
      case KitchenDrawerPage.transaksi:
        context.push(AppRoutes.kitchenTransaksi);
      case KitchenDrawerPage.inventori:
        context.push(AppRoutes.kitchenInventori);
      case KitchenDrawerPage.kelolaStok:
        context.push(AppRoutes.kitchenKelolaStok);
      case KitchenDrawerPage.stokGudang:
        context.push(AppRoutes.kitchenStokGudang);
    }
  }
}
