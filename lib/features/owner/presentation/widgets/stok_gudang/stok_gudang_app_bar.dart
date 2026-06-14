import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../providers/stok_gudang_provider.dart';

class StokGudangAppBar extends StatelessWidget {
  const StokGudangAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final kategoriFilter = context.select<StokGudangProvider, String?>(
      (p) => p.kategoriFilter,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        border: Border(bottom: BorderSide(color: AppColors.secondaryContainer)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x3,
          ),
          child: Row(
            children: [
              _HamburgerButton(),
              const SizedBox(width: AppSpacing.x3),
              Text(
                'Stok Gudang',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _KategoriButton(
                label: kategoriFilter ?? 'Semua Produk',
                onTap: () => _showKategoriPicker(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showKategoriPicker(BuildContext context) {
    final provider = context.read<StokGudangProvider>();
    showDialog<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const _KategoriPickerDialog(),
      ),
    );
  }
}

class _HamburgerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: () => Scaffold.of(context).openDrawer(),
        borderRadius: AppRadius.md,
        child: const SizedBox(
          width: 45,
          height: 45,
          child: Icon(Icons.menu_rounded, color: AppColors.onPrimary, size: 28),
        ),
      ),
    );
  }
}

class _KategoriButton extends StatelessWidget {
  const _KategoriButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppSpacing.x1),
          const Icon(
            Icons.sort_rounded,
            color: AppColors.onSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ── Kategori picker dialog ────────────────────────────────────────────────────

class _KategoriPickerDialog extends StatelessWidget {
  const _KategoriPickerDialog();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StokGudangProvider>();
    final kategoriList = provider.availableKategori.toList()..sort();
    final selected = provider.kategoriFilter;

    return Dialog(
      backgroundColor: AppColors.primary,
      shape: AppRadius.toShape(AppRadius.lg),
      child: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x4,
                AppSpacing.x4,
                AppSpacing.x2,
                AppSpacing.x4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Kategori Stok',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.onPrimary,
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.55,
              ),
              child: ListView(
                padding: const EdgeInsets.only(bottom: AppSpacing.x4),
                shrinkWrap: true,
                children: [
                  _KategoriTile(
                    label: '[Semua Produk]',
                    isSelected: selected == null,
                    onTap: () {
                      provider.setKategoriFilter(null);
                      Navigator.of(context).pop();
                    },
                  ),
                  ...kategoriList.map(
                    (k) => _KategoriTile(
                      label: k,
                      isSelected: selected == k,
                      onTap: () {
                        provider.setKategoriFilter(k);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KategoriTile extends StatelessWidget {
  const _KategoriTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected
            ? AppColors.onPrimary.withValues(alpha: 0.15)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded,
                  size: 18, color: AppColors.onPrimary),
          ],
        ),
      ),
    );
  }
}
