import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_tab_bar.dart';
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
                : const CustomItemForm(),
          ),
        ),
      ],
    );
  }
}
