import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/stok_gudang_provider.dart';
import '../widgets/navigation/owner_drawer.dart';
import '../widgets/stok_gudang/stok_gudang_app_bar.dart';
import '../widgets/stok_gudang/stok_gudang_filter_bar.dart';
import '../widgets/stok_gudang/stok_gudang_table.dart';

class OwnerStokGudangPage extends StatelessWidget {
  const OwnerStokGudangPage({super.key, this.drawer});

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StokGudangProvider()..load(),
      child: _StokGudangView(drawer: drawer),
    );
  }
}

class _StokGudangView extends StatelessWidget {
  const _StokGudangView({this.drawer});

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer ?? const OwnerDrawer(activePage: OwnerDrawerPage.stokGudang),
      body: Column(
        children: [
          const StokGudangAppBar(),
          const StokGudangFilterBar(),
          const Expanded(child: StokGudangTable()),
        ],
      ),
    );
  }
}
