import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../data/datasources/stok_dokumen_remote_datasource.dart';
import '../../../domain/entities/stok_masuk_entry.dart';

class ProdukPickerPanel extends StatefulWidget {
  const ProdukPickerPanel({super.key, required this.source});

  final ProdukSource source;

  @override
  State<ProdukPickerPanel> createState() => _ProdukPickerPanelState();
}

class _ProdukPickerPanelState extends State<ProdukPickerPanel> {
  final _datasource = StokDokumenRemoteDatasource();

  List<ProdukPilihan> _allItems = const [];
  bool _memuat = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _muat();
  }

  /// Daftar produk diambil dari server (menu untuk Inventori, bahan baku
  /// untuk Stok Gudang) supaya id-nya ikut terbawa saat dipilih.
  Future<void> _muat() async {
    try {
      final items = widget.source == ProdukSource.inventori
          ? await _datasource.fetchMenus()
          : await _datasource.fetchBahanBaku();
      if (mounted) setState(() => _allItems = items);
    } on ApiException {
      // Biarkan kosong; daftar tampil hampa daripada menampilkan contoh palsu.
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  List<ProdukPilihan> get _filteredItems => _query.isEmpty
      ? _allItems
      : _allItems
          .where((i) => i.nama.toLowerCase().contains(_query.toLowerCase()))
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
    if (_memuat) return const Center(child: CircularProgressIndicator());

    final items = _filteredItems;
    if (items.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada produk',
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => InkWell(
        onTap: () => Navigator.of(context).pop(
          StokMasukProdukItem(
            refId: items[i].id,
            nama: items[i].nama,
            source: widget.source,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x4,
          ),
          child: Text(
            items[i].nama,
            style: AppTypography.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
