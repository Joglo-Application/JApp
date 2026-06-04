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
    final menu = context.watch<MenuProvider>();

    if (menu.isLoading && !menu.hasLoaded) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.onPrimary),
      );
    }

    if (menu.error != null && !menu.hasLoaded) {
      return _ErrorState(message: menu.error!, onRetry: menu.refresh);
    }

    final products = menu.filteredProducts;
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.onPrimary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.x3),
            Text(
              'Gagal memuat menu',
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: AppSpacing.x1),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.x4),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
