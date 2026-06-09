import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_tab_bar.dart';
import '../../../domain/entities/product.dart';
import '../../providers/menu_provider.dart';
import '../../providers/pos_ui_provider.dart';
import 'add_menu_form.dart';
import 'custom_item_form.dart';
import 'product_detail_form.dart';
import 'product_grid.dart';
import 'product_panel_header.dart';

class ProductPanel extends StatefulWidget {
  const ProductPanel({super.key});

  @override
  State<ProductPanel> createState() => _ProductPanelState();
}

class _ProductPanelState extends State<ProductPanel> {
  int _tabIndex = 0;
  Product? _pendingProduct;

  void _openDetailForm(Product product) {
    setState(() => _pendingProduct = product);
  }

  void _closeDetailForm() {
    setState(() => _pendingProduct = null);
  }

  @override
  void initState() {
    super.initState();
    // Fetch the menu from the backend once the panel mounts (the user is
    // already authenticated by the time the POS screen is shown).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MenuProvider>().loadMenus();
    });
  }

  /// Tab content. Tab 0 = product grid, tab 1 = ad-hoc custom order item
  /// (development), tab 2 = create persistent menu (dashboard-panel).
  Widget _buildTabContent() {
    switch (_tabIndex) {

        
      case 1:
        // Jump back to the Produk grid after a menu is created so the
        // freshly-fetched item is visible right away.
        return AddMenuForm(onCreated: () => setState(() => _tabIndex = 0));
      case 0:
      default:
        return ProductGrid(onProductTap: _openDetailForm);
    }
  }

  @override
  Widget build(BuildContext context) {
    final posUi = context.watch<PosUiProvider>();
    final editingItem = posUi.editingItem;

    // Edit mode — order item tapped: show form in-place
    if (editingItem != null) {
      return ColoredBox(
        color: AppColors.primary,
        child: ProductDetailForm(
          product: Product(
            id: editingItem.productId,
            name: editingItem.name,
            price: editingItem.unitPrice,
            categoryId: '',
            imageUrl: editingItem.imageUrl,
          ),
          existingItem: editingItem,
          onCancel: () => context.read<PosUiProvider>().clearEdit(),
        ),
      );
    }

    // Add mode — product tapped from grid
    return ColoredBox(
      color: AppColors.primary,
      child: _pendingProduct != null
          ? ProductDetailForm(
              product: _pendingProduct!,
              onCancel: _closeDetailForm,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTabBar(
                  tabs: const ['Produk', 'Menu'],
                  selectedIndex: _tabIndex,
                  onTabSelected: (i) => setState(() => _tabIndex = i),
                ),
                const ProductPanelHeader(),
                Expanded(child: _buildTabContent()),
              ],
            ),
    );
  }
}
