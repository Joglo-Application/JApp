import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/stok_gudang_item.dart';
import '../../providers/stok_gudang_provider.dart';

class StokGudangTable extends StatelessWidget {
  const StokGudangTable({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StokGudangProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Text(
          provider.error!,
          style: AppTypography.textTheme.bodyMedium
              ?.copyWith(color: AppColors.error),
        ),
      );
    }

    final items = provider.filtered;

    return Column(
      children: [
        const _TableHeader(),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada data stok gudang.',
                    style: AppTypography.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.outlineVariant,
                  ),
                  itemBuilder: (context, index) =>
                      _StokGudangRow(item: items[index]),
                ),
        ),
      ],
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.outline,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            const SizedBox(width: 48 + AppSpacing.x3), // avatar + gap
            Expanded(
              flex: 3,
              child: _HeaderCell(label: 'Nama'),
            ),
            Expanded(
              flex: 2,
              child: _HeaderCell(label: 'Unit Produk'),
            ),
            Expanded(
              child: _HeaderCell(label: 'Qty Stok', align: TextAlign.right),
            ),
            Expanded(
              child: _HeaderCell(label: 'Qty Tahan', align: TextAlign.right),
            ),
            const SizedBox(
              width: 64,
              child: _HeaderCell(label: 'Status', align: TextAlign.right),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label, this.align = TextAlign.left});

  final String label;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: align,
      style: AppTypography.textTheme.labelLarge?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ── Row ────────────────────────────────────────────────────────────────────────

class _StokGudangRow extends StatelessWidget {
  const _StokGudangRow({required this.item});

  final StokGudangItem item;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            _ProductAvatar(item: item),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              flex: 3,
              child: Text(
                item.nama,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                item.unitProduk,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${item.qtyStok}',
                textAlign: TextAlign.right,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${item.qtyTahan}',
                textAlign: TextAlign.right,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            SizedBox(
              width: 64,
              child: Align(
                alignment: Alignment.centerRight,
                child: _StatusIndicator(status: item.status),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductAvatar extends StatelessWidget {
  const _ProductAvatar({required this.item});

  final StokGudangItem item;

  @override
  Widget build(BuildContext context) {
    if (item.imageUrl != null) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(item.imageUrl!),
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.outline,
      child: Text(
        item.nama.isNotEmpty ? item.nama[0].toUpperCase() : '?',
        style: AppTypography.textTheme.titleMedium?.copyWith(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.status});

  final StokGudangStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == StokGudangStatus.aman) return const SizedBox.shrink();

    final color = switch (status) {
      StokGudangStatus.rendah => AppColors.error,
      StokGudangStatus.habis => AppColors.onSurfaceVariant,
      StokGudangStatus.aman => Colors.transparent,
    };

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
