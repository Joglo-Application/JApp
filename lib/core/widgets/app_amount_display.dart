import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A large currency amount display used on payment entry and summary screens.
///
/// Shows an optional [label] above the amount, then the [currencySymbol]
/// baseline-aligned with the [amount] string.
///
/// The widget is purely presentational — formatting and value management
/// belong to the caller.
///
/// ```dart
/// AppAmountDisplay(
///   amount: '20.000',
///   label: 'Total Bayar',
/// )
///
/// // On dark background (e.g. shell panel):
/// AppAmountDisplay(
///   amount: '20.000',
///   onDark: true,
/// )
/// ```
class AppAmountDisplay extends StatelessWidget {
  const AppAmountDisplay({
    super.key,
    required this.amount,
    this.currencySymbol = 'Rp',
    this.label,
    this.onDark = false,
    this.alignment = Alignment.centerLeft,
  });

  /// The formatted amount string (e.g. `"20.000"` or `"0"`).
  final String amount;

  /// Currency prefix. Defaults to `"Rp"`.
  final String currencySymbol;

  /// Optional label rendered above the amount row in [bodyMedium].
  final String? label;

  /// When true, uses [AppColors.onShell] for all text — for dark panel use.
  final bool onDark;

  /// Alignment of the amount content. Defaults to [Alignment.centerLeft].
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final labelColor =
        onDark ? AppColors.onShell.withValues(alpha: 0.7) : AppColors.onSurfaceVariant;
    final symbolColor =
        onDark ? AppColors.onShell : AppColors.onSurface;
    final amountColor =
        onDark ? AppColors.onShell : AppColors.primary;

    return Align(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: alignment == Alignment.center
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: labelColor,
              ),
            ),
            const SizedBox(height: AppSpacing.x1),
          ],
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currencySymbol,
                style: AppTypography.currencySymbol.copyWith(
                  color: symbolColor,
                ),
              ),
              const SizedBox(width: AppSpacing.x1),
              Text(
                amount,
                style: AppTypography.price.copyWith(
                  color: amountColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
