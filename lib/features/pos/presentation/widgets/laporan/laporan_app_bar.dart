import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../providers/log_transaksi_provider.dart';
import '../../providers/transaksi_provider.dart';

class LaporanAppBar extends StatelessWidget {
  const LaporanAppBar({super.key});

  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static const _tabLabels = [
    'Penutupan Penjualan',
    'Penjualan Produk',
    'Log Transaksi',
  ];

  String _formatDate(DateTime dt) =>
      '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  @override
  Widget build(BuildContext context) {
    final date = context.select<TransaksiProvider, DateTime>(
      (p) => p.selectedDate,
    );
    final tabController = DefaultTabController.of(context);

    return ListenableBuilder(
      listenable: tabController,
      builder: (context, _) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            border: Border(
              bottom: BorderSide(color: AppColors.secondaryContainer),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
                vertical: AppSpacing.x3,
              ),
              child: Row(
                children: [
                  _IconButtonSquare(
                    icon: Icons.menu_rounded,
                    iconSize: 28,
                    onTap: () => Scaffold.of(context).openDrawer(),
                  ),
                  const SizedBox(width: AppSpacing.x4),
                  Expanded(
                    child: _SegmentedTabs(
                      labels: _tabLabels,
                      activeIndex: tabController.index,
                      onTap: tabController.animateTo,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x4),
                  _DatePill(
                    label: _formatDate(date),
                    onTap: () => _pickDate(context, date),
                  ),
                  const SizedBox(width: AppSpacing.x2),
                  _IconButtonSquare(
                    icon: Icons.refresh_rounded,
                    iconSize: 24,
                    onTap: () => _refresh(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && context.mounted) {
      context.read<TransaksiProvider>().changeDate(picked);
    }
  }

  void _refresh(BuildContext context) {
    final tab = DefaultTabController.of(context).index;
    if (tab == 2) {
      context.read<LogTransaksiProvider>().load();
    } else {
      context.read<TransaksiProvider>()
        ..load()
        ..loadWeeklyData();
    }
  }
}

/// Segmented control: satu track dengan tab aktif terisi emas.
class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.labels,
    required this.activeIndex,
    required this.onTap,
  });

  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: AppRadius.md,
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < labels.length; i++)
              _Segment(
                label: labels[i],
                active: activeIndex == i,
                onTap: () => onTap(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.sm,
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.labelLarge?.copyWith(
            color: active ? AppColors.onPrimary : Colors.white70,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Pill tanggal + ikon kalender; menekan membuka date picker.
class _DatePill extends StatelessWidget {
  const _DatePill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month_rounded,
                  color: AppColors.onPrimary, size: 20),
              const SizedBox(width: AppSpacing.x2),
              Text(
                label,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconButtonSquare extends StatelessWidget {
  const _IconButtonSquare({
    required this.icon,
    required this.onTap,
    this.iconSize = 24,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: SizedBox(
          width: 45,
          height: 45,
          child: Icon(icon, color: AppColors.onPrimary, size: iconSize),
        ),
      ),
    );
  }
}
