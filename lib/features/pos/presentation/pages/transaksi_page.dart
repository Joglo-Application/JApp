import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaksi_provider.dart';
import '../widgets/navigation/pos_drawer.dart';
import '../widgets/transaksi/transaksi_app_bar.dart';
import '../widgets/transaksi/transaksi_detail_panel.dart';
import '../widgets/transaksi/transaksi_filter_bar.dart';
import '../widgets/transaksi/transaksi_list.dart';

class TransaksiPage extends StatelessWidget {
  const TransaksiPage({super.key, this.drawer});

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransaksiProvider()..load(),
      child: _TransaksiView(drawer: drawer),
    );
  }
}

class _TransaksiView extends StatelessWidget {
  const _TransaksiView({this.drawer});

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer ?? const PosDrawer(activePage: PosDrawerPage.transaksi),
      body: SafeArea(
        child: Column(
          children: [
            const TransaksiAppBar(),
            const TransaksiFilterBar(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ColoredBox(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const TransaksiList(),
                    ),
                  ),
                  const TransaksiDetailPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
