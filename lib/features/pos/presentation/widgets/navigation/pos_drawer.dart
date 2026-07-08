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

enum PosDrawerPage { pos, transaksi, inventori, shiftKas, absensi }

class PosDrawer extends StatelessWidget {
  const PosDrawer({super.key, this.activePage = PosDrawerPage.pos});

  final PosDrawerPage activePage;

  @override
  Widget build(BuildContext context) {
    final name = context.select<AuthProvider, String>(
      (a) => a.user?.namaUser.isNotEmpty == true
          ? a.user!.namaUser
          : '[NAMA KASIR]',
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
                  label: 'Point of Sale',
                  active: activePage == PosDrawerPage.pos,
                  onTap: () => _navigateTo(context, PosDrawerPage.pos),
                ),
                AppDrawerItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Transaksi',
                  active: activePage == PosDrawerPage.transaksi,
                  onTap: () => _navigateTo(context, PosDrawerPage.transaksi),
                ),
                AppDrawerItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Inventori',
                  active: activePage == PosDrawerPage.inventori,
                  onTap: () => _navigateTo(context, PosDrawerPage.inventori),
                ),
                AppDrawerItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Shift Kas Kasir',
                  active: activePage == PosDrawerPage.shiftKas,
                  onTap: () => _navigateTo(context, PosDrawerPage.shiftKas),
                ),
                AppDrawerSharedFooter(
                  absensiActive: activePage == PosDrawerPage.absensi,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, PosDrawerPage destination) {
    Navigator.of(context).pop(); // close drawer
    if (activePage == destination) return; // already here

    switch (destination) {
      case PosDrawerPage.pos:
        context.go(AppRoutes.pos);
      case PosDrawerPage.transaksi:
        context.go(AppRoutes.transaksi);
      case PosDrawerPage.inventori:
        context.go(AppRoutes.inventori);
      case PosDrawerPage.shiftKas:
        context.go(AppRoutes.shiftKas);
      case PosDrawerPage.absensi:
        // handled by AppDrawerSharedFooter
        break;
    }
  }
}
