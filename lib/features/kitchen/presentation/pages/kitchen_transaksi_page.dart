import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/kitchen_order_provider.dart';
import '../widgets/navigation/kitchen_drawer.dart';
import '../widgets/transaksi/kitchen_transaksi_app_bar.dart';
import '../widgets/transaksi/kitchen_transaksi_detail.dart';
import '../widgets/transaksi/kitchen_transaksi_list.dart';

class KitchenTransaksiPage extends StatelessWidget {
  const KitchenTransaksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KitchenOrderProvider()..fetch(),
      child: const _KitchenTransaksiView(),
    );
  }
}

class _KitchenTransaksiView extends StatefulWidget {
  const _KitchenTransaksiView();

  @override
  State<_KitchenTransaksiView> createState() => _KitchenTransaksiViewState();
}

class _KitchenTransaksiViewState extends State<_KitchenTransaksiView> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KitchenOrderProvider>();
    final orders = provider.orders;
    final selectedOrder =
        _selectedId == null ? null : orders.where((o) => o.id == _selectedId).firstOrNull;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const KitchenDrawer(activePage: KitchenDrawerPage.transaksi),
      body: Column(
        children: [
          const KitchenTransaksiAppBar(),
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : Row(
                    children: [
                      // ── Left: order list ─────────────────────────────
                      SizedBox(
                        width: 420,
                        child: KitchenTransaksiList(
                          orders: orders,
                          selectedId: _selectedId,
                          onSelect: (id) => setState(() => _selectedId = id),
                        ),
                      ),
                      const VerticalDivider(width: 1, thickness: 1),
                      // ── Right: detail panel ──────────────────────────
                      Expanded(
                        child: selectedOrder == null
                            ? Center(
                                child: Text(
                                  'Pilih transaksi untuk melihat detail',
                                  style: AppTypography.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : KitchenTransaksiDetail(
                                order: selectedOrder,
                                onItemToggle: (i) =>
                                    provider.toggleItem(selectedOrder.id, i),
                                onClose: () =>
                                    setState(() => _selectedId = null),
                                onPrint: () {},
                              ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
