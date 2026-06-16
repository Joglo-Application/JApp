import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'owner_pengaturan_layout_toko_edit_page.dart';

/// "Denah Restoran" — owner-managed list of floor layouts (Lantai 1, Lantai 2,
/// Outdoor, etc.), each holding its own set of tables. Tapping "Tambah" or a
/// card's "Edit" link pushes [OwnerPengaturanLayoutTokoEditPage] and applies
/// whatever [LayoutTokoEditResult] comes back.
class OwnerPengaturanLayoutTokoPage extends StatefulWidget {
  const OwnerPengaturanLayoutTokoPage({super.key});

  @override
  State<OwnerPengaturanLayoutTokoPage> createState() =>
      _OwnerPengaturanLayoutTokoPageState();
}

class _OwnerPengaturanLayoutTokoPageState
    extends State<OwnerPengaturanLayoutTokoPage> {
  final List<LayoutTokoData> _layouts = [
    const LayoutTokoData(
      nama: 'Lantai 1',
      meja: ['01', '02', '03', '04', '05', '06', 'Lesehan 01', 'Taman 01'],
    ),
    const LayoutTokoData(nama: 'Lantai 2', meja: ['07', '08', '09', '10']),
    const LayoutTokoData(
      nama: 'Lantai 3',
      meja: ['11', '12', '13', '14', '15'],
    ),
    const LayoutTokoData(
      nama: 'Outdoor',
      meja: ['Outdoor 1', 'Outdoor 2', 'Outdoor 3', 'Outdoor 4'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.outlineVariant,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.x4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Denah Restoran',
                          style: AppTypography.textTheme.titleSmall?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        _TambahButton(onTap: _onTambahLayout),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    for (var i = 0; i < _layouts.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.x3),
                      _LayoutCard(
                        data: _layouts[i],
                        onEdit: () => _onEditLayout(i),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Layout Toko',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          InkWell(
            onTap: () => context.pop(),
            borderRadius: AppRadius.full,
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onTambahLayout() async {
    final result = await context.push<LayoutTokoEditResult>(
      AppRoutes.ownerPengaturanLayoutTokoEdit,
    );
    if (result == null || result.data == null || !mounted) return;
    setState(() => _layouts.add(result.data!));
  }

  Future<void> _onEditLayout(int index) async {
    final result = await context.push<LayoutTokoEditResult>(
      AppRoutes.ownerPengaturanLayoutTokoEdit,
      extra: _layouts[index],
    );
    if (result == null || !mounted) return;
    setState(() {
      if (result.deleted) {
        _layouts.removeAt(index);
      } else if (result.data != null) {
        _layouts[index] = result.data!;
      }
    });
  }
}

// ── Tambah button ────────────────────────────────────────────────────────────

class _TambahButton extends StatelessWidget {
  const _TambahButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.sm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.sm,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x5,
            vertical: AppSpacing.x3,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: AppColors.onPrimary, size: 20),
              const SizedBox(width: AppSpacing.x1),
              Text(
                'Tambah',
                style: AppTypography.textTheme.labelLarge?.copyWith(
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

// ── Layout card ──────────────────────────────────────────────────────────────

class _LayoutCard extends StatelessWidget {
  const _LayoutCard({required this.data, required this.onEdit});

  final LayoutTokoData data;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x4,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: AppRadius.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.nama,
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.x1),
                Text(
                  data.meja.join(',  '),
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          GestureDetector(
            onTap: onEdit,
            child: Text(
              'Edit',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
