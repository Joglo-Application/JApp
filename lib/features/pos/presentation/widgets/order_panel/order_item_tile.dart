import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/order_item.dart';
import '../../providers/order_provider.dart';
import 'order_columns.dart';

class OrderItemTile extends StatelessWidget {
  const OrderItemTile({super.key, required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            child: _QtyStepper(productId: item.productId, qty: item.quantity),
          ),
          SizedBox(
            width: OrderColumns.total,
            child: _ItemTotal(item: item),
          ),
        ],
      ),
    );
  }
}

class _ItemName extends StatelessWidget {
  const _ItemName({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            item.name,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.x2),
        _RemoveButton(productId: item.productId),
      ],
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

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.productId, required this.qty});

  final String productId;
  final int qty;

  @override
  Widget build(BuildContext context) {
    final order = context.read<OrderProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepButton(icon: Icons.remove, onTap: () => order.decrement(productId)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2),
          child: Text(
            '$qty',
            style: AppTypography.quantity.copyWith(color: AppColors.onSurface),
          ),
        ),
        _StepButton(icon: Icons.add, onTap: () => order.increment(productId)),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.xs,
          border: Border.all(color: AppColors.outline),
        ),
        child: Icon(icon, size: 12, color: AppColors.onSurface),
      ),
    );
  }
}
