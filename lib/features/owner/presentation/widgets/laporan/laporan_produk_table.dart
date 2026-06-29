import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';

class LaporanProdukTable extends StatelessWidget {
  const LaporanProdukTable({super.key});

  static const _items = [
    _ProdukRow('Burger Sapi', 'Makanan', 63, 1260000),
    _ProdukRow('Bakmi Udang', 'Makanan', 104, 3328000),
    _ProdukRow('Lemon Squash', 'Minuman', 51, 714000),
    _ProdukRow('Americano', 'Minuman', 34, 340000),
  ];

  static const _topGroups = [
    _GroupRow('Makanan', 167, 'IDR 4.588.000'),
    _GroupRow('Minuman', 85, 'IDR 1.054.000'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ProdukHeader(),
        Expanded(
          child: ListView(
            children: [
              ..._items.map(
                (item) => Column(
                  children: [
                    _ProdukRow2(item: item),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.outlineVariant,
                    ),
                  ],
                ),
              ),
              const _SectionHeader('Top Group Produk'),
              const _GroupHeader(),
              ..._topGroups.map(
                (item) => Column(
                  children: [
                    _GroupDataRow(item: item),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.outlineVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Product table ─────────────────────────────────────────────────────────────

class _ProdukHeader extends StatelessWidget {
  const _ProdukHeader();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.outline,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: const [
            Expanded(flex: 3, child: _Cell('Produk', header: true)),
            Expanded(flex: 2, child: _Cell('Grup', header: true)),
            Expanded(child: _Cell('Qty Terjual', header: true, right: true)),
            Expanded(
              flex: 2,
              child: _Cell('Total Penjualan', header: true, right: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProdukRow2 extends StatelessWidget {
  const _ProdukRow2({required this.item});

  final _ProdukRow item;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            Expanded(flex: 3, child: _Cell(item.produk)),
            Expanded(flex: 2, child: _Cell(item.grup)),
            Expanded(child: _Cell('${item.qty}', right: true)),
            Expanded(
              flex: 2,
              child: _Cell(_formatNumber(item.total), right: true),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top Group section ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.outline,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.outline,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Nama',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Qty',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Jumlah',
                textAlign: TextAlign.right,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupDataRow extends StatelessWidget {
  const _GroupDataRow({required this.item});

  final _GroupRow item;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                item.nama,
                style: AppTypography.textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: Text(
                '${item.qty}',
                style: AppTypography.textTheme.bodyMedium,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                item.jumlah,
                textAlign: TextAlign.right,
                style: AppTypography.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

String _formatNumber(int value) {
  final s = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return buffer.toString();
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, {this.header = false, this.right = false});

  final String text;
  final bool header;
  final bool right;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: right ? TextAlign.right : TextAlign.left,
      style: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
        fontWeight: header ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}

class _ProdukRow {
  const _ProdukRow(this.produk, this.grup, this.qty, this.total);

  final String produk;
  final String grup;
  final int qty;
  final int total;
}

class _GroupRow {
  const _GroupRow(this.nama, this.qty, this.jumlah);

  final String nama;
  final int qty;
  final String jumlah;
}
