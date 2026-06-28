import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/app_search_field.dart';
import '../../providers/inventori_provider.dart';

class InventoriFilterBar extends StatefulWidget {
  const InventoriFilterBar({super.key});

  @override
  State<InventoriFilterBar> createState() => _InventoriFilterBarState();
}

class _InventoriFilterBarState extends State<InventoriFilterBar> {
  bool _isSearching = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    _searchCtrl.clear();
    context.read<InventoriProvider>().search('');
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoriProvider>();
    final displayLabel = switch (provider.statusFilter) {
      InventoriStatusFilter.peringatanStok => 'Peringatan Stok',
      InventoriStatusFilter.tidakAdaStok => 'Tidak ada Stok',
      null => provider.kategoriFilter ?? 'Semua Kategori',
    };

    return ColoredBox(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2,
        ),
        child: _isSearching
            ? _SearchRow(
                controller: _searchCtrl,
                onStop: _stopSearch,
                onChanged: (q) => context.read<InventoriProvider>().search(q),
              )
            : _FilterRow(
                activeLabel: displayLabel,
                onSearchTap: _startSearch,
                onFilterTap: () => _showKategoriPicker(context),
              ),
      ),
    );
  }

  void _showKategoriPicker(BuildContext context) {
    final provider = context.read<InventoriProvider>();
    showDialog<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const _KategoriPickerDialog(),
      ),
    );
  }
}

// ── Filter row (default state) ─────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.activeLabel,
    required this.onSearchTap,
    required this.onFilterTap,
  });

  final String activeLabel;
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onSearchTap,
          child: const Icon(Icons.search_rounded,
              color: AppColors.onPrimary, size: 22),
        ),
        Expanded(
          child: Text(
            activeLabel,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        GestureDetector(
          onTap: onFilterTap,
          child: const Icon(Icons.filter_list_rounded,
              color: AppColors.onPrimary, size: 22),
        ),
      ],
    );
  }
}

// ── Search row (active search state) ─────────────────────────────────────────

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.onStop,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onStop;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppSearchField(
            controller: controller,
            hint: 'Cari produk…',
            autofocus: true,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: AppSpacing.x2),
        GestureDetector(
          onTap: onStop,
          child: const Icon(Icons.close_rounded,
              color: AppColors.onPrimary, size: 22),
        ),
      ],
    );
  }
}

// ── Kategori picker dialog ────────────────────────────────────────────────────

class _KategoriPickerDialog extends StatelessWidget {
  const _KategoriPickerDialog();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoriProvider>();
    final kategoriList = provider.availableKategori.toList()..sort();
    final selected = provider.kategoriFilter;
    final statusFilter = provider.statusFilter;

    final headerLabel = switch (statusFilter) {
      InventoriStatusFilter.peringatanStok => 'Peringatan Stok',
      InventoriStatusFilter.tidakAdaStok => 'Tidak ada Stok',
      null => selected ?? 'Semua Kategori',
    };

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
                  const Icon(Icons.filter_list_rounded,
                      color: AppColors.onPrimary, size: 22),
                  const SizedBox(width: AppSpacing.x2),
                  Expanded(
                    child: Text(
                      headerLabel,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w600,
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
                  // ── Special filters ───────────────────────────────────────
                  _SpecialFilterTile(
                    label: '[Semua Kategori]',
                    isSelected: selected == null && statusFilter == null,
                    onTap: () {
                      provider.setKategoriFilter(null);
                      Navigator.of(context).pop();
                    },
                  ),
                  _SpecialFilterTile(
                    label: '[Peringatan Stok]',
                    isSelected:
                        statusFilter == InventoriStatusFilter.peringatanStok,
                    onTap: () {
                      provider.setStatusFilter(
                          InventoriStatusFilter.peringatanStok);
                      Navigator.of(context).pop();
                    },
                  ),
                  _SpecialFilterTile(
                    label: '[Tidak ada Stok]',
                    isSelected:
                        statusFilter == InventoriStatusFilter.tidakAdaStok,
                    onTap: () {
                      provider.setStatusFilter(
                          InventoriStatusFilter.tidakAdaStok);
                      Navigator.of(context).pop();
                    },
                  ),
                  // ── Category items ────────────────────────────────────────
                  ...kategoriList.map(
                    (k) => _KategoriTile(
                      label: k,
                      imagePath: provider.kategoriImage(k),
                      isSelected: selected == k && statusFilter == null,
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

// ── Special filter tile (text-only, bracketed labels) ─────────────────────────

class _SpecialFilterTile extends StatelessWidget {
  const _SpecialFilterTile({
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
          vertical: AppSpacing.x3,
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

// ── Category tile with image thumbnail ───────────────────────────────────────

class _KategoriTile extends StatelessWidget {
  const _KategoriTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.imagePath,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? imagePath;

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
            _Thumbnail(imagePath: imagePath),
            const SizedBox(width: AppSpacing.x3),
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

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.imagePath});
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: imagePath != null
          ? _buildImage(imagePath!)
          : const Icon(Icons.image_rounded,
              color: AppColors.onPrimary, size: 22),
    );
  }

  Widget _buildImage(String path) {
    if (!path.startsWith('http')) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, st) =>
            const Icon(Icons.image_rounded, color: AppColors.onPrimary, size: 22),
      );
    }
    return Image.network(
      path,
      fit: BoxFit.cover,
      errorBuilder: (ctx, err, st) =>
          const Icon(Icons.image_rounded, color: AppColors.onPrimary, size: 22),
    );
  }
}
