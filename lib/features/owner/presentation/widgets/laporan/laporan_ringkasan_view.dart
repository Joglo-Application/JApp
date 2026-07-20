import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../providers/owner_laporan_provider.dart';

/// Format "Rp 1.234.567".
String _rp(double v) {
  final s = v.round().abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}Rp $buf';
}

class LaporanRingkasanView extends StatelessWidget {
  const LaporanRingkasanView({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.watch<OwnerLaporanProvider>().ringkasan;

    final summaryItems = [
      ('Ringkasan Loyalty Point', r.poinTerkumpul),
      ('Pesanan Diterima', r.pesananDiterima),
      ('Pesanan Dibatalkan', r.pesananDibatalkan),
      ('Pesanan Diretur', r.pesananDiretur),
    ];

    final pencatatanItems = [
      ('Pendapatan', _rp(r.pendapatan)),
      ('Pengeluaran', _rp(r.pengeluaran)),
      ('Pengembalian Penjualan', _rp(r.retur)),
    ];

    // "Kotor" = sebelum pajak & biaya layanan; "Penerimaan" = bersih setelah
    // dikurangi retur dan pengeluaran.
    final penjualanItems = [
      ('Total Penjualan', _rp(r.pendapatan)),
      ('Penjualan Kotor', _rp(r.subtotal)),
      ('Penerimaan', _rp(r.pendapatanBersih)),
    ];

    return ListView(
      children: [
        ...summaryItems.map(
          (item) => _SummaryRow(label: item.$1, total: item.$2),
        ),
        const _SectionHeader('Ringkasan Pencatatan Resto'),
        ...pencatatanItems.map(
          (item) => _KeyValueRow(label: item.$1, value: item.$2),
        ),
        const _SectionHeader('Ringkasan Penjualan'),
        ...penjualanItems.map(
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
