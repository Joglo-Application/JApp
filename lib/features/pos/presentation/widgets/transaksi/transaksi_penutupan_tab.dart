import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/transaksi.dart';
import '../../providers/menu_provider.dart';
import '../../providers/transaksi_provider.dart';

const _kChartColors = [
  AppColors.primary,
  AppColors.tertiary,
  Color(0xFF2196F3),
  AppColors.warning,
];

class TransaksiPenutupanTab extends StatelessWidget {
  const TransaksiPenutupanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.x4),
        child: Column(
          children: const [
            _StatsRow(),
            SizedBox(height: AppSpacing.x4),
            _WeeklyChartsRow(),
            SizedBox(height: AppSpacing.x4),
            _DonutsRow(),
            SizedBox(height: AppSpacing.x4),
          ],
        ),
      ),
    );
  }
}

// ── Summary stat cards ────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransaksiProvider>();
    final isLoading = provider.isLoading;

    final penjualan = isLoading
        ? '-'
        : NumberFormat('#,###', 'id_ID').format(provider.totalPenjualan);
    final guest = isLoading ? '-' : '${provider.totalGuest}';

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total Penjualan',
            value: penjualan,
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: AppSpacing.x4),
        Expanded(
          child: _StatCard(
            title: 'Total Guest',
            value: guest,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x5,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weekly line charts ────────────────────────────────────────────────────────

class _WeeklyChartsRow extends StatelessWidget {
  const _WeeklyChartsRow();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransaksiProvider>();
    final penjualan = provider.weeklyPenjualan;
    final guest = provider.weeklyGuest;
    final isLoading = provider.isLoadingWeekly;

    final penjualanSpots = penjualan.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.$2))
        .toList();
    final guestSpots = guest.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.$2.toDouble()))
        .toList();
    final xLabels = penjualan.map((e) => '${e.$1.day}').toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _LineChartCard(
            title: 'Penjualan berdasarkan Tanggal',
            spots: penjualanSpots,
            xLabels: xLabels,
            isLoading: isLoading,
            formatY: (v) => v == 0
                ? '0'
                : NumberFormat('#,###', 'id_ID').format(v),
          ),
        ),
        const SizedBox(width: AppSpacing.x4),
        Expanded(
          child: _LineChartCard(
            title: 'Tamu berdasarkan Tanggal',
            spots: guestSpots,
            xLabels: xLabels,
            isLoading: isLoading,
            formatY: (v) => v.toInt().toString(),
          ),
        ),
      ],
    );
  }
}

class _LineChartCard extends StatelessWidget {
  const _LineChartCard({
    required this.title,
    required this.spots,
    required this.xLabels,
    required this.isLoading,
    required this.formatY,
  });

