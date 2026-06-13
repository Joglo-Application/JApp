import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

enum PosDrawerPage { pos, transaksi, inventori, shiftKas, laporan, absensi }

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
          _DrawerHeader(name: name),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.x2),
              children: [
                _DrawerItem(
                  icon: Icons.circle,
                  label: 'Point of Sale',
                  active: activePage == PosDrawerPage.pos,
                  onTap: () => _navigateTo(context, PosDrawerPage.pos),
                ),
                _DrawerItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Transaksi',
                  active: activePage == PosDrawerPage.transaksi,
                  onTap: () => _navigateTo(context, PosDrawerPage.transaksi),
                ),
                _DrawerItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Inventori',
                  active: activePage == PosDrawerPage.inventori,
                  onTap: () => _navigateTo(context, PosDrawerPage.inventori),
                ),
                _DrawerItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Shift Kas Kasir',
                  active: activePage == PosDrawerPage.shiftKas,
                  onTap: () => _navigateTo(context, PosDrawerPage.shiftKas),
                ),
                //# ADD VALUE ROLE FROM DATABASE
                _DrawerItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Laporan',
                  active: activePage == PosDrawerPage.laporan,
                  onTap: () => _navigateTo(context, PosDrawerPage.laporan),
                ),
                const _DrawerDivider(),
                _DrawerItem(
                  icon: Icons.face_retouching_natural_rounded,
                  label: 'Absensi',
                  active: activePage == PosDrawerPage.absensi,
                  onTap: () => _navigateTo(context, PosDrawerPage.absensi),
                ),
                _DrawerItem(
                  icon: Icons.settings_rounded,
                  label: 'Pengaturan',
                  onTap: () => _soon(context, 'Pengaturan'),
                ),
                _DrawerItem(
                  icon: Icons.switch_account_rounded,
                  label: 'Ganti Role',
                  onTap: () => _soon(context, 'Ganti Role'),
                ),
                _DrawerItem(
                  icon: Icons.logout_rounded,
                  label: 'Keluar',
                  onTap: () => _logout(context),
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
        context.pop(); // go back to home in GoRouter stack
      case PosDrawerPage.transaksi:
        context.push(AppRoutes.transaksi);
      case PosDrawerPage.inventori:
        context.push(AppRoutes.inventori);
      case PosDrawerPage.shiftKas:
        context.push(AppRoutes.shiftKas);
      case PosDrawerPage.laporan:
        context.push(AppRoutes.laporan);
      case PosDrawerPage.absensi:
        context.push(AppRoutes.absensi);
    }
  }

  void _soon(BuildContext context, String label) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label belum tersedia')));
  }

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    await auth.logout();
    router.go(AppRoutes.login);
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x5,
            AppSpacing.x6,
            AppSpacing.x5,
            AppSpacing.x4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.onPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.x4),
              Text(
                name,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Items ─────────────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final iconColor = active ? AppColors.primary : AppColors.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x5,
          vertical: AppSpacing.x4,
        ),
        child: Row(
          children: [
            // Fixed-width slot keeps every label left-aligned, even though the
            // active "dot" icon is smaller than the regular icons.
            SizedBox(
              width: 24,
              child: Center(
                child: Icon(icon, size: active ? 18 : 24, color: iconColor),
              ),
            ),
            const SizedBox(width: AppSpacing.x4),
            Text(
              label,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.x5,
        vertical: AppSpacing.x2,
      ),
      child: Divider(color: AppColors.primary, thickness: 1, height: 1),
    );
  }
}
