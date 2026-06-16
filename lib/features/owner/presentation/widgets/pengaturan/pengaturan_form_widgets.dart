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

/// Single-select dropdown inside the standard solo container — closed state
/// shows the current [value] with a leading chevron. Tapping it raises a
/// scrim-backed popup (anchored over the field, same width) with a
/// primary-colored header showing [placeholder] + a close action, and
/// [options] listed below to pick from.
class PengaturanSoloDropdownField extends StatefulWidget {
  const PengaturanSoloDropdownField({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.placeholder = 'Pilih',
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String placeholder;

  @override
  State<PengaturanSoloDropdownField> createState() =>
      _PengaturanSoloDropdownFieldState();
}

class _PengaturanSoloDropdownFieldState
    extends State<PengaturanSoloDropdownField> {
  final _fieldKey = GlobalKey();
  OverlayEntry? _overlay;

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }

  void _open() {
    final box = _fieldKey.currentContext!.findRenderObject()! as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;

    _overlay?.remove();
    _overlay = OverlayEntry(
      builder: (_) => _PengaturanDropdownPopup(
        top: offset.dy,
        left: offset.dx,
        width: size.width,
        placeholder: widget.placeholder,
        options: widget.options,
        onSelect: (option) {
          widget.onChanged(option);
          _close();
        },
        onClose: _close,
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return PengaturanSoloContainer(
      child: InkWell(
        key: _fieldKey,
        onTap: _open,
        borderRadius: BorderRadius.circular(AppSpacing.x3),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x4,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.x2),
              Expanded(
                child: Text(
                  widget.value,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scrim-backed popup raised by [PengaturanSoloDropdownField] — dims the
/// rest of the screen and floats a gold header + option list at the
/// field's exact position/width.
class _PengaturanDropdownPopup extends StatelessWidget {
  const _PengaturanDropdownPopup({
    required this.top,
    required this.left,
    required this.width,
    required this.placeholder,
    required this.options,
    required this.onSelect,
    required this.onClose,
  });

  final double top;
  final double left;
  final double width;
  final String placeholder;
  final List<String> options;
  final ValueChanged<String> onSelect;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: const ColoredBox(
              color: AppColors.scrim,
              child: SizedBox.expand(),
            ),
          ),
          Positioned(
            top: top,
            left: left,
            width: width,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(AppSpacing.x3),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PengaturanDropdownPopupHeader(
                    placeholder: placeholder,
                    onClose: onClose,
                  ),
                  for (final option in options) ...[
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.outlineVariant,
                    ),
                    _PengaturanDropdownOptionRow(
                      label: option,
                      onTap: () => onSelect(option),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PengaturanDropdownPopupHeader extends StatelessWidget {
  const _PengaturanDropdownPopupHeader({
    required this.placeholder,
    required this.onClose,
  });

  final String placeholder;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x4,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                placeholder,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x2),
            Container(
              width: 1,
              height: 20,
              color: AppColors.onPrimary.withValues(alpha: 0.4),
            ),
            const SizedBox(width: AppSpacing.x2),
            GestureDetector(
              onTap: onClose,
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.onPrimary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PengaturanDropdownOptionRow extends StatelessWidget {
  const _PengaturanDropdownOptionRow({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x4,
          ),
          child: Text(
            label,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
            ),
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
