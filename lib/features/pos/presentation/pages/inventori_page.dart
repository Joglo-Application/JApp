import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../core/router/app_routes.dart';
import '../../domain/entities/inventori_item.dart';
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

class _InventoriView extends StatefulWidget {
  const _InventoriView({this.drawer});

  final Widget? drawer;

  @override
  State<_InventoriView> createState() => _InventoriViewState();
}

class _InventoriViewState extends State<_InventoriView> {
  Future<void> _onTambah() async {
    final item = await context.push<InventoriItem>(
      AppRoutes.inventoriTambahProduk,
    );
    if (item != null && mounted) {
      context.read<InventoriProvider>().addItem(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: widget.drawer ??
          const PosDrawer(activePage: PosDrawerPage.inventori),
      body: Column(
        children: [
          InventoriAppBar(onTambah: _onTambah),
          const InventoriFilterBar(),
          const Expanded(child: InventoriTable()),
        ],
      ),
    );
  }
}
