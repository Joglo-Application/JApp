import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../providers/transaksi_provider.dart';

class LaporanDatePanel extends StatelessWidget {
  const LaporanDatePanel({super.key});

  /// Shared with the right-panel headers so the green strip reads as one
  /// continuous bar across both panels.
  static const double headerHeight = 64;

  static const _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransaksiProvider>();
    // Tanggal terbaru di paling atas.
    final weekly = provider.weeklyPenjualan.reversed.toList();
    final selected = provider.selectedDate;
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: headerHeight,
          child: ColoredBox(
            color: AppColors.tertiary,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: AppSpacing.x2),
                  Text(
                    'Tanggal',
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: weekly.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.x3),
                  itemCount: weekly.length,
                  itemBuilder: (context, i) {
                    final date = weekly[i].$1;
                    final isSelected = _isSameDay(date, selected);
                    final isToday = _isSameDay(date, today);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.x2),
                      child: _DateTile(
                        weekday: _days[date.weekday - 1],
                        day: date.day,
                        month: _months[date.month - 1],
                        year: date.year,
                        isSelected: isSelected,
                        isToday: isToday,
                        onTap: () => provider.selectDate(date),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.weekday,
    required this.day,
    required this.month,
    required this.year,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final String weekday;
  final int day;
  final String month;
  final int year;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = isSelected ? AppColors.primary : AppColors.tertiary;
    return Material(
      color: isSelected ? AppColors.primaryContainer : AppColors.surface,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.md,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.x2),
          child: Row(
            children: [
              // Date badge
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isSelected ? 0.18 : 0.10),
                  borderRadius: AppRadius.sm,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    Text(
                      month,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            weekday,
                            style:
                                AppTypography.textTheme.titleSmall?.copyWith(
                              color: isSelected
                                  ? AppColors.onPrimaryContainer
                                  : AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: AppSpacing.x2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.tertiary,
                              borderRadius: AppRadius.full,
                            ),
                            child: Text(
                              'Hari ini',
                              style: AppTypography.textTheme.labelSmall
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '$day $month $year',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
