import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
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
          decoration: BoxDecoration(
            color: Colors.grey.shade700,
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
                  _HamburgerButton(),
                  const SizedBox(width: AppSpacing.x3),
                  for (var i = 0; i < _tabLabels.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.x2),
                    _TabButton(
                      label: _tabLabels[i],
                      active: tabController.index == i,
                      onTap: () => tabController.animateTo(i),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    _formatDate(date),
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x2),
                  _DatePickerButton(currentDate: date),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HamburgerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: () => Scaffold.of(context).openDrawer(),
        borderRadius: AppRadius.md,
        child: const SizedBox(
          width: 45,
          height: 45,
          child: Icon(Icons.menu_rounded, color: AppColors.onPrimary, size: 28),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.sm,
          border: Border.all(
            color: active ? AppColors.primary : Colors.white54,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.labelLarge?.copyWith(
            color: active ? AppColors.onPrimary : Colors.white,
            fontWeight: active ? FontWeight.bold : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton({required this.currentDate});

  final DateTime currentDate;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: currentDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (picked != null && context.mounted) {
            context.read<TransaksiProvider>().changeDate(picked);
          }
        },
        borderRadius: AppRadius.md,
        child: const SizedBox(
          width: 45,
          height: 45,
          child: Icon(
            Icons.calendar_month_rounded,
            color: AppColors.onPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