  final String title;
  final List<FlSpot> spots;
  final List<String> xLabels;
  final bool isLoading;
  final String Function(double) formatY;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: AppRadius.toShape(AppRadius.md),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x4,
          AppSpacing.x4,
          AppSpacing.x3,
          AppSpacing.x3,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.x4),
            SizedBox(
              height: 220,
              child: isLoading
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
                      : _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final barData = LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.35,
      color: AppColors.primary,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (_, _, _, _) => FlDotCirclePainter(
          radius: 3,
          color: AppColors.primary,
          strokeWidth: 0,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: AppColors.primaryContainer,
      ),
    );

    return LineChart(
      LineChartData(
        minY: 0,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= xLabels.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    xLabels[idx],
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [barData],
        showingTooltipIndicators: List.generate(spots.length, (i) {
          return ShowingTooltipIndicators(
            [LineBarSpot(barData, 0, spots[i])],
          );
        }),
        lineTouchData: LineTouchData(
          enabled: false,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.transparent,
            tooltipBorder: BorderSide.none,
            tooltipPadding: const EdgeInsets.only(bottom: 2),
            getTooltipItems: (touchedSpots) => touchedSpots
                .map(
                  (s) => LineTooltipItem(
                    formatY(s.y),
                    AppTypography.textTheme.labelSmall!.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ── Donut charts ──────────────────────────────────────────────────────────────

class _DonutsRow extends StatelessWidget {
  const _DonutsRow();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransaksiProvider>();
    final menuProvider = context.watch<MenuProvider>();

    final topProduk = provider.topProdukByQty;
    final produkItems = topProduk.asMap().entries.map((e) {
      return (
        e.value.$1,
        e.value.$2.toDouble(),
        _kChartColors[e.key % _kChartColors.length],
      );
    }).toList();

    final topKategori = _computeTopKategori(
      provider.all,
      menuProvider.allProducts,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _DonutCard(
            title: 'Top Penjualan Produk',
            chartTitle: 'Top 3 Penjualan Produk',
            items: produkItems,
            isLoading: provider.isLoading,
          ),
        ),
        const SizedBox(width: AppSpacing.x4),
        Expanded(
          child: _DonutCard(
            title: 'Top Penjualan Kategori Produk',
            chartTitle: 'Top 3 Penjualan Kategori',
            items: topKategori,
            isLoading: provider.isLoading,
          ),
        ),
      ],
    );
  }

  List<(String, double, Color)> _computeTopKategori(
    List<Transaksi> transaksiList,
    List<Product> products,
  ) {
    final nameToCategory = <String, String>{};
    for (final p in products) {
      nameToCategory[p.name.toLowerCase()] = _capitalize(p.categoryId);
    }

    final catRevenue = <String, double>{};
    for (final t in transaksiList.where((t) => !t.isReturned)) {
      for (final item in t.items) {
        final cat = nameToCategory[item.nama.toLowerCase()] ?? 'Lainnya';
        catRevenue[cat] = (catRevenue[cat] ?? 0) + item.total;
      }
    }

    final sorted = catRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(3).toList().asMap().entries.map((e) {
      return (
        e.value.key,
        e.value.value,
        _kChartColors[e.key % _kChartColors.length],
      );
    }).toList();
  }

  String _capitalize(String raw) => raw
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

class _DonutCard extends StatelessWidget {
  const _DonutCard({
    required this.title,
    required this.chartTitle,
    required this.items,
    required this.isLoading,
  });

  final String title;
  final String chartTitle;
  final List<(String, double, Color)> items;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: AppRadius.toShape(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: AppColors.primary,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
                vertical: AppSpacing.x4,
              ),
              child: Text(
                title,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chartTitle,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.x4),
                SizedBox(
                  height: 160,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : items.isEmpty
                          ? Center(
                              child: Text(
                                'Tidak ada data',
                                style:
                                    AppTypography.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            )
                          : Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: PieChart(
                                    PieChartData(
                                      centerSpaceRadius: 40,
                                      sectionsSpace: 3,
                                      sections: items
                                          .map(
                                            (item) => PieChartSectionData(
                                              value: item.$2,
                                              color: item.$3,
                                              title: '',
                                              radius: 55,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.x3),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: items
                                        .map(
                                          (item) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: AppSpacing.x2,
                                            ),
                                            child: _SideLegendItem(
                                              label: item.$1,
                                              value: item.$2,
                                              color: item.$3,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                ),
                if (items.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.x2),
                  Wrap(
                    spacing: AppSpacing.x4,
                    runSpacing: AppSpacing.x1,
                    children: items
                        .map((item) => _BottomLegendItem(
                              label: item.$1,
                              color: item.$3,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideLegendItem extends StatelessWidget {
  const _SideLegendItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${value.toStringAsFixed(1)} - $label',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.x1),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: AppRadius.xs),
        ),
      ],
    );
  }
}

class _BottomLegendItem extends StatelessWidget {
  const _BottomLegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: AppRadius.xs),
        ),
        const SizedBox(width: AppSpacing.x1),
        Text(
          label,
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
