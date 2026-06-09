import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import 'payment_panel_widgets.dart';

class QrisPaymentPanel extends StatefulWidget {
  const QrisPaymentPanel({
    super.key,
    required this.orderTotal,
    required this.onDone,
    required this.onClose,
  });

  final double orderTotal;
  final VoidCallback onDone;
  final VoidCallback onClose;

  @override
  State<QrisPaymentPanel> createState() => _QrisPaymentPanelState();
}

class _QrisPaymentPanelState extends State<QrisPaymentPanel> {
  final _refCtrl = TextEditingController();

  @override
  void dispose() {
    _refCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PaymentPanelHeader(
          icon: Icons.qr_code,
          title: 'QRIS',
          orderTotal: widget.orderTotal,
          onClose: widget.onClose,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x10,
              vertical: AppSpacing.x8,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.x4),
                Text(
                  formatAmountDisplay(widget.orderTotal.toInt().toString()),
                  style: AppTypography.textTheme.displaySmall?.copyWith(
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.x12),
                TextField(
                  controller: _refCtrl,
                  decoration: InputDecoration(
                    labelText: 'Ref. Pembayaran',
                    labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.x3),
                Text(
                  'The payment amount is being sent to the EDC Machine',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: widget.onDone,
          child: ColoredBox(
            color: AppColors.tertiary,
            child: SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  'SELESAI',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.onTertiary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
