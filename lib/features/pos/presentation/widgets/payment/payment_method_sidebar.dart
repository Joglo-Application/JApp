import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/payment_method.dart';

class PaymentMethodSidebar extends StatelessWidget {
  const PaymentMethodSidebar({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.itemCount,
  });

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onSelect;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.onSurfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Text(
              'PILIH METODE PEMBAYARAN',
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: AppColors.onShell,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView(
              children: PaymentMethod.values.map((m) {
                return _MethodTile(
                  method: m,
                  isSelected: m == selected,
                  onTap: m.isActive ? () => onSelect(m) : null,
                );
              }).toList(),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(16),
          //   child: DefaultTextStyle(
          //     style: AppTypography.textTheme.bodySmall!.copyWith(
          //       color: AppColors.onShell.withValues(alpha: 0.6),
          //     ),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text('Jumlah Item : $itemCount'),
          //         const SizedBox(height: 4),
          //         const Text('Dilayani Oleh : Kasir01'),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback? onTap;

  IconData get _icon => switch (method) {
        PaymentMethod.tunai => Icons.payments_rounded,
        PaymentMethod.qris => Icons.qr_code,
        PaymentMethod.debitCard => Icons.credit_card,
        PaymentMethod.qrisNetzme => Icons.qr_code_2,
      };

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final fg = isDisabled
        ? AppColors.onShell.withValues(alpha: 0.35)
        : AppColors.onShell;
    final bg = isSelected ? AppColors.primary : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: ColoredBox(
        color: bg,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_icon, color: fg, size: 22),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: fg,
                    ),
                  ),
                  if (!method.isActive)
                    Text(
                      'Belum Aktif',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: fg.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
