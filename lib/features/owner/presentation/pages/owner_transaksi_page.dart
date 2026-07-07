import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/navigation/owner_drawer.dart';
import '../widgets/transaksi/transaksi_app_bar.dart';
import '../widgets/transaksi/transaksi_section_list.dart';

class OwnerTransaksiPage extends StatelessWidget {
  const OwnerTransaksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const OwnerDrawer(activePage: OwnerDrawerPage.transaksi),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const TransaksiAppBar(),
            const Expanded(child: TransaksiSectionList()),
          ],
        ),
      ),
    );
  }
}
