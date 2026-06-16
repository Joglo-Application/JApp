import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/laporan/laporan_action_bar.dart';
import '../widgets/laporan/laporan_app_bar.dart';
import '../widgets/laporan/laporan_guest_resto_table.dart';
import '../widgets/laporan/laporan_pembayaran_table.dart';
import '../widgets/laporan/laporan_produk_table.dart';
import '../widgets/laporan/laporan_ringkasan_view.dart';
import '../widgets/laporan/laporan_tab_bar.dart';
import '../widgets/navigation/owner_drawer.dart';

class OwnerLaporanPage extends StatefulWidget {
  const OwnerLaporanPage({super.key});

  @override
  State<OwnerLaporanPage> createState() => _OwnerLaporanPageState();
}

class _OwnerLaporanPageState extends State<OwnerLaporanPage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const OwnerDrawer(activePage: OwnerDrawerPage.laporan),
      body: SafeArea(
        child: Column(
          children: [
            const LaporanAppBar(),
            LaporanTabBar(
              selectedIndex: _tabIndex,
              onTabSelected: (i) => setState(() => _tabIndex = i),
            ),
            const LaporanActionBar(),
            const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return switch (_tabIndex) {
      0 => const LaporanProdukTable(),
      1 => const LaporanRingkasanView(),
      2 => const LaporanGuestRestoTable(),
      3 => const LaporanPembayaranTable(),
      _ => const SizedBox.shrink(),
    };
  }
}
