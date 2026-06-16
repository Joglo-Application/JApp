import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Top bar shared by every Pengaturan detail page — a green "Simpan" button
/// on the left, the page [title] plus a close (X) action on the right.
class PengaturanDetailTopBar extends StatelessWidget {
  const PengaturanDetailTopBar({
    super.key,
    required this.title,
    required this.onSave,
    required this.onClose,
  });

  final String title;
  final VoidCallback onSave;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          FilledButton(
            onPressed: onSave,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              foregroundColor: AppColors.onTertiary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x5,
                vertical: AppSpacing.x3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.x2),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Simpan',
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: AppColors.onTertiary,
              ),
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          GestureDetector(
            onTap: onClose,
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.onSurface,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bold group title — e.g. "Pajak Toko", "Profil Toko".
class PengaturanSectionHeader extends StatelessWidget {
  const PengaturanSectionHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.textTheme.titleSmall?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Small muted helper text printed above a field — e.g. "Persentase Pajak".
class PengaturanSubLabel extends StatelessWidget {
  const PengaturanSubLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.textTheme.bodySmall?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

/// Rounded, bordered container shared by every standalone settings row.
class PengaturanSoloContainer extends StatelessWidget {
  const PengaturanSoloContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.x3),
      ),
      child: child,
    );
  }
}

/// Label + value row that navigates elsewhere on tap (e.g. opens a picker).
class PengaturanSoloNavRow extends StatelessWidget {
  const PengaturanSoloNavRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PengaturanSoloContainer(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.x3),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x4,
          ),
          child: Row(
            children: [
              Text(
                label,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Borderless text input inside the standard solo container.
class PengaturanSoloTextField extends StatelessWidget {
  const PengaturanSoloTextField({
    super.key,
    required this.controller,
    this.keyboardType,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return PengaturanSoloContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x1,
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurface,
          ),
          decoration: const InputDecoration(
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            isDense: true,
          ),
        ),
      ),
    );
  }
}

/// Label + switch row inside the standard solo container.
class PengaturanSoloToggleRow extends StatelessWidget {
  const PengaturanSoloToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return PengaturanSoloContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.onPrimary,
              activeTrackColor: AppColors.primary,
              inactiveThumbColor: AppColors.onSurfaceVariant,
              inactiveTrackColor: AppColors.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }
}
