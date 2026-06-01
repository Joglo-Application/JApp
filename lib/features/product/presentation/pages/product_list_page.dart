import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../category/presentation/widgets/category_chip.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_overlay.dart';
import 'product_form_page.dart';

/// Displays all products with category filtering and CRUD actions.
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Product',
            onPressed: () => _openForm(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _CategoryFilterBar(),
          Expanded(child: _ProductGrid()),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, {Product? existing}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductFormPage(existing: existing),
      ),
    );
  }
}

/// Horizontal scrolling category filter chips.
class _CategoryFilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<CategoryProvider, ProductProvider>(
      builder: (context, categoryProvider, productProvider, _) {
        final categories = categoryProvider.categories;
        if (categories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 52,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            children: [
              // "All" chip
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => productProvider.filterByCategory(null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: productProvider.selectedCategoryId == null
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: productProvider.selectedCategoryId == null
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                        width: productProvider.selectedCategoryId == null
                            ? 2
                            : 1,
                      ),
                    ),
                    child: Text(
                      'All',
                      style: TextStyle(
                        fontWeight:
                            productProvider.selectedCategoryId == null
                                ? FontWeight.w700
                                : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              ...categories.map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChip(
                    category: cat,
                    isSelected:
                        productProvider.selectedCategoryId == cat.id,
                    onTap: () =>
                        productProvider.filterByCategory(cat.id),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Grid of product cards.
class _ProductGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const InlineLoader();

        if (provider.errorMessage != null) {
          return Center(child: Text(provider.errorMessage!));
        }

        final products = provider.filteredProducts;

        if (products.isEmpty) {
          return EmptyStateWidget(
            message: 'No products found.\nTap + to add one.',
            icon: Icons.inventory_2_outlined,
            actionLabel: 'Add Product',
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProductFormPage()),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductFormPage(existing: product),
                ),
              ),
              onDelete: () => _confirmDelete(context, provider, product),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    ProductProvider provider,
    Product product,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              provider.deleteProduct(product.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
