import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../core/router/app_routes.dart';
import '../../domain/entities/create_menu_params.dart';
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
    final params = await context.push<CreateMenuParams>(
      AppRoutes.inventoriTambahProduk,
    );
    if (params == null || !mounted) return;

    final provider = context.read<InventoriProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await provider.tambahProduk(params);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Produk ditambahkan' : (provider.submitError ?? 'Gagal menambah produk'),
        ),
      ),
    );
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
