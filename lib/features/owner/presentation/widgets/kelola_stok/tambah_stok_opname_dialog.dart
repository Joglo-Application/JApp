import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/app_button.dart';

typedef TambahStokOpnameResult = ({DateTime tanggal, String catatan});

class TambahStokOpnameDialog extends StatefulWidget {
  const TambahStokOpnameDialog({super.key});

  static Future<TambahStokOpnameResult?> show(BuildContext context) {
    return showDialog<TambahStokOpnameResult>(
      context: context,
      builder: (_) => const TambahStokOpnameDialog(),
    );
  }

  @override
  State<TambahStokOpnameDialog> createState() => _TambahStokOpnameDialogState();
}

class _TambahStokOpnameDialogState extends State<TambahStokOpnameDialog> {
  DateTime _tanggal = DateTime.now();
  final _catatanCtrl = TextEditingController();

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: AppRadius.toShape(AppRadius.lg),
      child: SizedBox(
        width: 680,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(height: 1),
            _buildContent(),
            const Divider(height: 1),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          const Spacer(),
          Text(
            'Tambah Stok Opname',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            iconSize: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tanggal',
            style: AppTypography.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          _DateField(
            value: _tanggal,
            onChanged: (d) => setState(() => _tanggal = d),
          ),
          const SizedBox(height: AppSpacing.x4),
          Text(
            'Catatan',
            style: AppTypography.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          TextFormField(
            controller: _catatanCtrl,
            maxLines: 5,
            style: AppTypography.textTheme.bodyMedium,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: AppRadius.xs,
                borderSide: const BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.xs,
                borderSide: const BorderSide(color: AppColors.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.xs,
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.x3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x6,
        vertical: AppSpacing.x4,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppOutlinedButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
              width: double.infinity,
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop((
                  tanggal: _tanggal,
                  catatan: _catatanCtrl.text,
                )),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.tertiary,
                  foregroundColor: AppColors.onTertiary,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
                  textStyle: AppTypography.textTheme.labelLarge,
                ),
                child: const Text('Simpan'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onChanged});

  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  static String _format(DateTime d) {
    const hari = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
    ];
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${hari[d.weekday - 1]}, ${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pick(context),
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surface,
          suffixIcon: InkWell(
            onTap: () => _pick(context),
            child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.xs,
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.xs,
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x3,
          ),
        ),
        child: Text(_format(value), style: AppTypography.textTheme.bodyMedium),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) onChanged(picked);
  }
}
