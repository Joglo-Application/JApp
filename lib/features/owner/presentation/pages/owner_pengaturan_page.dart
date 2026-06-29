import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/navigation/owner_drawer.dart';

class OwnerPengaturanPage extends StatefulWidget {
  const OwnerPengaturanPage({super.key});

  @override
  State<OwnerPengaturanPage> createState() => _OwnerPengaturanPageState();
}

class _OwnerPengaturanPageState extends State<OwnerPengaturanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const OwnerDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const _AppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _NavSection(
                      title: 'Toko',
                      onTap: () => context.push(AppRoutes.ownerPengaturanToko),
                    ),
                    _NavSection(
                      title: 'Point of Sale',
                      onTap: () => context.push(AppRoutes.ownerPengaturanPos),
                    ),
                    _NavSection(
                      title: 'Pajak Toko',
                      onTap: () => context.push(AppRoutes.ownerPengaturanPajak),
                    ),
                    _NavSection(
                      title: 'Mata Uang Penjualan',
                      onTap: () =>
                              context.push(AppRoutes.ownerPengaturanMataUang),
                    ),
                    _NavSection(
                      title: 'Ringkasan Shift',
                      onTap: () => context
                          .push(AppRoutes.ownerPengaturanRingkasanShift),
                    ),
                    _NavSection(
                      title: 'Layout Toko',
                      onTap: () => context.push(AppRoutes.ownerPengaturanLayoutToko),
                    ),
                    _NavSection(
                      title: 'Notifikasi',
                      onTap: () => context.push(AppRoutes.ownerPengaturanNotifikasi),
                    ),
                    const SizedBox(height: AppSpacing.x6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        border: Border(bottom: BorderSide(color: AppColors.secondaryContainer)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            Material(
              color: AppColors.primary,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: InkWell(
                onTap: () => Scaffold.of(context).openDrawer(),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: const SizedBox(
                  width: 45,
                  height: 45,
                  child: Icon(
                    Icons.menu_rounded,
                    color: AppColors.onPrimary,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            Text(
              'Pengaturan',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.onSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nav section (top-level row that pushes a detail page) ────────────────────

class _NavSection extends StatelessWidget {
  const _NavSection({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x5,
            vertical: AppSpacing.x5,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.sm,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.onPrimary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
