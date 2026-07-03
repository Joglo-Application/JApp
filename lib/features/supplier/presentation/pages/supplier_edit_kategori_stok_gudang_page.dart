import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/kategori_stok_gudang.dart';
import '../providers/kategori_stok_gudang_provider.dart';

class SupplierEditKategoriStokGudangPage extends StatefulWidget {
  const SupplierEditKategoriStokGudangPage({
    super.key,
    required this.kategori,
    required this.provider,
  });

  final KategoriStokGudang kategori;
  final KategoriStokGudangProvider provider;

  @override
  State<SupplierEditKategoriStokGudangPage> createState() =>
      _SupplierEditKategoriStokGudangPageState();
}

class _SupplierEditKategoriStokGudangPageState
    extends State<SupplierEditKategoriStokGudangPage> {
  late final TextEditingController _namaCtrl;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.kategori.nama);
    _namaCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    super.dispose();
  }

  bool get _canSave {
    final nama = _namaCtrl.text.trim();
    return nama.isNotEmpty && nama != widget.kategori.nama;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(height: 1, color: AppColors.outlineVariant),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.x6),
                children: [
                  Text(
                    'Nama Kategori',
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  TextFormField(
                    controller: _namaCtrl,
                    style: AppTypography.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x3,
                        vertical: AppSpacing.x3,
                      ),
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
                        borderSide:
                            const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x6),
                  _HapusButton(onPressed: _onHapus),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.outlineVariant),
            Padding(
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
                    child: _SaveButton(enabled: _canSave, onPressed: _onSave),
                  ),
                ],
              ),
            ),
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
            widget.kategori.nama,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close_rounded, size: 22),
          ),
        ],
      ),
    );
  }

  void _onSave() {
    final updated = widget.kategori..nama = _namaCtrl.text.trim();
    widget.provider.updateKategori(updated);
    Navigator.of(context).pop();
  }

  void _onHapus() {
    showDialog<bool>(
      context: context,
      builder: (_) => const _HapusConfirmDialog(),
    ).then((confirmed) {
      if (confirmed != true || !mounted) return;
      widget.provider.removeKategori(widget.kategori.id);
      Navigator.of(context).pop();
    });
  }
}

class _HapusButton extends StatelessWidget {
  const _HapusButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.onError,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
        child: const Text('Hapus Kategori'),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.tertiary,
          foregroundColor: AppColors.onTertiary,
          disabledBackgroundColor: AppColors.tertiary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
        child: const Text('Save'),
      ),
    );
  }
}

class _HapusConfirmDialog extends StatelessWidget {
  const _HapusConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: AppRadius.toShape(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: const Icon(
                  Icons.close_rounded,
                  size: 22,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.priority_high_rounded,
                color: AppColors.onPrimary,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.x4),
            Text(
              'Apakah kamu yakin?',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(
              'Kategori yang dihapus tidak dapat dikembalikan.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.x5),
            Row(
              children: [
                Expanded(
                  child: _DialogBtn(
                    label: 'Tidak',
                    color: AppColors.outline,
                    textColor: AppColors.onSurface,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: AppSpacing.x3),
                Expanded(
                  child: _DialogBtn(
                    label: 'Ya',
                    color: AppColors.primary,
                    textColor: AppColors.onPrimary,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogBtn extends StatelessWidget {
  const _DialogBtn({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: AppRadius.sm,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.sm,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3),
          child: Center(
            child: Text(
              label,
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
