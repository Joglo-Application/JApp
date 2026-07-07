import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/log_transaksi_provider.dart';
import '../providers/transaksi_provider.dart';
import '../widgets/laporan/laporan_app_bar.dart';
import '../widgets/laporan/laporan_date_panel.dart';
import '../widgets/laporan/laporan_log_panel.dart';
import '../widgets/navigation/pos_drawer.dart';
import '../widgets/transaksi/transaksi_penutupan_tab.dart';
import '../widgets/transaksi/transaksi_penjualan_produk_tab.dart';

class LaporanPage extends StatelessWidget {
  const LaporanPage({super.key, this.drawer});

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransaksiProvider()
            ..load()
            ..loadWeeklyData(),
        ),
        ChangeNotifierProvider(
          create: (_) => LogTransaksiProvider()..load(),
        ),
      ],
      child: _LaporanView(drawer: drawer),
    );
  }
}

class _LaporanView extends StatelessWidget {
  const _LaporanView({this.drawer});

  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: drawer ?? const PosDrawer(activePage: PosDrawerPage.laporan),
        body: Column(
          children: const [
            LaporanAppBar(),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  TransaksiPenutupanTab(),
                  TransaksiPenjualanProdukTab(),
                  _LogTransaksiTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Log Transaksi tab: date panel left + log panel right ──────────────────────

class _LogTransaksiTab extends StatelessWidget {
  const _LogTransaksiTab();

  @override
  Widget build(BuildContext context) {
    // Sync date selection: when TransaksiProvider date changes, update log too
    final selectedDate = context.select<TransaksiProvider, DateTime>(
      (p) => p.selectedDate,
    );

    // Trigger log reload when the date changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final logProvider = context.read<LogTransaksiProvider>();
      if (!_isSameDay(logProvider.selectedDate, selectedDate)) {
        logProvider.changeDate(selectedDate);
      }
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 320,
          child: ColoredBox(
            color: AppColors.surface,
            child: const LaporanDatePanel(),
          ),
        ),
        const VerticalDivider(
          width: 1,
          thickness: 1,
          color: AppColors.outlineVariant,
        ),
        const Expanded(
          child: ColoredBox(
            color: AppColors.surface,
            child: LaporanLogPanel(),
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
