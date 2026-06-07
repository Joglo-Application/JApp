import 'package:flutter/material.dart';

import '../widgets/order_panel/order_panel.dart';
import '../widgets/product_panel/product_panel.dart';
import 'payment_page.dart';

const double _kExpandedBreakpoint = 800;

class PosPage extends StatelessWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
