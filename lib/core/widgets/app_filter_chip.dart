import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A selectable chip for filter rows (category filters, tag selectors).
///
/// Selected state: [AppColors.primaryContainer] fill with
/// [AppColors.onPrimaryContainer] text.
/// Unselected state: outlined with [AppColors.outline] border.
///
/// ```dart
/// AppFilterChip(
///   label: 'Semua Kategori',
///   selected: _selectedIndex == 0,
///   onSelected: (_) => setState(() => _selectedIndex = 0),
/// )
/// ```
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.leadingIcon,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  /// Optional icon shown to the left of the label.
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x1 + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: AppRadius.full,
          border: Border.all(
            color: selected ? AppColors.primaryContainer : AppColors.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                size: 14,
                color: selected
                    ? AppColors.onPrimaryContainer
                    : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.x1),
            ],
            Text(
              label,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: selected
                    ? AppColors.onPrimaryContainer
                    : AppColors.onSurfaceVariant,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
