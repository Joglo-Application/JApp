import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/stok_opname_entry.dart';

class _ProdukOption {
  const _ProdukOption({required this.nama, required this.qtySystem});
  final String nama;
  final int qtySystem;
}

class TambahProdukOpnamePage extends StatefulWidget {
  const TambahProdukOpnamePage({super.key, this.alreadyAdded = const []});

  final List<String> alreadyAdded;

  static Future<List<StokOpnameProdukItem>?> push(
    BuildContext context, {
    List<String> alreadyAdded = const [],
  }) {
    return Navigator.of(context).push<List<StokOpnameProdukItem>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => TambahProdukOpnamePage(alreadyAdded: alreadyAdded),
      ),
    );
  }

  @override
  State<TambahProdukOpnamePage> createState() => _TambahProdukOpnamePageState();
}

class _TambahProdukOpnamePageState extends State<TambahProdukOpnamePage> {
  static const _allProduk = [
    _ProdukOption(nama: 'Burger Sapi', qtySystem: 50),
    _ProdukOption(nama: 'Bakmi Udang', qtySystem: 40),
    _ProdukOption(nama: 'Lemon Squash', qtySystem: 35),
    _ProdukOption(nama: 'Americano', qtySystem: 60),
    _ProdukOption(nama: 'Air Mineral 600ml', qtySystem: 30),
    _ProdukOption(nama: 'Air Mineral 750ml', qtySystem: 22),
  ];

  String _query = '';
  final Set<String> _selected = {};

  List<_ProdukOption> get _filtered {
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
          const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 22),
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
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
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

  Widget _buildList(List<_ProdukOption> items) {
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
        final isChecked = _selected.contains(p.nama);
        return InkWell(
          onTap: () => setState(() {
            isChecked ? _selected.remove(p.nama) : _selected.add(p.nama);
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(p.nama, style: AppTypography.textTheme.bodyMedium),
                ),
                Checkbox(
                  value: isChecked,
                  activeColor: AppColors.tertiary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (v) => setState(() {
                    v == true ? _selected.add(p.nama) : _selected.remove(p.nama);
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
    final map = {for (final p in _allProduk) p.nama: p};
    final result = _selected
        .map((nama) => StokOpnameProdukItem(
              nama: nama,
              qtySystem: map[nama]?.qtySystem ?? 0,
              qtyAktual: map[nama]?.qtySystem ?? 0,
            ))
        .toList();
    Navigator.of(context).pop(result);
  }
}
