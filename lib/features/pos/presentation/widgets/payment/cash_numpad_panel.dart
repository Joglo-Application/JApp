import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/currency_formatter.dart';

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
    if (cashRaw.isEmpty) return _dotFormat(orderTotal.toInt().toString());
    if (cashRaw == '0') return '0';
    return _dotFormat(cashRaw);
  }

  String _dotFormat(String digits) {
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(orderTotal: orderTotal, onClose: onClose),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              _QuickChip(
                label: '+ 50.000',
                onTap: () => onQuickAmount(50000),
              ),
              const SizedBox(width: 10),
              _QuickChip(
                label: '+ 100.000',
                onTap: () => onQuickAmount(100000),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              _displayAmount,
              style: const TextStyle(
                fontFamily: 'Inter',
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

class _Header extends StatelessWidget {
  const _Header({required this.orderTotal, required this.onClose});

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
              child: const Icon(Icons.payments_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TUNAI',
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: AppTypography.textTheme.labelLarge
            ?.copyWith(color: AppColors.primary),
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
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
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
    return GestureDetector(
      onTap: onTap,
      child: const ColoredBox(
        color: AppColors.tertiary,
        child: SizedBox(
          height: 60,
          child: Center(
            child: Text(
              'BAYAR',
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
    );
  }
}
