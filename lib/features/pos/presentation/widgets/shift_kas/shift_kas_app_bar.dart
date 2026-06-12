import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../providers/shift_kas_provider.dart';

class ShiftKasAppBar extends StatelessWidget {
  const ShiftKasAppBar({super.key});

  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatDate(DateTime dt) =>
      '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  static String _formatRp(double amount) {
    final s = amount.round().toString();
    final buf = StringBuffer('Rp ');
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final date = context.select<ShiftKasProvider, DateTime>(
      (p) => p.selectedDate,
    );
    final totalKas = context.select<ShiftKasProvider, double>(
      (p) => p.totalKas,
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
                'Shift Kas Kasir',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              _RiwayatButton(),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: _KasBalanceDisplay(label: _formatRp(totalKas)),
              ),
              const SizedBox(width: AppSpacing.x3),
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

class _RiwayatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade400),
        foregroundColor: AppColors.onSecondary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
        minimumSize: const Size(0, 45),
      ),
      child: Text(
        'Riwayat',
        style: AppTypography.textTheme.labelLarge?.copyWith(
          color: AppColors.onSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _KasBalanceDisplay extends StatelessWidget {
  const _KasBalanceDisplay({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTypography.textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
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
            context.read<ShiftKasProvider>().changeDate(picked);
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
