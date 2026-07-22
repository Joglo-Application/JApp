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

  bool get _isInventori => widget.source == ProdukSource.inventori;

  /// Warna & ikon aksen mengikuti konvensi di halaman kelola stok:
  /// Inventori (produk/menu) = oranye, Stok Gudang (bahan) = hijau utama.
  Color get _accent => _isInventori ? Colors.deepOrange : AppColors.primary;
  IconData get _accentIcon =>
      _isInventori ? Icons.inventory_2_rounded : Icons.warehouse_rounded;
  String get _title => _isInventori ? 'Inventori' : 'Stok Gudang';

  @override
  void initState() {
    super.initState();
    _muat();
  }

  /// Daftar produk diambil dari server (menu untuk Inventori, bahan baku
  /// untuk Stok Gudang) supaya id-nya ikut terbawa saat dipilih.
  Future<void> _muat() async {
    try {
      final items = _isInventori
          ? await _datasource.fetchMenus()
          : await _datasource.fetchBahanBaku();
      // Urutkan menurut nama (A→Z, tanpa peduli huruf besar/kecil).
      items.sort(
        (a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()),
      );
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

  void _pilih(ProdukPilihan item) {
    Navigator.of(context).pop(
      StokMasukProdukItem(
        refId: item.id,
        nama: item.nama,
        source: widget.source,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          _buildSearchBar(),
          Expanded(child: _buildBody(context)),
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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x4,
            AppSpacing.x3,
            AppSpacing.x3,
            AppSpacing.x4,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: AppRadius.md,
                ),
                child: Icon(_accentIcon, color: AppColors.onPrimary, size: 22),
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        color: AppColors.onSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Pilih produk untuk ditambahkan',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                color: AppColors.onSecondary,
                iconSize: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x4,
          AppSpacing.x3,
          AppSpacing.x4,
          AppSpacing.x3,
        ),
        child: TextField(
          onChanged: (q) => setState(() => _query = q),
          style: AppTypography.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Cari produk',
            hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.onSurfaceVariant,
              size: 22,
            ),
            filled: true,
            fillColor: AppColors.background,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x3,
              vertical: AppSpacing.x3,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(color: _accent, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_memuat) {
      return Center(child: CircularProgressIndicator(color: _accent));
    }

    final items = _filteredItems;
    if (items.isEmpty) {
      return _EmptyState(
        icon: _query.isEmpty ? _accentIcon : Icons.search_off_rounded,
        message: _query.isEmpty
            ? 'Belum ada produk'
            : 'Tidak ada produk cocok "$_query"',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x4,
            AppSpacing.x3,
            AppSpacing.x4,
            AppSpacing.x2,
          ),
          child: Text(
            '${items.length} produk',
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x4,
              0,
              AppSpacing.x4,
              AppSpacing.x4,
            ),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.x2),
            itemBuilder: (_, i) => _ProdukCard(
              item: items[i],
              accent: _accent,
              satuanFallback: _isInventori ? 'porsi' : '',
              onTap: () => _pilih(items[i]),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Kartu produk ─────────────────────────────────────────────────────────────

class _ProdukCard extends StatelessWidget {
  const _ProdukCard({
    required this.item,
    required this.accent,
    required this.satuanFallback,
    required this.onTap,
  });

  final ProdukPilihan item;
  final Color accent;
  final String satuanFallback;
  final VoidCallback onTap;

  static String _fmtAngka(double v) {
    final s = (v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString());
    final buf = StringBuffer();
    final intPart = s.split('.').first;
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
      buf.write(intPart[i]);
    }
    final dec = s.contains('.') ? ',${s.split('.').last}' : '';
    return '$buf$dec';
  }

  @override
  Widget build(BuildContext context) {
    final satuan = item.satuan.isNotEmpty ? item.satuan : satuanFallback;
    final huruf = item.nama.isNotEmpty ? item.nama[0].toUpperCase() : '?';

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.x3),
          decoration: BoxDecoration(
            borderRadius: AppRadius.md,
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: AppRadius.sm,
                ),
                child: Text(
                  huruf,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x1),
                    Row(
                      children: [
                        _MetaChip(
                          icon: Icons.inventory_rounded,
                          label: 'Stok ${_fmtAngka(item.stok)}'
                              '${satuan.isNotEmpty ? ' $satuan' : ''}',
                        ),
                        if (item.harga > 0) ...[
                          const SizedBox(width: AppSpacing.x2),
                          _MetaChip(
                            icon: Icons.sell_rounded,
                            label: 'Rp ${_fmtAngka(item.harga)}',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: AppRadius.sm,
                ),
                child: const Icon(
                  Icons.add_rounded,
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: AppRadius.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 56,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppSpacing.x3),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
