import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/stok_gudang_item.dart';
import '../../providers/stok_gudang_provider.dart';

const _avatarLead = 44 + AppSpacing.x3; // lebar avatar + jarak

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
              : _GroupedList(items: items),
        ),
      ],
    );
  }
}

// ── Grouping per kategori ────────────────────────────────────────────────────

class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.items});

  final List<StokGudangItem> items;

  @override
  Widget build(BuildContext context) {
    // Kelompokkan berdasarkan kategori; bahan tanpa kategori masuk grup khusus.
    final groups = <String, List<StokGudangItem>>{};
    for (final it in items) {
      final key = it.kategori.trim().isEmpty ? 'Tanpa Kategori' : it.kategori.trim();
      (groups[key] ??= []).add(it);
    }
    final keys = groups.keys.toList()
      ..sort((a, b) {
        if (a == 'Tanpa Kategori') return 1;
        if (b == 'Tanpa Kategori') return -1;
        return a.toLowerCase().compareTo(b.toLowerCase());
      });

    // Ratakan jadi satu daftar: header grup lalu barisnya.
    final rows = <Widget>[];
    for (final k in keys) {
      final list = groups[k]!;
      rows.add(_GroupHeader(kategori: k, count: list.length));
      for (var i = 0; i < list.length; i++) {
        rows.add(_StokGudangRow(item: list[i]));
        if (i < list.length - 1) {
          rows.add(const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.outlineVariant,
          ));
        }
      }
    }

    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (_, i) => rows[i],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.kategori, required this.count});

  final String kategori;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x2,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.folder_rounded,
            size: 16,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.x2),
          Text(
            kategori,
            style: AppTypography.textTheme.labelLarge?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          Text(
            '($count)',
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
            const SizedBox(width: _avatarLead),
            const Expanded(flex: 3, child: _HeaderCell(label: 'Nama')),
            const Expanded(flex: 2, child: _HeaderCell(label: 'Kategori')),
            const Expanded(flex: 2, child: _HeaderCell(label: 'Unit Produk')),
            const Expanded(
              child: _HeaderCell(label: 'Qty Stok', align: TextAlign.right),
            ),
            const Expanded(
              child: _HeaderCell(label: 'Qty Tahan', align: TextAlign.right),
            ),
            const SizedBox(
              width: 72,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _KategoriChip(kategori: item.kategori),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                item.unitProduk,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${item.qtyStok}',
                textAlign: TextAlign.right,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${item.qtyTahan}',
                textAlign: TextAlign.right,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(
              width: 72,
              child: Align(
                alignment: Alignment.centerRight,
                child: _StatusChip(status: item.status),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KategoriChip extends StatelessWidget {
  const _KategoriChip({required this.kategori});

  final String kategori;

  @override
  Widget build(BuildContext context) {
    final kosong = kategori.trim().isEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: AppRadius.full,
      ),
      child: Text(
        kosong ? '—' : kategori,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w500,
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
    // Belum ada backend gambar, dan sebagian `imageUrl` menunjuk halaman HTML
    // (bukan gambar) sehingga Image.network melempar ImageCodecException.
    // Sementara selalu tampilkan avatar inisial.
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: AppRadius.sm,
      ),
      child: Text(
        item.nama.isNotEmpty ? item.nama[0].toUpperCase() : '?',
        style: AppTypography.textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final StokGudangStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      StokGudangStatus.aman => ('Tersedia', Colors.green.shade700),
      StokGudangStatus.rendah => ('Rendah', Colors.orange.shade800),
      StokGudangStatus.habis => ('Habis', AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.full,
      ),
      child: Text(
        label,
        style: AppTypography.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
