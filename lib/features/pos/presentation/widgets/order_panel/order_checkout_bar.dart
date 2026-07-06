import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../providers/order_provider.dart';
import '../shared/pin_supervisor_dialog.dart';
import 'cancel_order_dialog.dart';

class OrderCheckoutBar extends StatelessWidget {
  const OrderCheckoutBar({super.key, this.onCheckout});

  final VoidCallback? onCheckout;

  Future<void> _handleCancel(BuildContext context) async {
    final alasan = await CancelOrderDialog.show(context);
    if (alasan == null || !context.mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const PinSupervisorDialog(),
    );
    if (ok == true && context.mounted) {
      context.read<OrderProvider>().clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(
            child: _BarButton(
              label: 'CANCEL',
              color: AppColors.error,
              onPressed: order.isEmpty ? null : () => _handleCancel(context),
            ),
          ),
          Expanded(
            child: _BarButton(
              label: CurrencyFormatter.format(order.total),
              color: AppColors.tertiary,
              onPressed: order.isEmpty ? null : (onCheckout ?? () {}),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final effective = onPressed != null ? color : color.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onPressed,
      child: ColoredBox(
        color: effective,
        child: Center(
          child: Text(
            label,
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
