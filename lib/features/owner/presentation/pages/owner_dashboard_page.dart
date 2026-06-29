import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/owner_dashboard_provider.dart';
import '../widgets/navigation/owner_drawer.dart';

class OwnerDashboardPage extends StatelessWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OwnerDashboardProvider(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const OwnerDrawer(activePage: OwnerDrawerPage.dashboard),
      body: SafeArea(
        child: Column(
          children: [
            const _AppBar(),
            const Expanded(child: _DashboardBody()),
          ],
        ),
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        border: Border(bottom: BorderSide(color: AppColors.secondaryContainer)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            Material(
              color: AppColors.primary,
              borderRadius: AppRadius.md,
              child: InkWell(
                onTap: () => Scaffold.of(context).openDrawer(),
                borderRadius: AppRadius.md,
                child: const SizedBox(
                  width: 45,
                  height: 45,
                  child: Icon(
                    Icons.menu_rounded,
                    color: AppColors.onPrimary,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            Text(
              'Dashboard',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.onSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scrollable body ───────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _DateRangeRow(),
          _TentangTokoSection(),
          _PenjualanSection(),
          _ChartSection(
            title: 'Pendapatan',
            dataKey: _ChartDataKey.pendapatan,
            color: AppColors.primary,
            fillColor: AppColors.primaryContainer,
          ),
          _ChartSection(
            title: 'Pengeluaran',
            dataKey: _ChartDataKey.pengeluaran,
            color: AppColors.error,
            fillColor: AppColors.errorContainer,
          ),
          _TopSection(
            title: 'Top Kategori Produk',
            dataKey: _TopDataKey.kategori,
          ),
          _TopSection(
            title: 'Top Produk Toko',
            dataKey: _TopDataKey.produk,
          ),
          SizedBox(height: AppSpacing.x6),
        ],
      ),
    );
  }
}

// ── Date range row ────────────────────────────────────────────────────────────

class _DateRangeRow extends StatelessWidget {
  const _DateRangeRow();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OwnerDashboardProvider>();
    final fmt = DateFormat('dd/MM/yyyy');
    final dateText =
        '${fmt.format(provider.startDate)} - ${fmt.format(provider.endDate)}';

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
                vertical: AppSpacing.x4,
              ),
              child: Text(
                'Pilih Tanggal',
                style: AppTypography.textTheme.bodyMedium,
              ),
            ),
          ),
          InkWell(
            onTap: () => _pickDateRange(context, provider),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
                vertical: AppSpacing.x4,
              ),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dateText,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x2),
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange(
    BuildContext context,
    OwnerDashboardProvider provider,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: provider.startDate,
        end: provider.endDate,
      ),
    );
    if (picked != null && context.mounted) {
      await provider.changeDateRange(picked.start, picked.end);
    }
  }
}

// ── Tentang Toko section ──────────────────────────────────────────────────────

class _TentangTokoSection extends StatelessWidget {
  const _TentangTokoSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OwnerDashboardProvider>();
    final fmt = NumberFormat('#,###', 'id_ID');
    String idr(double v) => 'IDR ${fmt.format(v.round())}';

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionDividerRow(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.store_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.x2),
                Text(
                  'Tentang Toko Anda',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _SummaryRow(label: 'Pendapatan', value: idr(provider.pendapatan)),
          _SummaryRow(
            label: 'Pengeluaran',
            value: idr(provider.pengeluaran),
          ),
          _SummaryRow(
            label: 'Pengembalian penjualan',
            value: idr(provider.pengembalianPenjualan),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SectionDividerRow extends StatelessWidget {
  const _SectionDividerRow({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x4,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: child,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x4,
      ),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.outlineVariant),
              ),
            ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.textTheme.bodyMedium),
          Text(
            value,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Penjualan section ─────────────────────────────────────────────────────────

class _PenjualanSection extends StatelessWidget {
  const _PenjualanSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OwnerDashboardProvider>();
    final fmt = NumberFormat('#,###', 'id_ID');
    String idr(double v) => 'IDR  ${fmt.format(v.round())}';

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x4,
              AppSpacing.x4,
              AppSpacing.x4,
              AppSpacing.x2,
            ),
            child: Text(
              'Penjualan',
              style: AppTypography.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _PenjualanCell(
                  label: 'Total Penjualan',
                  value: idr(provider.totalPenjualan),
                  padLeft: AppSpacing.x4,
                  padRight: AppSpacing.x2,
                ),
              ),
              Expanded(
                child: _PenjualanCell(
                  label: 'Penjualan Kotor',
                  value: idr(provider.penjualanKotor),
                  padLeft: AppSpacing.x2,
                  padRight: AppSpacing.x4,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _PenjualanCell(
                  label: 'Transaksi',
                  value: '${provider.jumlahTransaksi}',
                  padLeft: AppSpacing.x4,
                  padRight: AppSpacing.x2,
                ),
              ),
              Expanded(
                child: _PenjualanCell(
                  label: 'Penerimaan',
                  value: idr(provider.penerimaan),
                  padLeft: AppSpacing.x2,
                  padRight: AppSpacing.x4,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x2),
        ],
      ),
    );
  }
}

