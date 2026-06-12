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
    final activeFilter = context.select<InventoriProvider, String?>(
      (p) => p.kategoriFilter,
    );

    return ColoredBox(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2,
        ),
        child: _isSearching ? _SearchRow(
          controller: _searchCtrl,
          onStop: _stopSearch,
          onChanged: (q) => context.read<InventoriProvider>().search(q),
        ) : _FilterRow(
          activeFilter: activeFilter,
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
    required this.activeFilter,
    required this.onSearchTap,
    required this.onFilterTap,
  });

  final String? activeFilter;
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
            activeFilter ?? 'Semua Tipe Produk',
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
                      selected ?? 'Semua Tipe Produk',
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
                  _KategoriTile(
                    label: 'Semua Tipe Produk',
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
