import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_colors.dart';

/// A row with a title on the left and an optional trailing widget on the right.
///
/// Used for panel headers, section labels, and any row that combines
/// a heading with an action (e.g. edit icon, count badge, "See all" link).
///
/// ```dart
/// AppSectionHeader(
///   title: 'Order Items',
///   trailing: Text('3 items'),
/// )
/// ```
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
  });

  final String title;

  /// Optional widget anchored to the right of the row.
  final Widget? trailing;

  /// Overrides the default vertical padding (horizontal padding is always 0).
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(vertical: AppSpacing.x3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
