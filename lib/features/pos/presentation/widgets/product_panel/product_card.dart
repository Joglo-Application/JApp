import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: product.isAvailable ? onTap : null,
        borderRadius: AppRadius.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _ProductImage(product: product)),
            _ProductInfo(
              product: product,
              onAdd: product.isAvailable ? onTap : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _ImageContent(imageUrl: product.imageUrl),
          if (!product.isAvailable) const _UnavailableOverlay(),
        ],
      ),
    );
  }
}

class _ImageContent extends StatelessWidget {
  const _ImageContent({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return Image.network(imageUrl!, fit: BoxFit.cover);
    }
    return ColoredBox(
      color: AppColors.surfaceContainerHighest,
      child: const Icon(
        Icons.restaurant_outlined,
        size: 36,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _UnavailableOverlay extends StatelessWidget {
  const _UnavailableOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.scrim),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x2,
            vertical: AppSpacing.x1,
          ),
          decoration: BoxDecoration(
            color: AppColors.errorContainer,
            borderRadius: AppRadius.full,
          ),
          child: Text(
            'Unavailable',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.onErrorContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.product, this.onAdd});

  final Product product;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x3,
        AppSpacing.x2,
        AppSpacing.x2,
        AppSpacing.x2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed 2-line slot (12px * 1.33 line-height * 2) so cards with
          // 1- vs 2-line names keep an identical info block height.
          SizedBox(
            height: 32,
            child: Text(
              product.name,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: AppColors.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          Row(
            children: [
              Expanded(
                child: Text(
                  CurrencyFormatter.format(product.price),
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _AddButton(onAdd: onAdd),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({this.onAdd});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onAdd != null
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.3),
          borderRadius: AppRadius.xs,
        ),
        child: const Icon(Icons.add, size: 16, color: AppColors.onPrimary),
      ),
    );
  }
}
