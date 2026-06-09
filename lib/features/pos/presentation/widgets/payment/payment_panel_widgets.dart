import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/currency_formatter.dart';

/// Shared header used by [CashNumpadPanel] and [QrisPaymentPanel].
class PaymentPanelHeader extends StatelessWidget {
  const PaymentPanelHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.orderTotal,
    required this.onClose,
  });

  final IconData icon;
  final String title;
  final double orderTotal;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: 10,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withValues(alpha: 0.2),
                borderRadius: AppRadius.sm,
              ),
              child: Icon(icon, color: AppColors.onPrimary, size: 22),
            ),
            const SizedBox(width: AppSpacing.x3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: AppColors.onPrimary,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(orderTotal),
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: AppColors.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Formats a raw digit string with dot thousands separators.
/// e.g. "50000" → "50.000". Used in numpad amount displays.
String formatAmountDisplay(String digits) {
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  return buf.toString();
}
