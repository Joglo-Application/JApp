import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PengaturanPage extends StatelessWidget {
  const PengaturanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
        title: Text(
          'Pengaturan',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.onSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const _Section(title: 'Printer'),
                _AddDeviceTile(
                  label: 'Tambahkan Printer',
                  subtitle: 'Tambahkan Printer disini',
                  onTap: () {},
                ),
                const _Section(title: 'Perangkat EDC'),
                _EdcTile(
                  name: 'EDC BCA',
                  tipeKoneksi: 'Tipe koneksi',
                  alamat: 'Alamat',
                  onTap: () {},
                ),
                const _Section(title: 'Support'),
                _SupportTile(
                  label: 'Hubungi Kami',
                  onTap: () {},
                ),
                _SupportTile(
                  label: 'Versi Aplikasi',
                  onTap: () {},
                ),
              ],
            ),
          ),
          _LogoutButton(
            onTap: () async {
              final auth = context.read<AuthProvider>();
              final router = GoRouter.of(context);
              await auth.logout();
              router.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x5,
            AppSpacing.x6,
            AppSpacing.x5,
            AppSpacing.x3,
          ),
          child: Text(
            title,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.outlineVariant,
        ),
      ],
    );
  }
}

// ── Add device tile ────────────────────────────────────────────────────────

class _AddDeviceTile extends StatelessWidget {
  const _AddDeviceTile({
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x5,
          vertical: AppSpacing.x4,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.x4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ── EDC device tile ────────────────────────────────────────────────────────

class _EdcTile extends StatelessWidget {
  const _EdcTile({
    required this.name,
    required this.tipeKoneksi,
    required this.alamat,
    required this.onTap,
  });

  final String name;
  final String tipeKoneksi;
  final String alamat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x5,
          vertical: AppSpacing.x4,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tipeKoneksi,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    alamat,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Support tile ───────────────────────────────────────────────────────────

class _SupportTile extends StatelessWidget {
  const _SupportTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x5,
          vertical: AppSpacing.x4,
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

// ── Logout button ──────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x5),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.x2),
              ),
            ),
            child: Text(
              'Keluar',
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: AppColors.onError,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
