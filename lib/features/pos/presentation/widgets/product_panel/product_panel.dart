import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_tab_bar.dart';
import '../../providers/menu_provider.dart';
import 'custom_item_form.dart';
import 'product_grid.dart';
import 'product_panel_header.dart';

class ProductPanel extends StatefulWidget {
  const ProductPanel({super.key});

  @override
  State<ProductPanel> createState() => _ProductPanelState();
}

class _ProductPanelState extends State<ProductPanel> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch the menu from the backend once the panel mounts (the user is
    // already authenticated by the time the POS screen is shown).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MenuProvider>().loadMenus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTabBar(
          tabs: const ['Produk', 'Custom'],
          selectedIndex: _tabIndex,
          onTabSelected: (i) => setState(() => _tabIndex = i),
        ),
        const ProductPanelHeader(),
        Expanded(
          child: ColoredBox(
            color: AppColors.primary,
            child: _tabIndex == 0
                ? const ProductGrid()
                : CustomItemForm(
                    // Jump to the Produk grid after a menu is created so the
                    // freshly-fetched item is visible right away.
                    onCreated: () => setState(() => _tabIndex = 0),
                  ),
          ),
        ),
      ],
    );
  }
}
