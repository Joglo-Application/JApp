import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../providers/order_provider.dart';

class OrderSummaryTotals extends StatelessWidget {
  const OrderSummaryTotals({super.key});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    final serviceRate = order.taxRate / 2;
    final taxRate = order.taxRate / 2;

    final namaKasir = context.select<AuthProvider, String>(
      (auth) => auth.user?.namaUser ?? '-',
    );

    return Column(
      children: [
        if (order.orderDiscountAmount > 0)
          _SummaryRow(
            label: 'Diskon :',
            value: '-${CurrencyFormatter.format(order.orderDiscountAmount)}',
            shaded: true,
          ),
        _SummaryRow(
          label: 'Subtotal :',
          value: CurrencyFormatter.format(order.subtotal),
          shaded: false,
        ),
        _SummaryRow(
          label: 'Biaya Layanan : ${(serviceRate * 100).toStringAsFixed(0)}%',
          value: CurrencyFormatter.format(order.subtotal * serviceRate),
          shaded: true,
        ),
        _SummaryRow(
          label: 'Pajak : ${(taxRate * 100).toStringAsFixed(0)}%',
          value: CurrencyFormatter.format(order.subtotal * taxRate),
          shaded: false,
        ),
        _SummaryRow(
          label: 'Jumlah Item : ${order.totalQty}',
          value: '',
          shaded: true,
        ),
        _SummaryRow(
          label: 'Dilayani Oleh : $namaKasir',
          value: '',
          shaded: false,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.shaded,
  });

  final String label;
  final String value;
  final bool shaded;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: shaded ? AppColors.background : AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const Spacer(),
            if (value.isNotEmpty)
              Text(
                value,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
