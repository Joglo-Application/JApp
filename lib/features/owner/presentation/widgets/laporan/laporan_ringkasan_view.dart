import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';

class LaporanRingkasanView extends StatelessWidget {
  const LaporanRingkasanView({super.key});

  static const _summaryItems = [
    ('Ringkasan Loyalty Point', 34),
    ('Pesanan Diterima', 225),
    ('Pesanan Dibatalkan', 62),
    ('Pesanan Diretur', 21),
  ];

  static const _pencatatanItems = [
    ('Pendapatan', 'Rp 1.270.600'),
    ('Pengeluaran', 'Rp 200.000'),
    ('Pengembalian Penjualan', 'Rp 280.700'),
  ];

  static const _penjualanItems = [
    ('Total Penjualan', 'Rp 989.900'),
    ('Penjualan Kotor', 'Rp 949.300'),
    ('Penerimaan', 'Rp 989.000'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ..._summaryItems.map(
          (item) => _SummaryRow(label: item.$1, total: item.$2),
        ),
        const _SectionHeader('Ringkasan Pencatatan Resto'),
        ..._pencatatanItems.map(
          (item) => _KeyValueRow(label: item.$1, value: item.$2),
        ),
        const _SectionHeader('Ringkasan Penjualan'),
        ..._penjualanItems.map(
          (item) => _KeyValueRow(label: item.$1, value: item.$2),
        ),
      ],
    );
  }
}

// ── Rows ──────────────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.total});

  final String label;
  final int total;

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
                  child: Text(
                    label,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Text(
                  'Total  :  $total',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
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

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});

  final String label;
  final String value;

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
                  child: Text(
                    label,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
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
