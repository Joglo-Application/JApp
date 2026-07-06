import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/router/app_routes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/widgets/drawer/app_drawer_item.dart';
import '../../../../../../core/widgets/drawer/app_drawer_shared_footer.dart';
import '../../../../../../core/widgets/drawer/app_drawer_user_header.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

enum SupplierDrawerPage {
  gudangSupplier,
  inventori,
  stokGudang,
  kategoriStokGudang,
}

class SupplierDrawer extends StatelessWidget {
  const SupplierDrawer({
    super.key,
    this.activePage = SupplierDrawerPage.gudangSupplier,
  });

  final SupplierDrawerPage activePage;

  @override
  Widget build(BuildContext context) {
    final name = context.select<AuthProvider, String>(
      (a) => a.user?.namaUser.isNotEmpty == true
          ? a.user!.namaUser
          : '[NAMA GUDANG/SUPPLIER]',
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
                  label: 'Gudang / Supplier',
                  active: activePage == SupplierDrawerPage.gudangSupplier,
                  onTap: () => _navigateTo(context, SupplierDrawerPage.gudangSupplier),
                ),
                AppDrawerItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Inventori',
                  active: activePage == SupplierDrawerPage.inventori,
                  onTap: () => _navigateTo(context, SupplierDrawerPage.inventori),
                ),
                AppDrawerItem(
                  icon: Icons.account_tree_rounded,
                  label: 'Stok Gudang',
                  active: activePage == SupplierDrawerPage.stokGudang,
                  onTap: () => _navigateTo(context, SupplierDrawerPage.stokGudang),
                ),
                AppDrawerItem(
                  icon: Icons.format_list_bulleted_rounded,
                  label: 'Kategori Stok Gudang',
                  active: activePage == SupplierDrawerPage.kategoriStokGudang,
                  onTap: () => _navigateTo(context, SupplierDrawerPage.kategoriStokGudang),
                ),
                AppDrawerSharedFooter(absensiActive: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, SupplierDrawerPage destination) {
    Navigator.of(context).pop();
    if (activePage == destination) return;

    switch (destination) {
      case SupplierDrawerPage.gudangSupplier:
        context.go(AppRoutes.supplierGudang);
      case SupplierDrawerPage.inventori:
        context.go(AppRoutes.supplierInventori);
      case SupplierDrawerPage.stokGudang:
        context.go(AppRoutes.supplierStokGudang);
      case SupplierDrawerPage.kategoriStokGudang:
        context.go(AppRoutes.supplierKategoriStokGudang);
    }
  }
}
