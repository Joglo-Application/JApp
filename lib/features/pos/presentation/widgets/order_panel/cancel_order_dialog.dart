import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_button.dart';

/// Asks for the cancellation reason before an order is cleared.
///
/// Pops with the entered reason when "Lanjutkan" is tapped, or `null` when
/// dismissed.
class CancelOrderDialog extends StatefulWidget {
  const CancelOrderDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const CancelOrderDialog(),
    );
  }

  @override
  State<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  final _alasanCtrl = TextEditingController();

  @override
  void dispose() {
    _alasanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 420,
        child: ClipRRect(
          borderRadius: AppRadius.lg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              ColoredBox(
                color: AppColors.error,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x4,
                    vertical: AppSpacing.x3,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.delete_rounded,
                          color: AppColors.onError, size: 22),
                      const SizedBox(width: AppSpacing.x3),
                      Expanded(
                        child: Text(
                          'Cancel',
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            color: AppColors.onError,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.onError),
                        iconSize: 22,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
              // Body
              ColoredBox(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x6,
                    vertical: AppSpacing.x8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _alasanCtrl,
                        style: AppTypography.textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Alasan',
                          hintStyle:
                              AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.error),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.error, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x8),
                      AppButton(
                        label: 'Lanjutkan',
                        isDestructive: true,
                        onPressed: () =>
                            Navigator.of(context).pop(_alasanCtrl.text.trim()),
                      ),
                    ],
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
