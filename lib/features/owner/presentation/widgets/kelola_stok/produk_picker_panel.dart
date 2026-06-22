import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/stok_masuk_entry.dart';

class ProdukPickerPanel extends StatefulWidget {
  const ProdukPickerPanel({super.key, required this.source});

  final ProdukSource source;

  @override
  State<ProdukPickerPanel> createState() => _ProdukPickerPanelState();
}

class _ProdukPickerPanelState extends State<ProdukPickerPanel> {
  static const _inventoriItems = [
    'Burger Sapi',
    'Bakmi Udang',
    'Lemon Squash',
    'Americano',
  ];
  static const _stokGudangItems = [
    'Beras',
    'Air Galon',
    'Telur',
    'Tepung Terigu',
    'Daging Ayam Fillet',
  ];

  String _query = '';

  List<String> get _allItems => widget.source == ProdukSource.inventori
      ? _inventoriItems
      : _stokGudangItems;

  List<String> get _filteredItems => _query.isEmpty
      ? _allItems
      : _allItems
          .where((i) => i.toLowerCase().contains(_query.toLowerCase()))
          .toList();

  String get _title =>
      widget.source == ProdukSource.inventori ? 'Inventori' : 'Stok Gudang';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          _buildSearchBar(),
          Expanded(child: _buildList(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.shellBackground),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x3,
          ),
          child: Row(
            children: [
              const Spacer(),
              Text(
                _title,
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                color: AppColors.onSecondary,
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppColors.onSurfaceVariant,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
            child: TextField(
              onChanged: (q) => setState(() => _query = q),
              style: AppTypography.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Cari',
                hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.xs,
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.xs,
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.xs,
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x3,
                  vertical: AppSpacing.x2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final items = _filteredItems;
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => InkWell(
        onTap: () => Navigator.of(context).pop(
          StokMasukProdukItem(nama: items[i], source: widget.source),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x4,
          ),
          child: Text(
            items[i],
            style: AppTypography.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
