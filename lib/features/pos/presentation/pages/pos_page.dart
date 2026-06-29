import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../widgets/order_panel/order_panel.dart';
import '../widgets/navigation/pos_drawer.dart';
import '../widgets/product_panel/product_panel.dart';
import 'payment_page.dart';

const double _kExpandedBreakpoint = 800;

class PosPage extends StatelessWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PosDrawer(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= _kExpandedBreakpoint) {
              return const _ExpandedLayout();
            }
            return const _CompactLayout();
          },
        ),
      ),
    );
  }
}

void _goToPayment(BuildContext context) {
  final order = context.read<OrderProvider>();
  if (order.isEmpty) return;

  // Dine-In wajib "Kirim ke Dapur" dulu (pesanan diparkir di meja & diambil
  // ulang lewat "Lihat Pesanan" untuk dibayar). Non-Dine-In boleh langsung
  // bayar — pesanannya dibuat & dikirim ke dapur saat pembayaran selesai.
  if (order.effectiveOrderType == OrderType.dineIn && !order.isSentToKitchen) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.send_rounded),
        title: const Text('Kirim ke Dapur dulu'),
        content: const Text(
          'Pesanan Dine-In harus dikirim ke dapur terlebih dahulu sebelum '
          'melakukan pembayaran.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const PaymentPage()),
  );
}

class _ExpandedLayout extends StatelessWidget {
  const _ExpandedLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: OrderPanel(onCheckout: () => _goToPayment(context))),
        const Expanded(child: ProductPanel()),
      ],
    );
  }
}

class _CompactLayout extends StatelessWidget {
  const _CompactLayout();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Column(
      children: [
        const Expanded(child: ProductPanel()),
        SizedBox(
          height: screenHeight * 0.42,
          child: OrderPanel(onCheckout: () => _goToPayment(context)),
        ),
      ],
    );
  }
}
