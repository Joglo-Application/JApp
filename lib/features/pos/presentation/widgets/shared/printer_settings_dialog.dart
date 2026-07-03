import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';

/// Dialog for adding / configuring a receipt printer from the Pengaturan page.
class PrinterSettingsDialog extends StatefulWidget {
  const PrinterSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const PrinterSettingsDialog(),
    );
  }

  @override
  State<PrinterSettingsDialog> createState() => _PrinterSettingsDialogState();
}

class _PrinterSettingsDialogState extends State<PrinterSettingsDialog> {
  final _namaCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();

  String? _seriesPrinter;
  String? _kolomResi;
  String? _jumlahSalinan;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: AppRadius.toShape(AppRadius.lg),
      child: SizedBox(
        width: 420,
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
        horizontal: AppSpacing.x5,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          Text(
            'Printer',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
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
      padding: const EdgeInsets.all(AppSpacing.x5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(label: 'Cari Printer', onPressed: _cariPrinter),
          const SizedBox(height: AppSpacing.x4),
          AppTextField(controller: _namaCtrl, label: 'Nama Printer'),
          const SizedBox(height: AppSpacing.x4),
          AppTextField(controller: _alamatCtrl, label: 'Alamat Printer'),
          const SizedBox(height: AppSpacing.x4),
          _OptionTile(
            label: 'Series Printer',
            value: _seriesPrinter,
            options: const ['58mm (2 inch)', '80mm (3 inch)'],
            onSelected: (v) => setState(() => _seriesPrinter = v),
          ),
          const SizedBox(height: AppSpacing.x3),
          _OptionTile(
            label: 'Kolom Resi',
            value: _kolomResi,
            options: const ['32 Kolom', '48 Kolom'],
            onSelected: (v) => setState(() => _kolomResi = v),
          ),
          const SizedBox(height: AppSpacing.x3),
          _OptionTile(
            label: 'Jumlah Salinan',
            value: _jumlahSalinan,
            options: const ['1', '2', '3', '4', '5'],
            onSelected: (v) => setState(() => _jumlahSalinan = v),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x5,
        vertical: AppSpacing.x4,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Hapus',
              isDestructive: true,
              onPressed: _hapus,
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: AppButton(label: 'Tes Cetak', onPressed: _tesCetak),
          ),
        ],
      ),
    );
  }

  void _cariPrinter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur pencarian printer belum tersedia')),
    );
  }

  void _hapus() {
    setState(() {
      _namaCtrl.clear();
      _alamatCtrl.clear();
      _seriesPrinter = null;
      _kolomResi = null;
      _jumlahSalinan = null;
    });
  }

  void _tesCetak() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur tes cetak belum tersedia')),
    );
  }
}

// ── Option tile (opens a picker sheet) ─────────────────────────────────────

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.sm,
      onTap: () => _pick(context),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outline),
          borderRadius: AppRadius.sm,
        ),
        child: Text(
          value == null ? label : '$label: $value',
          textAlign: TextAlign.center,
          style: AppTypography.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.topLg),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.x4),
              child: Text(
                label,
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            for (final option in options)
              ListTile(
                title: Text(option),
                trailing: option == value
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );
    if (selected != null) onSelected(selected);
  }
}
