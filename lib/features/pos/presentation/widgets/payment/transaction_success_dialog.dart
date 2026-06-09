import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import 'payment_panel_widgets.dart';

class TransactionSuccessDialog extends StatefulWidget {
  const TransactionSuccessDialog({
    super.key,
    required this.total,
    required this.cashPaid,
    required this.onNew,
    required this.onPrint,
  });

  final double total;
  final double cashPaid;
  final VoidCallback onNew;
  final VoidCallback onPrint;

  @override
  State<TransactionSuccessDialog> createState() =>
      _TransactionSuccessDialogState();
}

class _TransactionSuccessDialogState extends State<TransactionSuccessDialog> {
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  double get _change =>
      (widget.cashPaid - widget.total).clamp(0, double.infinity);

  String _fmt(double n) =>
      n <= 0 ? '0' : formatAmountDisplay(n.toInt().toString());

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 32),
      shape: AppRadius.toShape(AppRadius.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogHeader(onClose: widget.onNew),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, AppSpacing.x5, 28, 28),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.onPrimary,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '(KODE TRANSAKSI)',
                    style: AppTypography.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AmountCol(
                        label: 'Total Pembayaran',
                        value: _fmt(widget.cashPaid),
                      ),
                      const SizedBox(width: AppSpacing.x10),
                      _AmountCol(
                        label: 'Kembalian',
                        value: _fmt(_change),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x6),
                  _ReceiptField(
                    controller: _emailCtrl,
                    hint: 'Email Resi',
                    icon: Icons.email_rounded,
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  _ReceiptField(
                    controller: _phoneCtrl,
                    hint: 'SMS/WhatsApp Resi',
                    icon: Icons.phone_rounded,
                  ),
                  const SizedBox(height: AppSpacing.x6),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'Cetak Resi',
                          icon: Icons.print_rounded,
                          color: const Color(0xFF2979FF),
                          onTap: widget.onPrint,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x3),
                      Expanded(
                        child: _ActionButton(
                          label: 'Baru',
                          icon: Icons.add_rounded,
                          color: AppColors.tertiary,
                          onTap: widget.onNew,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: AppRadiusValue.md),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded, color: AppColors.onPrimary),
        ),
      ),
    );
  }
}

class _AmountCol extends StatelessWidget {
  const _AmountCol({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.textTheme.bodyMedium
              ?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.textTheme.headlineSmall),
      ],
    );
  }
}

class _ReceiptField extends StatelessWidget {
  const _ReceiptField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.x2),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.x2),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadius.sm,
          ),
          child: Icon(icon, color: AppColors.onPrimary, size: 20),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: AppRadius.toShape(AppRadius.sm),
        textStyle: AppTypography.textTheme.labelLarge,
      ),
    );
  }
}
