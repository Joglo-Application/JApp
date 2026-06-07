import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/currency_formatter.dart';

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
        _QrisHeader(orderTotal: widget.orderTotal, onClose: widget.onClose),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  _dotFormat(widget.orderTotal.toInt().toString()),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 48),
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
                      borderSide:
                          BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
        GestureDetector(
          onTap: widget.onDone,
          child: const ColoredBox(
            color: AppColors.tertiary,
            child: SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  'SELESAI',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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

  String _dotFormat(String digits) {
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    return buf.toString();
  }
}

class _QrisHeader extends StatelessWidget {
  const _QrisHeader({required this.orderTotal, required this.onClose});

  final double orderTotal;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.qr_code, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QRIS',
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(orderTotal),
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
