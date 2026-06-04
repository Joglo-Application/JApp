import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import 'order_columns.dart';

class OrderTableHeader extends StatelessWidget {
  const OrderTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.textTheme.labelSmall?.copyWith(
      color: AppColors.onShell,
      letterSpacing: 0.5,
    );

    return ColoredBox(
      color: Colors.grey.shade700,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2,
        ),
        child: Row(
          children: [
            Expanded(child: Text('Item', style: style)),
            SizedBox(
              width: OrderColumns.qty,
              child: Text('Qty', style: style, textAlign: TextAlign.center),
            ),
            SizedBox(
              width: OrderColumns.total,
              child: Text('Total', style: style, textAlign: TextAlign.end),
            ),
          ],
        ),
      ),
    );
  }
}
