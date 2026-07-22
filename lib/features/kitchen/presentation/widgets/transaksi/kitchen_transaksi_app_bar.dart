import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/kitchen_order_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

const _months = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

class KitchenTransaksiAppBar extends StatelessWidget {
  const KitchenTransaksiAppBar({super.key});

  static String _dateLabel(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final tanggal = context.select<KitchenOrderProvider, DateTime>(
      (p) => p.selectedDate,
    );

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
              _MenuButton(),
              const SizedBox(width: AppSpacing.x3),
              Text(
                'Transaksi',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                _dateLabel(tanggal),
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              _CalendarButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
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

class _CalendarButton extends StatelessWidget {
  /// Membuka pemilih tanggal, lalu memuat ulang daftar untuk tanggal itu.
  /// Batas atas hari ini — dapur tidak punya pesanan di masa depan.
  Future<void> _pilihTanggal(BuildContext context) async {
    final provider = context.read<KitchenOrderProvider>();
    final kini = DateTime.now();
    final dipilih = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(kini.year - 1),
      lastDate: kini,
    );
    if (dipilih == null) return;
    await provider.changeDate(dipilih);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: () => _pilihTanggal(context),
        borderRadius: AppRadius.md,
        child: const SizedBox(
          width: 45,
          height: 45,
          child:
              Icon(Icons.calendar_month_rounded, color: AppColors.onPrimary, size: 24),
        ),
      ),
    );
  }
}
