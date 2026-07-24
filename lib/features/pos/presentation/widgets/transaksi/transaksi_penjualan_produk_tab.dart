import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../providers/menu_provider.dart';
import '../../providers/transaksi_provider.dart';
import '../laporan/laporan_date_panel.dart';

typedef _ProductStat = ({String name, int qty, double revenue});
typedef _CategoryStat = ({
  String name,
  int qty,
  double revenue,
  List<_ProductStat> products,
});

String _rp(num v) => 'Rp ${NumberFormat('#,###', 'id_ID').format(v)}';

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
            color: AppColors.background,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProdukHeader(
          totalQty: provider.totalItemQty,
          totalRevenue: provider.totalPenjualan,
        ),
        Expanded(
          child: grouped.isEmpty
              ? _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.x4),
                  itemCount: grouped.length,
                  itemBuilder: (context, i) => Padding(
                    padding: EdgeInsets.only(
                      bottom: i == grouped.length - 1 ? 0 : AppSpacing.x3,
                    ),
                    child: _CategoryCard(cat: grouped[i]),
                  ),
                ),
        ),
      ],
    );
  }

  List<_CategoryStat> _buildGrouped(
    TransaksiProvider provider,
    MenuProvider menuProvider,
  ) {
    // product name (lower) → category id
    final nameToCategory = <String, String>{};
    final categoryDisplayName = <String, String>{};
    for (final p in menuProvider.allProducts) {
      nameToCategory[p.name.toLowerCase()] = p.categoryId;
    }
    for (final cat in menuProvider.categories) {
      categoryDisplayName[cat.id] = cat.name;
    }

    final catMap = <String,
        ({
          int qty,
          double revenue,
          Map<String, ({int qty, double revenue})> products
        })>{};

    for (final t in provider.all.where((t) => !t.isReturned)) {
      for (final item in t.items) {
        final catId = nameToCategory[item.nama.toLowerCase()] ?? 'lainnya';
        final existing = catMap[catId];
        final products =
            Map<String, ({int qty, double revenue})>.from(existing?.products ?? {});
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

    if (catMap.isEmpty) return const [];

    final sortedCats = catMap.entries.toList()
      ..sort((a, b) => b.value.revenue.compareTo(a.value.revenue));

    return [
      for (final catEntry in sortedCats)
        (
          name: categoryDisplayName[catEntry.key] ?? _capitalize(catEntry.key),
          qty: catEntry.value.qty,
          revenue: catEntry.value.revenue,
          products: (catEntry.value.products.entries.toList()
                ..sort((a, b) => b.value.revenue.compareTo(a.value.revenue)))
              .map((e) =>
                  (name: e.key, qty: e.value.qty, revenue: e.value.revenue))
              .toList(),
        ),
    ];
  }

  String _capitalize(String raw) => raw
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 48, color: Colors.grey.shade400),
          const SizedBox(height: AppSpacing.x3),
          Text(
            'Tidak ada data penjualan',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProdukHeader extends StatelessWidget {
  const _ProdukHeader({required this.totalQty, required this.totalRevenue});

  final int totalQty;
  final double totalRevenue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: LaporanDatePanel.headerHeight,
      child: ColoredBox(
        color: AppColors.tertiary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
          child: Row(
            children: [
              _HeaderStat(
                icon: Icons.shopping_bag_rounded,
                label: 'Item Terjual',
                value: '$totalQty',
              ),
              const SizedBox(width: AppSpacing.x6),
              _HeaderStat(
                icon: Icons.payments_rounded,
                label: 'Pendapatan',
                value: _rp(totalRevenue),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(
                      content: Text('Fitur cetak belum tersedia'))),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.onSurface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x4,
                    vertical: AppSpacing.x2,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
                ),
                icon: const Icon(Icons.print_rounded, size: 16),
                label: Text(
                  'Cetak',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: AppSpacing.x2),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: Colors.white70,
              ),
            ),
            Text(
              value,
              style: AppTypography.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.cat});

  final _CategoryStat cat;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Category header
          Container(
            color: AppColors.tertiaryContainer,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x3,
            ),
            child: Row(
              children: [
                Icon(Icons.category_rounded,
                    size: 18, color: AppColors.onTertiaryContainer),
                const SizedBox(width: AppSpacing.x2),
                Expanded(
                  child: Text(
                    cat.name,
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: AppColors.onTertiaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _QtyRevenue(
                  qty: cat.qty,
                  revenue: cat.revenue,
                  color: AppColors.onTertiaryContainer,
                  bold: true,
                ),
              ],
            ),
          ),
          // Products
          for (var i = 0; i < cat.products.length; i++) ...[
            if (i > 0)
              const Divider(
                  height: 1, thickness: 1, color: AppColors.outlineVariant),
            _ProductRow(product: cat.products[i]),
          ],
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product});

  final _ProductStat product;

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
              product.name,
              style: AppTypography.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          _QtyRevenue(qty: product.qty, revenue: product.revenue),
        ],
      ),
    );
  }
}

/// Aligned qty chip + revenue text used on both category & product rows.
class _QtyRevenue extends StatelessWidget {
  const _QtyRevenue({
    required this.qty,
    required this.revenue,
    this.color,
    this.bold = false,
  });

  final int qty;
  final double revenue;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 34),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: (bold ? c : AppColors.tertiary).withValues(alpha: 0.12),
            borderRadius: AppRadius.full,
          ),
          child: Text(
            '$qty',
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: bold ? c : AppColors.onTertiaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.x3),
        SizedBox(
          width: 110,
          child: Text(
            _rp(revenue),
            textAlign: TextAlign.right,
            style: (bold
                    ? AppTypography.textTheme.titleSmall
                    : AppTypography.textTheme.bodyMedium)
                ?.copyWith(
              color: c,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
