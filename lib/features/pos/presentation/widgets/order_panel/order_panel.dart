import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import 'customer_name_row.dart';
import 'order_checkout_bar.dart';
import 'order_item_list.dart';
import 'order_summary_totals.dart';
import 'order_table_header.dart';
import '../navigation/pos_app_bar.dart';

class OrderPanel extends StatelessWidget {
  const OrderPanel({super.key, this.onCheckout});

  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        children: [
          const PosAppBar(),
          const CustomerNameRow(),
          _Divider(),
          const OrderTableHeader(),
          _Divider(),
          const Expanded(child: OrderItemList()),
          _Divider(),
          const OrderSummaryTotals(),
          _Divider(),
          OrderCheckoutBar(onCheckout: onCheckout),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.onShell.withValues(alpha: 0.10),
    );
  }
}
