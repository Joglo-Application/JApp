import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../providers/order_provider.dart';

class OrderPanelHeader extends StatelessWidget {
  const OrderPanelHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final itemCount = context.watch<OrderProvider>().itemCount;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
            child: Text(
              'Current Order',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.onShell,
              ),
            ),
          ),
          if (itemCount > 0) ...[
            _ItemCountBadge(count: itemCount),
            const SizedBox(width: AppSpacing.x1),
            _ClearButton(),
          ],
        ],
      ),
    );
  }
}

class _ItemCountBadge extends StatelessWidget {
  const _ItemCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.full,
      ),
      child: Text(
        '$count',
        style: AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      color: AppColors.error,
      iconSize: 20,
      tooltip: 'Clear order',
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
      onPressed: () => context.read<OrderProvider>().clear(),
    );
  }
}
