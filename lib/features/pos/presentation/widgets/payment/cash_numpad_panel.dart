import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import 'payment_panel_widgets.dart';

class CashNumpadPanel extends StatelessWidget {
  const CashNumpadPanel({
    super.key,
    required this.orderTotal,
    required this.cashRaw,
    required this.onNumpad,
    required this.onQuickAmount,
    required this.onPay,
    required this.onClose,
  });

  final double orderTotal;
  final String cashRaw;
  final ValueChanged<String> onNumpad;
  final ValueChanged<double> onQuickAmount;
  final VoidCallback onPay;
  final VoidCallback onClose;

  String get _displayAmount {
    if (cashRaw.isEmpty) return formatAmountDisplay(orderTotal.toInt().toString());
    if (cashRaw == '0') return '0';
    return formatAmountDisplay(cashRaw);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PaymentPanelHeader(
          icon: Icons.payments_rounded,
          title: 'TUNAI',
          orderTotal: orderTotal,
          onClose: onClose,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x4,
            AppSpacing.x3,
            AppSpacing.x4,
            0,
          ),
          child: Row(
            children: [
              _QuickChip(
                label: '+ 50.000',
                onTap: () => onQuickAmount(50000),
              ),
              const SizedBox(width: AppSpacing.x2 + 2),
              _QuickChip(
                label: '+ 100.000',
                onTap: () => onQuickAmount(100000),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x6,
            vertical: AppSpacing.x3,
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              _displayAmount,
              style: AppTypography.textTheme.displaySmall?.copyWith(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.outline),
        Expanded(child: _Numpad(onKey: onNumpad)),
        _PayButton(onTap: onPay),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: AppTypography.textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _Numpad extends StatelessWidget {
  const _Numpad({required this.onKey});

  final ValueChanged<String> onKey;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['C', '0', '00'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rows.map((row) {
        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: row.map((key) {
              return Expanded(
                child: _NumKey(label: key, onTap: () => onKey(key)),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _NumKey extends StatelessWidget {
  const _NumKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.outline, width: 0.5),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ColoredBox(
        color: AppColors.tertiary,
        child: SizedBox(
          height: 60,
          child: Center(
            child: Text(
              'BAYAR',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.onTertiary,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
