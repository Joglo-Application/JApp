import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/inventori_item.dart';
import '../../providers/inventori_provider.dart';

const _avatarLead = 44 + AppSpacing.x3; // lebar avatar + jarak

class InventoriTable extends StatelessWidget {
  const InventoriTable({super.key, this.onTapItem});

  final ValueChanged<InventoriItem>? onTapItem;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoriProvider>();

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
                    'Tidak ada data inventori.',
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
                  itemBuilder: (context, index) => _InventoriRow(
                    item: items[index],
                    onTap: onTapItem,
                  ),
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
            const SizedBox(width: _avatarLead),
            const Expanded(flex: 3, child: _HeaderCell(label: 'Nama')),
            const Expanded(flex: 2, child: _HeaderCell(label: 'Kategori')),
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

class _InventoriRow extends StatelessWidget {
  const _InventoriRow({required this.item, this.onTap});

  final InventoriItem item;
  final ValueChanged<InventoriItem>? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null ? null : () => onTap!(item),
      child: ColoredBox(
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

  final InventoriItem item;

  @override
  Widget build(BuildContext context) {
    // Gambar yang dipilih lokal (file valid) tetap ditampilkan. `imageUrl` dari
    // server dilewati karena belum ada backend gambar (sebagian menunjuk HTML,
    // memicu ImageCodecException) — pakai avatar inisial sebagai gantinya.
    if (item.localImagePath != null) {
      return ClipRRect(
        borderRadius: AppRadius.sm,
        child: Image.file(
          File(item.localImagePath!),
          width: 44,
          height: 44,
          fit: BoxFit.cover,
        ),
      );
    }
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

  final InventoriStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      InventoriStatus.aman => ('Tersedia', Colors.green.shade700),
      InventoriStatus.rendah => ('Rendah', Colors.orange.shade800),
      InventoriStatus.habis => ('Habis', AppColors.error),
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
