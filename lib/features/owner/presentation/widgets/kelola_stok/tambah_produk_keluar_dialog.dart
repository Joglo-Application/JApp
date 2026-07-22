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
      // Urutkan menurut nama (A→Z, tanpa peduli huruf besar/kecil).
      items.sort(
        (a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()),
      );
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
      padding: const EdgeInsets.all(AppSpacing.x4),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.x2),
      itemBuilder: (_, i) {
        final p = items[i];
        final isChecked = _selected.contains(p.id);
        return _ProdukPickRow(
          produk: p,
          selected: isChecked,
          onToggle: () => setState(() {
            if (isChecked) {
              _selected.remove(p.id);
            } else {
              _selected.add(p.id);
            }
          }),
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

// ── Baris pilih produk ───────────────────────────────────────────────────────

class _ProdukPickRow extends StatelessWidget {
  const _ProdukPickRow({
    required this.produk,
    required this.selected,
    required this.onToggle,
  });

  final ProdukPilihan produk;
  final bool selected;
  final VoidCallback onToggle;

  static String _fmtAngka(double v) {
    final s = v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
    final intPart = s.split('.').first;
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
      buf.write(intPart[i]);
    }
    final dec = s.contains('.') ? ',${s.split('.').last}' : '';
    return '$buf$dec';
  }

  @override
  Widget build(BuildContext context) {
    final habis = produk.stok <= 0;
    final huruf = produk.nama.isNotEmpty ? produk.nama[0].toUpperCase() : '?';

    return Material(
      color: selected
          ? AppColors.tertiary.withValues(alpha: 0.08)
          : AppColors.surface,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: onToggle,
        borderRadius: AppRadius.md,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.x3),
          decoration: BoxDecoration(
            borderRadius: AppRadius.md,
            border: Border.all(
              color: selected ? AppColors.tertiary : AppColors.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.sm,
                ),
                child: Text(
                  huruf,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.tertiary,
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
                      produk.nama,
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
                          label: 'Stok ${_fmtAngka(produk.stok)}',
                          fg: habis ? AppColors.error : Colors.green.shade700,
                          bg: habis
                              ? AppColors.error.withValues(alpha: 0.10)
                              : Colors.green.withValues(alpha: 0.12),
                        ),
                        if (produk.harga > 0) ...[
                          const SizedBox(width: AppSpacing.x2),
                          _MetaChip(
                            icon: Icons.sell_rounded,
                            label: 'Rp ${_fmtAngka(produk.harga)}',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              Checkbox(
                value: selected,
                activeColor: AppColors.tertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.fg,
    this.bg,
  });

  final IconData icon;
  final String label;

  /// Warna teks/ikon dan latar chip; default netral (abu-abu).
  final Color? fg;
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    final foreground = fg ?? AppColors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg ?? AppColors.surfaceContainerHighest,
        borderRadius: AppRadius.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
