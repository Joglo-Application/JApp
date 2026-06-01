import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../../../core/utils/currency_formatter.dart';

/// A card widget representing a single [Product] in the product grid.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.trailing,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// Optional widget in top-right corner (e.g., add-to-cart button).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product image / colour placeholder ────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: product.isAvailable
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.fastfood_outlined,
                        size: 48,
                        color: product.isAvailable
                            ? colorScheme.onPrimaryContainer.withOpacity(0.5)
                            : colorScheme.onSurfaceVariant.withOpacity(0.3),
                      ),
                    ),
                    if (!product.isAvailable)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Unavailable',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (trailing != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: trailing!,
                      ),
                    if (onEdit != null || onDelete != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: _ContextMenu(
                          onEdit: onEdit,
                          onDelete: onDelete,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Info section ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
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

/// Small popup menu with edit / delete options on the card.
class _ContextMenu extends StatelessWidget {
  const _ContextMenu({this.onEdit, this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.more_vert, size: 16, color: Colors.white),
      ),
      itemBuilder: (_) => [
        if (onEdit != null)
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
        if (onDelete != null)
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
      onSelected: (v) {
        if (v == 'edit') onEdit?.call();
        if (v == 'delete') onDelete?.call();
      },
    );
  }
}
