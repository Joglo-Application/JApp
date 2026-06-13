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
    final shiftStarted = context.select<ShiftKasProvider, bool>(
      (p) => p.shiftStarted,
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
                child: GestureDetector(
                  onTap: shiftStarted
                      ? () {
                          final provider = context.read<ShiftKasProvider>();
                          showDialog<void>(
                            context: context,
                            builder: (_) => ChangeNotifierProvider.value(
                              value: provider,
                              child: const _ShiftBerakhirDialog(),
                            ),
                          );
                        }
                      : null,
                  child: _KasBalanceDisplay(label: _formatRp(totalKas)),
                ),
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

class _ShiftBerakhirDialog extends StatefulWidget {
  const _ShiftBerakhirDialog();

  @override
  State<_ShiftBerakhirDialog> createState() => _ShiftBerakhirDialogState();
}

class _ShiftBerakhirDialogState extends State<_ShiftBerakhirDialog> {
  final DateTime _berakhirPada = DateTime.now();

  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year} $h:$m:$s';
  }

  static String _formatNum(double amount) {
    final s = amount.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final totalKeluar = context.read<ShiftKasProvider>().totalKeluar;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x6,
                AppSpacing.x5,
                AppSpacing.x6,
                AppSpacing.x5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Shift Berakhir',
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.x5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Berakhir pada',
                          style: AppTypography.textTheme.bodyMedium),
                      Text(_formatDateTime(_berakhirPada),
                          style: AppTypography.textTheme.bodyMedium),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.x4),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kas Keluar',
                          style: AppTypography.textTheme.bodyMedium),
                      Text(_formatNum(totalKeluar),
                          style: AppTypography.textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: AppTypography.textTheme.labelLarge?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        context.read<ShiftKasProvider>().berakhirShift();
                        Navigator.of(context).pop();
                      },
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      ),
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Konfirmasi',
                          style: AppTypography.textTheme.labelLarge?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
