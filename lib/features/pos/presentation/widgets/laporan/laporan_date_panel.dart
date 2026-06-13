import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../providers/transaksi_provider.dart';

class LaporanDatePanel extends StatelessWidget {
  const LaporanDatePanel({super.key});

  static const _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatDate(DateTime dt) =>
      '${_days[dt.weekday - 1]}, ${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransaksiProvider>();
    final weekly = provider.weeklyPenjualan;
    final selected = provider.selectedDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColoredBox(
          color: AppColors.tertiary,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x4,
            ),
            child: Text(
              'Tanggal',
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: weekly.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemCount: weekly.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.outlineVariant,
                  ),
                  itemBuilder: (context, i) {
                    final date = weekly[i].$1;
                    final isSelected = _isSameDay(date, selected);

                    return InkWell(
                      onTap: () => provider.changeDate(date),
                      child: ColoredBox(
                        color: isSelected
                            ? AppColors.primaryContainer
                            : Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.x4,
                            vertical: AppSpacing.x4,
                          ),
                          child: Text(
                            _formatDate(date),
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? AppColors.onPrimaryContainer
                                  : AppColors.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
