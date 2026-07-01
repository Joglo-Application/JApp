import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../owner/domain/entities/stok_gudang_item.dart';

/// Shared building blocks for the inventori product forms (tambah + edit).

// ── Labels ─────────────────────────────────────────────────────────────────────

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.isRequired = false});
  final String text;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    if (!isRequired) {
      return Text(
        text,
        style: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return RichText(
      text: TextSpan(
        text: text,
        style: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class SubLabel extends StatelessWidget {
  const SubLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.textTheme.bodySmall?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

// ── Outlined text input ───────────────────────────────────────────────────────

class OutlinedInput extends StatelessWidget {
  const OutlinedInput({
    super.key,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.prefix,
    this.hint,
    this.maxLines = 1,
    this.enabled = true,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefix;
  final String? hint;
  final int maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      enabled: enabled,
      style: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        prefixText: prefix,
        hintText: hint,
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        filled: !enabled,
        fillColor: AppColors.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

// ── Simpan button ─────────────────────────────────────────────────────────────

class SimpanButton extends StatelessWidget {
  const SimpanButton({super.key, required this.enabled, required this.onTap});
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x6,
          vertical: AppSpacing.x3,
        ),
        decoration: BoxDecoration(
          color: enabled ? AppColors.tertiary : AppColors.outline,
          borderRadius: AppRadius.sm,
        ),
        child: Text(
          'Simpan',
          style: AppTypography.textTheme.titleSmall?.copyWith(
            color: enabled ? AppColors.onTertiary : AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Small green "Simpan" pill used next to a field being edited inline.
class SmallSimpanButton extends StatelessWidget {
  const SmallSimpanButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x2,
        ),
        decoration: BoxDecoration(
          color: AppColors.tertiary,
          borderRadius: AppRadius.sm,
        ),
        child: Text(
          'Simpan',
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.onTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Small gold pencil button that unlocks a field for inline editing.
class EditPencilButton extends StatelessWidget {
  const EditPencilButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.x2),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.sm,
        ),
        child: const Icon(
          Icons.edit_rounded,
          size: 16,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}

// ── Tambah small button ───────────────────────────────────────────────────────

class TambahSmallButton extends StatelessWidget {
  const TambahSmallButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x2,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded,
                size: 16, color: AppColors.onPrimary),
            const SizedBox(width: AppSpacing.x1),
            Text(
              'Tambah',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Resep entry ────────────────────────────────────────────────────────────────

class ResepEntry {
  ResepEntry(this.item, {String initialJumlah = ''})
      : jumlah = TextEditingController(text: initialJumlah);
  final StokGudangItem item;
  final TextEditingController jumlah;

  void dispose() => jumlah.dispose();
}

class ResepEntryRow extends StatelessWidget {
  const ResepEntryRow({super.key, required this.entry, required this.onRemove});
  final ResepEntry entry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final label =
        '${entry.item.nama} - ${entry.item.unitProduk} (${entry.item.qtyStok})';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close_rounded,
                  size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.x2),
            Expanded(
              child: Text(
                label,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2),
        OutlinedInput(
          controller: entry.jumlah,
          hint: 'Jumlah',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }
}

// ── Kategori dialog ───────────────────────────────────────────────────────────

class KategoriDialog extends StatelessWidget {
  const KategoriDialog({
    super.key,
    required this.selected,
    required this.options,
    required this.onSelect,
  });
  final String? selected;
  final List<String> options;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: AppRadius.toShape(AppRadius.lg),
      backgroundColor: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x4,
              AppSpacing.x4,
              AppSpacing.x2,
              AppSpacing.x2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Pilih Kategori',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 22),
                  color: AppColors.onSurface,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),
          ...options.map(
            (k) => InkWell(
              onTap: () {
                onSelect(k);
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4,
                  vertical: AppSpacing.x3,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        k,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight:
                              k == selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (k == selected)
                      const Icon(Icons.check_rounded,
                          size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
        ],
      ),
    );
  }
}
