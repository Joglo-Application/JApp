import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AppBadgeVariant { success, danger, warning, neutral }

/// A pill-shaped status badge used for order status, payment state,
/// stock indicators, and discount labels.
///
/// ```dart
/// AppStatusBadge(label: 'Paid', variant: AppBadgeVariant.success)
/// AppStatusBadge(label: '-20%', variant: AppBadgeVariant.warning)
/// ```
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.icon,
  });

  final String label;
  final AppBadgeVariant variant;

  /// Optional leading icon inside the badge.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(variant);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: AppSpacing.x1,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppRadius.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: colors.foreground),
            const SizedBox(width: AppSpacing.x1),
          ],
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeColors _resolveColors(AppBadgeVariant v) => switch (v) {
        AppBadgeVariant.success => _BadgeColors(
            background: AppColors.tertiaryContainer,
            foreground: AppColors.onTertiaryContainer,
          ),
        AppBadgeVariant.danger => _BadgeColors(
            background: AppColors.errorContainer,
            foreground: AppColors.onErrorContainer,
          ),
        AppBadgeVariant.warning => _BadgeColors(
            background: AppColors.warningContainer,
            foreground: AppColors.onWarningContainer,
          ),
        AppBadgeVariant.neutral => _BadgeColors(
            background: AppColors.surfaceContainerHighest,
            foreground: AppColors.onSurfaceVariant,
          ),
      };
}

class _BadgeColors {
  const _BadgeColors({required this.background, required this.foreground});
  final Color background;
  final Color foreground;
}
