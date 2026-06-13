import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../providers/menu_provider.dart';
import '../../providers/transaksi_provider.dart';
import '../laporan/laporan_date_panel.dart';

class TransaksiPenjualanProdukTab extends StatelessWidget {
  const TransaksiPenjualanProdukTab({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: _ProdukPanel(),
          ),
        ),
      ],
    );
  }
}

// ── Right panel: product breakdown grouped by category ────────────────────────

class _ProdukPanel extends StatelessWidget {
  const _ProdukPanel();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransaksiProvider>();
    final menuProvider = context.watch<MenuProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final grouped = _buildGrouped(provider, menuProvider);
    final totalQty = provider.totalItemQty;
    final totalRevenue = provider.totalPenjualan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProdukHeader(totalQty: totalQty, totalRevenue: totalRevenue),
        Expanded(
          child: grouped.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada data penjualan',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: grouped.length,
                  itemBuilder: (context, i) => grouped[i],
                ),
        ),
      ],
    );
  }

  List<Widget> _buildGrouped(
    TransaksiProvider provider,
    MenuProvider menuProvider,
  ) {
    // product name (lower) → category name
    final nameToCategory = <String, String>{};
    final categoryDisplayName = <String, String>{};
    for (final p in menuProvider.allProducts) {
      nameToCategory[p.name.toLowerCase()] = p.categoryId;
    }
    for (final cat in menuProvider.categories) {
      categoryDisplayName[cat.id] = cat.name;
    }

    // category → { product → (qty, revenue) }
    final catMap = <String, ({int qty, double revenue, Map<String, ({int qty, double revenue})> products})>{};

    for (final t in provider.all.where((t) => !t.isReturned)) {
      for (final item in t.items) {
        final catId = nameToCategory[item.nama.toLowerCase()] ?? 'lainnya';
        final existing = catMap[catId];
        final products = Map<String, ({int qty, double revenue})>.from(existing?.products ?? {});
        final prod = products[item.nama];
        products[item.nama] = (
          qty: (prod?.qty ?? 0) + item.qty,
          revenue: (prod?.revenue ?? 0) + item.total,
        );
        catMap[catId] = (
          qty: (existing?.qty ?? 0) + item.qty,
          revenue: (existing?.revenue ?? 0) + item.total,
          products: products,
        );
      }
    }

    if (catMap.isEmpty) return [];

    final sortedCats = catMap.entries.toList()
      ..sort((a, b) => b.value.revenue.compareTo(a.value.revenue));

    final widgets = <Widget>[];
    for (final catEntry in sortedCats) {
      final catName = categoryDisplayName[catEntry.key] ?? _capitalize(catEntry.key);
      widgets.add(_CategoryRow(
        name: catName,
        qty: catEntry.value.qty,
        revenue: catEntry.value.revenue,
      ));
      widgets.add(const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant));

      final sortedProducts = catEntry.value.products.entries.toList()
        ..sort((a, b) => b.value.revenue.compareTo(a.value.revenue));

      for (final prodEntry in sortedProducts) {
        widgets.add(_ProductRow(
          name: prodEntry.key,
          qty: prodEntry.value.qty,
          revenue: prodEntry.value.revenue,
        ));
        widgets.add(const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant));
      }
    }

    return widgets;
  }

  String _capitalize(String raw) => raw
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

class _ProdukHeader extends StatelessWidget {
  const _ProdukHeader({required this.totalQty, required this.totalRevenue});

  final int totalQty;
  final double totalRevenue;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.tertiary,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$totalQty',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  NumberFormat('#,###', 'id_ID').format(totalRevenue),
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.x3),
            OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('Fitur cetak belum tersedia'))),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white70),
                backgroundColor: Colors.white12,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x3,
                  vertical: AppSpacing.x2,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.print_rounded, size: 16),
              label: Text(
                'Cetak',
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.name,
    required this.qty,
    required this.revenue,
  });

  final String name;
  final int qty;
  final double revenue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: AppTypography.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$qty',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                NumberFormat('#,###', 'id_ID').format(revenue),
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.name,
    required this.qty,
    required this.revenue,
  });

  final String name;
  final int qty;
  final double revenue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: AppTypography.textTheme.bodyMedium,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$qty',
                style: AppTypography.textTheme.bodyMedium,
              ),
              Text(
                NumberFormat('#,###', 'id_ID').format(revenue),
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