class _PenjualanCell extends StatelessWidget {
  const _PenjualanCell({
    required this.label,
    required this.value,
    required this.padLeft,
    required this.padRight,
  });

  final String label;
  final String value;
  final double padLeft;
  final double padRight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: padLeft,
        right: padRight,
        top: AppSpacing.x2,
        bottom: AppSpacing.x2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x3,
              vertical: AppSpacing.x3,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppRadius.xs,
            ),
            child: Text(
              value,
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Area chart section ────────────────────────────────────────────────────────

enum _ChartDataKey { pendapatan, pengeluaran }

class _ChartSection extends StatelessWidget {
  const _ChartSection({
    required this.title,
    required this.dataKey,
    required this.color,
    required this.fillColor,
  });

  final String title;
  final _ChartDataKey dataKey;
  final Color color;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OwnerDashboardProvider>();
    final data = dataKey == _ChartDataKey.pendapatan
        ? provider.dailyPendapatan
        : provider.dailyPengeluaran;

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    final maxY = data.isEmpty
        ? 0.0
        : data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: color, size: 22),
              const SizedBox(width: AppSpacing.x2),
              Text(
                title,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x4),
          SizedBox(
            height: 200,
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : spots.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada data',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      )
                    : _buildChart(spots, maxY, data),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(
    List<FlSpot> spots,
    double maxY,
    List<OwnerDailyData> data,
  ) {
    final fmt = NumberFormat('#,###', 'id_ID');
    final interval = maxY > 0 ? maxY / 3 : 1.0;

    final barData = LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.35,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: fillColor),
    );

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY * 1.15,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.outlineVariant,
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (_) => const FlLine(
            color: AppColors.outlineVariant,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 86,
              interval: interval,
              getTitlesWidget: (value, _) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  value == 0 ? 'IDR 0' : 'IDR ${fmt.format(value.round())}',
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox();
                final d = data[idx].date;
                final label =
                    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [barData],
      ),
    );
  }
}

// ── Top kategori / produk sections ────────────────────────────────────────────

enum _TopDataKey { kategori, produk }

class _TopSection extends StatelessWidget {
  const _TopSection({required this.title, required this.dataKey});

  final String title;
  final _TopDataKey dataKey;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OwnerDashboardProvider>();
    final items = dataKey == _TopDataKey.kategori
        ? provider.topKategoriProduk
        : provider.topProdukToko;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionDividerRow(
            child: Text(
              title,
              style: AppTypography.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          for (final item in items) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
                vertical: AppSpacing.x3,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              child: Text(
                item.kategori,
                style: AppTypography.textTheme.bodyMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
                vertical: AppSpacing.x3,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x3,
                  vertical: AppSpacing.x3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.xs,
                ),
                child: Text(
                  '${item.nama}  ${item.jumlah}',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.x4),
              child: Text(
                'Tidak ada data',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
