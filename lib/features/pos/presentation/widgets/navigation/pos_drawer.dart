import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

/// Side navigation drawer for the cashier (kasir) role.
///
/// Opened from the hamburger button in [PosAppBar]. Only "Point of Sale" is
/// wired up today; the remaining destinations don't have pages yet, so they
/// show a "coming soon" notice. "Keluar" logs out and returns to login.
class PosDrawer extends StatelessWidget {
  const PosDrawer({super.key});

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
                  active: true,
                  onTap: () => Navigator.of(context).pop(),
                ),
                _DrawerItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Transaksi',
                  onTap: () => _soon(context, 'Transaksi'),
                ),
                _DrawerItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Inventori',
                  onTap: () => _soon(context, 'Inventori'),
                ),
                _DrawerItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Shift Kas Kasir',
                  onTap: () => _soon(context, 'Shift Kas Kasir'),
                ),
                const _DrawerDivider(),
                _DrawerItem(
                  icon: Icons.face_retouching_natural_rounded,
                  label: 'Absensi',
                  onTap: () => _soon(context, 'Absensi'),
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

  void _soon(BuildContext context, String label) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$label belum tersedia')),
      );
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
