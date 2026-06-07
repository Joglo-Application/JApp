import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/order_item.dart';
import '../../providers/order_provider.dart';
import '../../providers/pos_ui_provider.dart';
import 'order_columns.dart';

class OrderItemTile extends StatelessWidget {
  const OrderItemTile({super.key, required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<PosUiProvider>().editItem(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2 + 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _ItemName(item: item)),
            SizedBox(
              width: OrderColumns.qty,
              child: _QtyBadge(qty: item.quantity),
            ),
            SizedBox(
              width: OrderColumns.total,
              child: _ItemTotal(item: item),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemName extends StatelessWidget {
  const _ItemName({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = item.discount > 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.note.isNotEmpty)
                Text(
                  item.note,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.55),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: AppSpacing.x2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(item.unitPrice),
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                _discountLabel(item),
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(width: AppSpacing.x2),
        _RemoveButton(productId: item.productId),
      ],
    );
  }
}

class _QtyBadge extends StatelessWidget {
  const _QtyBadge({required this.qty});

  final int qty;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x2,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.xs,
          border: Border.all(color: AppColors.outline),
        ),
        child: Text(
          '×$qty',
          style: AppTypography.quantity.copyWith(color: AppColors.onSurface),
        ),
      ),
    );
  }
}

class _ItemTotal extends StatelessWidget {
  const _ItemTotal({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Text(
      CurrencyFormatter.format(item.subtotal),
      style: AppTypography.textTheme.bodySmall?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.end,
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<OrderProvider>().remove(productId),
      child: Icon(
        Icons.close,
        size: 14,
        color: AppColors.onSurface.withValues(alpha: 0.35),
      ),
    );
  }
}

String _discountLabel(OrderItem item) {
  final pct = item.discount.toStringAsFixed(0);
  final nominal = CurrencyFormatter.format(item.discountAmount);
  if (item.promoName != null) {
    return item.discountType == DiscountType.percent
        ? '${item.promoName} $pct%($nominal)'
        : '${item.promoName} ($nominal)';
  }
  return item.discountType == DiscountType.percent
      ? 'Disc. $pct% ($nominal)'
      : 'Disc. ($nominal)';
}
