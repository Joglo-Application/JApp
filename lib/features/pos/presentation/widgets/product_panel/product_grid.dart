import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/product.dart';
import '../../providers/menu_provider.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.onProductTap});

  final ValueChanged<Product> onProductTap;

  @override
  Widget build(BuildContext context) {
    final products = context.watch<MenuProvider>().filteredProducts;

    if (products.isEmpty) {
      return const _EmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.x3),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 170,
        childAspectRatio: 0.72,
        crossAxisSpacing: AppSpacing.x3,
        mainAxisSpacing: AppSpacing.x3,
      ),
      itemCount: products.length,
      itemBuilder: (_, index) => ProductCard(
        product: products[index],
        onTap: () => onProductTap(products[index]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.onPrimary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppSpacing.x3),
          Text(
            'No products found',
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          Text(
            'Try a different search or category',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
