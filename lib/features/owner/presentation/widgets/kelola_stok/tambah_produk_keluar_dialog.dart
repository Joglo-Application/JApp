import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../data/datasources/stok_dokumen_remote_datasource.dart';
import '../../../domain/entities/stok_keluar_entry.dart';

class TambahProdukKeluarPage extends StatefulWidget {
  const TambahProdukKeluarPage({super.key, this.alreadyAdded = const []});

  final List<String> alreadyAdded;

  static Future<List<StokKeluarProdukItem>?> push(
    BuildContext context, {
    List<String> alreadyAdded = const [],
  }) {
    return Navigator.of(context).push<List<StokKeluarProdukItem>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => TambahProdukKeluarPage(alreadyAdded: alreadyAdded),
      ),
    );
  }

  @override
  State<TambahProdukKeluarPage> createState() => _TambahProdukKeluarPageState();
}

class _TambahProdukKeluarPageState extends State<TambahProdukKeluarPage> {
  final _datasource = StokDokumenRemoteDatasource();

  List<ProdukPilihan> _allProduk = const [];
  bool _memuat = true;
  String _query = '';

  /// Dipilih per id, bukan per nama, agar produk bernama sama tidak tertukar.
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    try {
      final items = await _datasource.fetchMenus();
      if (mounted) setState(() => _allProduk = items);
    } on ApiException {
      // Biarkan kosong daripada menampilkan produk contoh.
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  List<ProdukPilihan> get _filtered {
    final q = _query.toLowerCase();
    return _allProduk
        .where((p) =>
            !widget.alreadyAdded.contains(p.nama) &&
            (q.isEmpty || p.nama.toLowerCase().contains(q)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          _buildSearchBar(),
          Expanded(child: _buildList(filtered)),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
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
              'Tambah Produk',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppSpacing.x2),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
              iconSize: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
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

  Widget _buildList(List<ProdukPilihan> items) {
    if (_memuat) return const Center(child: CircularProgressIndicator());
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
      itemBuilder: (_, i) {
        final p = items[i];
        final isChecked = _selected.contains(p.id);
        return InkWell(
          onTap: () => setState(() {
            if (isChecked) {
              _selected.remove(p.id);
            } else {
              _selected.add(p.id);
            }
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    p.nama,
                    style: AppTypography.textTheme.bodyMedium,
                  ),
                ),
                Checkbox(
                  value: isChecked,
                  activeColor: AppColors.tertiary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _selected.add(p.id);
                    } else {
                      _selected.remove(p.id);
                    }
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 56,
        child: FilledButton(
          onPressed: _selected.isEmpty ? null : _onTambah,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.tertiary,
            foregroundColor: AppColors.onTertiary,
            disabledBackgroundColor: AppColors.tertiary.withValues(alpha: 0.4),
            shape: const RoundedRectangleBorder(),
            textStyle: AppTypography.textTheme.labelLarge,
          ),
          child: const Text('Tambah'),
        ),
      ),
    );
  }

  void _onTambah() {
    final byId = {for (final p in _allProduk) p.id: p};
    final result = _selected
        .map((id) => StokKeluarProdukItem(
              refId: id,
              nama: byId[id]?.nama ?? '',
              harga: (byId[id]?.harga ?? 0).round(),
            ))
        .toList();
    Navigator.of(context).pop(result);
  }
}
