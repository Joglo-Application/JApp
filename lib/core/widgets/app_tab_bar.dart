import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A stateless tab bar that matches the design's gold underline indicator style.
///
/// Does not use [TabController] — the parent owns [selectedIndex] and reacts
/// to [onTabSelected]. This keeps the widget pure and avoids [TickerProvider]
/// boilerplate in callers that already manage state.
///
/// Tabs are distributed equally across the available width. For long or
/// variable-count tab lists on small screens, wrap in a [SingleChildScrollView].
///
/// ```dart
/// AppTabBar(
///   tabs: const ['Produk', 'Custom'],
///   selectedIndex: _tabIndex,
///   onTabSelected: (i) => setState(() => _tabIndex = i),
/// )
/// ```
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.backgroundColor,
    this.indicatorHeight = 3,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  /// Background color of the tab bar container. Defaults to [AppColors.surface].
  final Color? backgroundColor;

  /// Thickness of the active-tab underline indicator. Default: 3 dp.
  final double indicatorHeight;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        border: const Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: _TabItem(
              label: tabs[index],
              isSelected: isSelected,
              indicatorHeight: indicatorHeight,
              onTap: () => onTabSelected(index),
            ),
          );
        }),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.indicatorHeight,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final double indicatorHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x3,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: indicatorHeight,
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
