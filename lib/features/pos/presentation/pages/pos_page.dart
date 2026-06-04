import 'package:flutter/material.dart';

import '../widgets/order_panel/order_panel.dart';
import '../widgets/navigation/pos_drawer.dart';
import '../widgets/product_panel/product_panel.dart';

const double _kExpandedBreakpoint = 800;

class PosPage extends StatelessWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PosDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= _kExpandedBreakpoint) {
            return const _ExpandedLayout();
          }
          return const _CompactLayout();
        },
      ),
    );
  }
}

class _ExpandedLayout extends StatelessWidget {
  const _ExpandedLayout();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: OrderPanel()),
        Expanded(child: ProductPanel()),
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
          child: const OrderPanel(),
        ),
      ],
    );
  }
}
