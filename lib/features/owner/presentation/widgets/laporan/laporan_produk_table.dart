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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Header(),
        Expanded(
          child: ListView.separated(
            itemCount: _items.length,
            separatorBuilder: (_, _) => const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.outlineVariant,
            ),
            itemBuilder: (_, i) => _Row(item: _items[i]),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

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
                child: _Cell('Total Penjualan', header: true, right: true)),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item});

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
