import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

/// Shared form field components used by [AddMenuForm] and [CustomItemForm].

class FormAvatarBadge extends StatelessWidget {
  const FormAvatarBadge({super.key, required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.sm,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: AppTypography.textTheme.titleSmall?.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class FormCurrencyIcon extends StatelessWidget {
  const FormCurrencyIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.attach_money_rounded,
        color: AppColors.onPrimary,
        size: 18,
      ),
    );
  }
}

class FormPriceField extends StatelessWidget {
  const FormPriceField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const FormCurrencyIcon(),
        const SizedBox(width: AppSpacing.x3),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Harga',
              hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.x2,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.outline),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
