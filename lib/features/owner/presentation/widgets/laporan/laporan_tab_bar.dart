import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';

class LaporanTabBar extends StatelessWidget {
  const LaporanTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  static const _tabs = ['Produk', 'Ringkasan', 'Guest Resto', 'Pembayaran'];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = index == selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTabSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3),
                  decoration: isSelected
                      ? BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppRadius.sm,
                        )
                      : null,
                  alignment: Alignment.center,
                  child: Text(
                    _tabs[index],
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.primary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
