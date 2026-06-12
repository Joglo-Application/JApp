import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../providers/transaksi_provider.dart';

class TransaksiAppBar extends StatelessWidget {
  const TransaksiAppBar({super.key});

  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatDate(DateTime dt) =>
      '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  @override
  Widget build(BuildContext context) {
    final date = context.select<TransaksiProvider, DateTime>(
      (p) => p.selectedDate,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        border: Border(bottom: BorderSide(color: AppColors.secondaryContainer)),
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
              Text(
                'Transaksi',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              const _OnlineChip(),
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

class _OnlineChip extends StatelessWidget {
  const _OnlineChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3,
        vertical: AppSpacing.x1,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_done_rounded, size: 14, color: AppColors.onPrimary),
          const SizedBox(width: AppSpacing.x1),
          Text(
            'Online',
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton({required this.currentDate});

  final DateTime currentDate;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
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
      icon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
