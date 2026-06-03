import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_filter_chip.dart';
import '../../providers/menu_provider.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2,
        ),
        child: Row(
          children: [
            AppFilterChip(
              label: 'All',
              selected: menu.selectedCategoryId == null,
              onSelected: (_) => menu.selectCategory(null),
              leadingIcon: Icons.grid_view_rounded,
            ),
            ...menu.categories.map(
              (cat) => Padding(
                padding: const EdgeInsets.only(left: AppSpacing.x2),
                child: AppFilterChip(
                  label: cat.name,
                  selected: menu.selectedCategoryId == cat.id,
                  onSelected: (_) => menu.selectCategory(cat.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
