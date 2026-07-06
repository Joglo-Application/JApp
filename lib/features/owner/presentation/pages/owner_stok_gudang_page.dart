import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/stok_gudang_provider.dart';
import '../widgets/navigation/owner_drawer.dart';
import '../widgets/stok_gudang/stok_gudang_app_bar.dart';
import '../widgets/stok_gudang/stok_gudang_filter_bar.dart';
import '../widgets/stok_gudang/stok_gudang_table.dart';

class OwnerStokGudangPage extends StatelessWidget {
  const OwnerStokGudangPage({
    super.key,
    this.drawer,
    this.showLogGudang = false,
  });

  final Widget? drawer;

  /// Hanya SPV dan owner yang melihat tombol Log Gudang.
  final bool showLogGudang;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StokGudangProvider()..load(),
      child: _StokGudangView(drawer: drawer, showLogGudang: showLogGudang),
    );
  }
}

class _StokGudangView extends StatelessWidget {
  const _StokGudangView({this.drawer, this.showLogGudang = false});

  final Widget? drawer;
  final bool showLogGudang;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer ?? const OwnerDrawer(activePage: OwnerDrawerPage.stokGudang),
      body: Column(
        children: [
          StokGudangAppBar(showLogGudang: showLogGudang),
          const StokGudangFilterBar(),
          const Expanded(child: StokGudangTable()),
        ],
      ),
    );
  }
}
