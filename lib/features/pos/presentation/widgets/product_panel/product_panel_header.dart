import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_search_field.dart';
import '../../providers/menu_provider.dart';

class ProductPanelHeader extends StatefulWidget {
  const ProductPanelHeader({super.key});

  @override
  State<ProductPanelHeader> createState() => _ProductPanelHeaderState();
}

class _ProductPanelHeaderState extends State<ProductPanelHeader> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x2,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: AppSearchField(
                  controller: _searchCtrl,
                  hint: 'Cari produk…',
                  onChanged: context.read<MenuProvider>().search,
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              Expanded(
                flex: 1,
                child: const _CategoryFilterButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category filter button ────────────────────────────────────────────────────

class _CategoryFilterButton extends StatelessWidget {
  const _CategoryFilterButton();

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();

    final label = menu.selectedCategoryId == null
        ? 'Semua Kategori'
        : menu.categories
            .firstWhere((c) => c.id == menu.selectedCategoryId)
            .name;

    return GestureDetector(
      onTap: () => _showCategoryPicker(context, menu),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.xs,
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.x1),
            const Icon(
              Icons.filter_list_rounded,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, MenuProvider menu) {
    showDialog<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: menu,
        child: const _CategoryPickerDialog(),
      ),
    );
  }
}

// ── Category picker dialog ────────────────────────────────────────────────────

class _CategoryPickerDialog extends StatelessWidget {
  const _CategoryPickerDialog();

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();

    return Dialog(
      backgroundColor: AppColors.primary,
      shape: AppRadius.toShape(AppRadius.lg),
      child: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x4,
                AppSpacing.x4,
                AppSpacing.x2,
                AppSpacing.x4,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list_rounded,
                    color: AppColors.onPrimary,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.x2),
                  Expanded(
                    child: Text(
                      menu.selectedCategoryId == null
                          ? 'Semua Kategori'
                          : menu.categories
                              .firstWhere(
                                  (c) => c.id == menu.selectedCategoryId)
                              .name,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.onPrimary,
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Category list
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: ListView(
                padding: const EdgeInsets.only(bottom: AppSpacing.x4),
                shrinkWrap: true,
                children: [
                  // "All" option
                  _CategoryTile(
                    label: 'Semua Kategori',
                    isSelected: menu.selectedCategoryId == null,
                    onTap: () {
                      menu.selectCategory(null);
                      Navigator.of(context).pop();
                    },
                  ),
                  // Per-category tiles
                  ...menu.categories.map(
                    (c) => _CategoryTile(
                      label: c.name,
                      isSelected: menu.selectedCategoryId == c.id,
                      onTap: () {
                        menu.selectCategory(c.id);
                        Navigator.of(context).pop();
                      },
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

// ── Category tile ─────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected
            ? AppColors.onPrimary.withValues(alpha: 0.15)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x2,
        ),
        child: Row(
          children: [
            // // Thumbnail placeholder
            // Container(
            //   width: 44,
            //   height: 44,
            //   decoration: BoxDecoration(
            //     color: AppColors.surface,
            //     borderRadius: AppRadius.sm,
            //   ),
            //   child: const Icon(
            //     Icons.image_rounded,
            //     size: 22,
            //     color: AppColors.outline,
            //   ),
            // ),
            // const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Text(
                label,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                size: 18,
                color: AppColors.onPrimary,
              ),
          ],
        ),
      ),
    );
  }
}
