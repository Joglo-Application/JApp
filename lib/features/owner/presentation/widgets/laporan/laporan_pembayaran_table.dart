import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';

class LaporanPembayaranTable extends StatelessWidget {
  const LaporanPembayaranTable({super.key});

  static const _items = [
    _PayRow('TUNAI', 104, 'IDR 8.588.000'),
    _PayRow('QRIS', 285, 'IDR 26.054.000'),
    _PayRow('DEBIT CARD', 163, 'IDR 9.124.000'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _SectionHeader('Top Metode Pembayaran'),
        const _Header(),
        ..._items.map((item) => _DataRow(item: item)),
      ],
    );
  }
}

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
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Nama',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Qty',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
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
                  color: AppColors.onSurface,
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

class _DataRow extends StatelessWidget {
  const _DataRow({required this.item});

  final _PayRow item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ColoredBox(
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
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${item.qty}',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    item.jumlah,
                    textAlign: TextAlign.right,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant),
      ],
    );
  }
}

class _PayRow {
  const _PayRow(this.nama, this.qty, this.jumlah);

  final String nama;
  final int qty;
  final String jumlah;
}
