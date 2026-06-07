import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/order_item.dart';
import '../../providers/order_provider.dart';

// ── Full-screen discount input page ──────────────────────────────────────────

class DiskonInputPage extends StatefulWidget {
  const DiskonInputPage({super.key});

  @override
  State<DiskonInputPage> createState() => _DiskonInputPageState();
}

class _DiskonInputPageState extends State<DiskonInputPage> {
  String _value = '';
  DiscountType _type = DiscountType.amount;

  void _onKey(String key) {
    setState(() {
      if (key == 'C') {
        _value = '';
      } else if (key == '.' && _value.contains('.')) {
        return;
      } else if (_value.isEmpty && key == '.') {
        _value = '0.';
      } else {
        _value += key;
      }
    });
  }

  void _save() {
    final val = double.tryParse(_value) ?? 0;
    context.read<OrderProvider>().setOrderDiscount(val, _type);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: AppColors.primary,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: AppColors.onPrimary),
                iconSize: 26,
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: AppColors.surface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x6,
                        vertical: AppSpacing.x8,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Tipe Diskon',
                            textAlign: TextAlign.center,
                            style: AppTypography.textTheme.headlineMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x8),
                          _TypeButton(
                            label: 'Persen',
                            icon: Icons.percent_rounded,
                            selected: _type == DiscountType.percent,
                            onTap: () => setState(() => _type = DiscountType.percent),
                          ),
                          const SizedBox(height: AppSpacing.x3),
                          _TypeButton(
                            label: 'Rp',
                            icon: Icons.attach_money_rounded,
                            selected: _type == DiscountType.amount,
                            onTap: () => setState(() => _type = DiscountType.amount),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          color: AppColors.surface,
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.x4, AppSpacing.x4, AppSpacing.x4, AppSpacing.x2,
                          ),
                          alignment: Alignment.centerRight,
                          child: Text(
                            _value.isEmpty ? '0' : _value,
                            style: AppTypography.textTheme.headlineMedium?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(child: _Numpad(onKey: _onKey)),
                        InkWell(
                          onTap: _save,
                          child: Container(
                            color: AppColors.tertiary,
                            height: 56,
                            alignment: Alignment.center,
                            child: Text(
                              'SIMPAN',
                              style: AppTypography.textTheme.titleMedium?.copyWith(
                                color: AppColors.onTertiary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

// ── Numpad ────────────────────────────────────────────────────────────────────

class _Numpad extends StatelessWidget {
  const _Numpad({required this.onKey});

  final ValueChanged<String> onKey;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['C', '0', '.'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _rows
            .map(
              (row) => Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: row
                      .map((key) => Expanded(
                            child: _NumKey(label: key, onTap: () => onKey(key)),
                          ))
                      .toList(),
                ),
              ),
            )
            .toList(),
      ),
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
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.headlineSmall?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Type button ───────────────────────────────────────────────────────────────

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x4,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.primaryContainer,
          borderRadius: AppRadius.md,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected ? AppColors.primary : AppColors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            Text(
              label,
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: selected ? AppColors.onPrimary : AppColors.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
