import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AppActionVariant { primary, success, danger }

/// A two-button cancel / confirm row used at the bottom of every screen,
/// bottom sheet, and dialog in the app.
///
/// The cancel button is always outlined. The confirm button is filled and
/// its color is driven by [confirmVariant]:
///   - [AppActionVariant.primary]  → gold  (default, general actions)
///   - [AppActionVariant.success]  → green (checkout, payment confirm)
///   - [AppActionVariant.danger]   → red   (destructive confirm)
///
/// Set [isLoading] to replace the confirm label with a spinner while an
/// async operation is in progress.
///
/// ```dart
/// AppActionRow(
///   cancelLabel: 'Batal',
///   confirmLabel: 'Bayar',
///   onCancel: () => Navigator.pop(context),
///   onConfirm: _handlePayment,
///   confirmVariant: AppActionVariant.success,
///   isLoading: _isProcessing,
/// )
/// ```
class AppActionRow extends StatelessWidget {
  const AppActionRow({
    super.key,
    required this.cancelLabel,
    required this.confirmLabel,
    this.onCancel,
    this.onConfirm,
    this.confirmVariant = AppActionVariant.primary,
    this.isLoading = false,
  });

  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final AppActionVariant confirmVariant;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CancelButton(
            label: cancelLabel,
            onPressed: onCancel,
          ),
        ),
        const SizedBox(width: AppSpacing.x3),
        Expanded(
          child: _ConfirmButton(
            label: confirmLabel,
            onPressed: isLoading ? null : onConfirm,
            variant: confirmVariant,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.outline),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
        child: Text(label),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.label,
    required this.variant,
    required this.isLoading,
    this.onPressed,
  });

  final String label;
  final AppActionVariant variant;
  final bool isLoading;
  final VoidCallback? onPressed;

  Color get _background => switch (variant) {
        AppActionVariant.primary => AppColors.primary,
        AppActionVariant.success => AppColors.tertiary,
        AppActionVariant.danger  => AppColors.error,
      };

  Color get _foreground => switch (variant) {
        AppActionVariant.primary => AppColors.onPrimary,
        AppActionVariant.success => AppColors.onTertiary,
        AppActionVariant.danger  => AppColors.onError,
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _background,
          foregroundColor: _foreground,
          disabledBackgroundColor: _background.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _foreground,
                ),
              )
            : Text(label),
      ),
    );
  }
}
