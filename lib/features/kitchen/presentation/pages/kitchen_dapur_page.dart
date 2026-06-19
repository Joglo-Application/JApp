import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/kitchen_order.dart';
import '../providers/kitchen_order_provider.dart';
import '../widgets/dapur/kitchen_app_bar.dart';
import '../widgets/dapur/kitchen_order_card.dart';
import '../widgets/navigation/kitchen_drawer.dart';

class KitchenDapurPage extends StatelessWidget {
  const KitchenDapurPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KitchenOrderProvider()..fetch(),
      child: const _KitchenDapurView(),
    );
  }
}

class _KitchenDapurView extends StatefulWidget {
  const _KitchenDapurView();

  @override
  State<_KitchenDapurView> createState() => _KitchenDapurViewState();
}

class _KitchenDapurViewState extends State<_KitchenDapurView> {
  KitchenOrderType? _filter;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KitchenOrderProvider>();
    final orders = provider.orders
        .where((o) => o.status == KitchenOrderStatus.inProgress)
        .where((o) => _filter == null || o.tipe == _filter)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const KitchenDrawer(activePage: KitchenDrawerPage.dapur),
      body: Column(
        children: [
          KitchenAppBar(
            selectedFilter: _filter,
            onFilterChanged: (f) => setState(() => _filter = f),
            onRefresh: () => context.read<KitchenOrderProvider>().fetch(),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : orders.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada pesanan aktif',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      )
                    : _OrderGrid(orders: orders, provider: provider),
          ),
        ],
      ),
    );
  }
}

class _OrderGrid extends StatelessWidget {
  const _OrderGrid({required this.orders, required this.provider});

  final List<KitchenOrder> orders;
  final KitchenOrderProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.x4),
      child: Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: AppSpacing.x4,
          runSpacing: AppSpacing.x4,
          children: [
            for (final order in orders)
              SizedBox(
                width: 260,
                height: 360,
                child: KitchenOrderCard(
                  key: ValueKey(order.id),
                  order: order,
                  onItemToggle: (i) => provider.toggleItem(order.id, i),
                  onAllDone: () => provider.markOrderDone(order.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
