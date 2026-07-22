import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/create_menu_params.dart';
import '../../domain/entities/inventori_item.dart';
import '../../domain/entities/update_menu_params.dart';
import '../providers/inventori_provider.dart';
import '../widgets/inventori/inventori_app_bar.dart';
import '../widgets/inventori/inventori_filter_bar.dart';
import '../widgets/inventori/inventori_table.dart';
import '../widgets/navigation/pos_drawer.dart';
import 'inventori_edit_item_page.dart';

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

  Future<void> _onEditItem(InventoriItem item) async {
    final provider = context.read<InventoriProvider>();
    final params = await context.push<UpdateMenuParams>(
      AppRoutes.inventoriEditItem,
      extra: InventoriEditItemArgs(item: item, menu: provider.menuFor(item.id)),
    );
    if (params == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final ok = await provider.editProduk(params);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Perubahan disimpan' : (provider.submitError ?? 'Gagal menyimpan perubahan'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tambah & edit produk untuk role pemilik tab Inventori (dapur, gudang,
    // kasir). Role lain (supervisor, owner, admin) melihat daftar read-only.
    final canManage = context.select<AuthProvider, bool>(
      (a) => a.canManageInventori,
    );

    return Scaffold(
      drawer: widget.drawer ??
          const PosDrawer(activePage: PosDrawerPage.inventori),
      body: Column(
        children: [
          InventoriAppBar(onTambah: canManage ? _onTambah : null),
          const InventoriFilterBar(),
          Expanded(
            child: InventoriTable(onTapItem: canManage ? _onEditItem : null),
          ),
        ],
      ),
    );
  }
}
