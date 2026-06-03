import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../providers/order_provider.dart';
import 'order_item_tile.dart';

class OrderItemList extends StatelessWidget {
  const OrderItemList({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<OrderProvider>().items;

    if (items.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        color: AppColors.outlineVariant,
      ),
      itemBuilder: (_, index) => OrderItemTile(item: items[index]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 48,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.2),
          ),
          const SizedBox(height: AppSpacing.x3),
          Text(
            'No items yet',
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          Text(
            'Tap a product to add it here',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.28),
            ),
          ),
        ],
      ),
    );
  }
}
