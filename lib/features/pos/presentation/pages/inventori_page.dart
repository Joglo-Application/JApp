import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventori_provider.dart';
import '../widgets/inventori/inventori_app_bar.dart';
import '../widgets/inventori/inventori_filter_bar.dart';
import '../widgets/inventori/inventori_table.dart';
import '../widgets/navigation/pos_drawer.dart';

class InventoriPage extends StatelessWidget {
  const InventoriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoriProvider()..load(),
      child: const _InventoriView(),
    );
  }
}

class _InventoriView extends StatelessWidget {
  const _InventoriView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PosDrawer(activePage: PosDrawerPage.inventori),
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
