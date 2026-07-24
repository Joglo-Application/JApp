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

const _kBlue = Color(0xFF2196F3);
const _kChartColors = [
  AppColors.primary,
  AppColors.tertiary,
  _kBlue,
  AppColors.warning,
];

String _rp(num v) => 'Rp ${NumberFormat('#,###', 'id_ID').format(v)}';

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
          ],
        ),
      ),
    );
  }
}

// ── Summary KPI cards ─────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransaksiProvider>();
    final loading = provider.isLoading;

    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            icon: Icons.payments_rounded,
            accent: AppColors.tertiary,
            label: 'Total Penjualan',
            value: loading ? '—' : _rp(provider.totalPenjualan),
          ),
        ),
        const SizedBox(width: AppSpacing.x4),
        Expanded(
          child: _KpiCard(
            icon: Icons.groups_rounded,
            accent: _kBlue,
            label: 'Total Guest',
            value: loading ? '—' : '${provider.totalGuest}',
          ),
        ),
        const SizedBox(width: AppSpacing.x4),
        Expanded(
          child: _KpiCard(
            icon: Icons.shopping_bag_rounded,
            accent: AppColors.primary,
            label: 'Item Terjual',
            value: loading ? '—' : '${provider.totalItemQty}',
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: AppRadius.sm,
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section wrapper card ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(AppSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.x2),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x4),
          child,
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
          child: _SectionCard(
            icon: Icons.show_chart_rounded,
            title: 'Penjualan berdasarkan Tanggal',
            child: _LineChart(
              spots: penjualanSpots,
              xLabels: xLabels,
              isLoading: isLoading,
              formatY: (v) =>
                  v == 0 ? '0' : NumberFormat('#,###', 'id_ID').format(v),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.x4),
        Expanded(
          child: _SectionCard(
            icon: Icons.stacked_line_chart_rounded,
            title: 'Tamu berdasarkan Tanggal',
            child: _LineChart(
              spots: guestSpots,
              xLabels: xLabels,
              isLoading: isLoading,
              formatY: (v) => v.toInt().toString(),
            ),
          ),
        ),
      ],
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({
    required this.spots,
    required this.xLabels,
    required this.isLoading,
    required this.formatY,
  });

  final List<FlSpot> spots;
  final List<String> xLabels;
  final bool isLoading;
  final String Function(double) formatY;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : spots.isEmpty
              ? _emptyChart()
              : _buildChart(),
    );
  }

  Widget _emptyChart() => Center(
        child: Text(
          'Tidak ada data',
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );

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
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
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
          child: _SectionCard(
            icon: Icons.donut_large_rounded,
            title: 'Top 3 Penjualan Produk',
            child: _Donut(
              items: produkItems,
              isLoading: provider.isLoading,
              formatValue: (v) => '${v.toInt()} pcs',
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.x4),
        Expanded(
          child: _SectionCard(
            icon: Icons.pie_chart_rounded,
            title: 'Top 3 Penjualan Kategori',
            child: _Donut(
              items: topKategori,
              isLoading: provider.isLoading,
              formatValue: _rp,
            ),
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

class _Donut extends StatelessWidget {
  const _Donut({
    required this.items,
    required this.isLoading,
    required this.formatValue,
  });

  final List<(String, double, Color)> items;
  final bool isLoading;
  final String Function(double) formatValue;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 176,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (items.isEmpty) {
      return SizedBox(
        height: 176,
        child: Center(
          child: Text(
            'Tidak ada data',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final total = items.fold<double>(0, (s, e) => s + e.$2);

    return SizedBox(
      height: 176,
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 42,
                sectionsSpace: 3,
                sections: items
                    .map(
                      (item) => PieChartSectionData(
                        value: item.$2,
                        color: item.$3,
                        title: '',
                        radius: 26,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x4),
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == items.length - 1 ? 0 : AppSpacing.x3,
                    ),
                    child: _LegendRow(
                      rank: i + 1,
                      label: items[i].$1,
                      valueText: formatValue(items[i].$2),
                      pct: total == 0 ? 0 : items[i].$2 / total,
                      color: items[i].$3,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.rank,
    required this.label,
    required this.valueText,
    required this.pct,
    required this.color,
  });

  final int rank;
  final String label;
  final String valueText;
  final double pct;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(color: color, borderRadius: AppRadius.xs),
        ),
        const SizedBox(width: AppSpacing.x2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$rank. $label',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                '$valueText · ${(pct * 100).toStringAsFixed(0)}%',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
