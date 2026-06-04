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
        child: Row(
          children: [
            Expanded(
              child: AppSearchField(
                controller: _searchCtrl,
                hint: 'Cari produk…',
                onChanged: context.read<MenuProvider>().search,
              ),
            ),
            const SizedBox(width: AppSpacing.x2),
            const _CategoryDropdown(),
          ],
        ),
      ),
    );
  }
}

// ── Category dropdown ─────────────────────────────────────────────────────────

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown();

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();

    final label = menu.selectedCategoryId == null
        ? 'Semua Kategori'
        : menu.categories
            .firstWhere((c) => c.id == menu.selectedCategoryId)
            .name;

    return PopupMenuButton<String?>(
      initialValue: menu.selectedCategoryId,
      onSelected: menu.selectCategory,
      itemBuilder: (_) => [
        const PopupMenuItem<String?>(
          value: null,
          child: Text('Semua Kategori'),
        ),
        ...menu.categories.map(
          (c) => PopupMenuItem<String?>(
            value: c.id,
            child: Text(c.name),
          ),
        ),
      ],
      child: _CategoryButton(label: label),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3,
        vertical: AppSpacing.x2 + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xs,
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.x1),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: AppColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
