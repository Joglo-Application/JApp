import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventori_provider.dart';
import '../widgets/inventori/inventori_app_bar.dart';
import '../widgets/inventori/inventori_filter_bar.dart';
import '../widgets/inventori/inventori_table.dart';
import '../widgets/navigation/pos_drawer.dart';

class InventoriPage extends StatelessWidget {
  const InventoriPage({super.key, this.drawer});

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoriProvider()..load(),
      child: _InventoriView(drawer: drawer),
    );
  }
}

class _InventoriView extends StatelessWidget {
  const _InventoriView({this.drawer});

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer ?? const PosDrawer(activePage: PosDrawerPage.inventori),
      body: SafeArea(
        child: Column(
          children: [
            const InventoriAppBar(),
            const InventoriFilterBar(),
            const Expanded(child: InventoriTable()),
          ],
        ),
      ),
    );
  }
}
