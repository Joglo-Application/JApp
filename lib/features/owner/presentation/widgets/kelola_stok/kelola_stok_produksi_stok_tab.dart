import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/produksi_stok_entry.dart';
import '../../pages/owner_produksi_stok_detail_page.dart';
import '../../pages/owner_tambahkan_produksi_stok_page.dart';
import '../../providers/kelola_stok_provider.dart';
import 'tambah_produksi_stok_dialog.dart';

class KelolaStokProduksiStokTab extends StatelessWidget {
  const KelolaStokProduksiStokTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _LeftPanel(),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(child: _RightPanel()),
      ],
    );
  }
}

class _LeftPanel extends StatelessWidget {
  const _LeftPanel();

  @override
  Widget build(BuildContext context) {
    final count = context.select<KelolaStokProvider, int>(
      (p) => p.produksiStokList.length,
    );

    return SizedBox(
      width: 280,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Produksi Stok',
              style: AppTypography.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.x1),
            Text(
              '$count Produksi Stok',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RightPanel extends StatefulWidget {
  @override
  State<_RightPanel> createState() => _RightPanelState();
}

class _RightPanelState extends State<_RightPanel> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(context),
        const Divider(height: 1),
        Expanded(child: _buildList(context)),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 22,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (q) => setState(() => _query = q),
              style: AppTypography.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Cari',
                hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.xs,
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.xs,
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.xs,
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x3,
                  vertical: AppSpacing.x2,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.sort_rounded),
            color: AppColors.onSurfaceVariant,
          ),
          const Spacer(),
          _CalendarIconButton(),
          const SizedBox(width: AppSpacing.x2),
          _TambahButton(
            onPressed: () => _navigateToTambah(context),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final list = context.select<KelolaStokProvider, List<ProduksiStokEntry>>(
      (p) => p.produksiStokList,
    );
    final provider = context.read<KelolaStokProvider>();

    final filtered = _query.isEmpty
        ? list
        : list
            .where((e) =>
                e.kode.toLowerCase().contains(_query.toLowerCase()) ||
                (e.catatan?.toLowerCase().contains(_query.toLowerCase()) ??
                    false))
            .toList();

    if (filtered.isEmpty) return const SizedBox.expand();

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (ctx, i) => _ProduksiStokListItem(
        entry: filtered[i],
        onTap: () => _onTapItem(ctx, filtered[i], provider),
      ),
    );
  }

  void _onTapItem(
    BuildContext ctx,
    ProduksiStokEntry entry,
    KelolaStokProvider provider,
  ) {
    if (entry.status == ProduksiStokStatus.draft) {
      Navigator.of(ctx).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => OwnerTambahkanProduksiStokPage(
            provider: provider,
            initialTanggal: entry.tanggal,
            initialCatatan: entry.catatan ?? '',
            existingEntry: entry,
          ),
        ),
      );
    } else {
      Navigator.of(ctx).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => OwnerProduksiStokDetailPage(entry: entry),
        ),
      );
    }
  }

  Future<void> _navigateToTambah(BuildContext context) async {
    final provider = context.read<KelolaStokProvider>();
    final navigator = Navigator.of(context);
    final result = await TambahProduksiStokDialog.show(context);
    if (result == null || !mounted) return;
    navigator.push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => OwnerTambahkanProduksiStokPage(
          provider: provider,
          initialTanggal: result.tanggal,
          initialCatatan: result.catatan,
        ),
      ),
    );
  }
}

// ── List item ─────────────────────────────────────────────────────────────────

class _ProduksiStokListItem extends StatelessWidget {
  const _ProduksiStokListItem({required this.entry, this.onTap});

  final ProduksiStokEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      '${entry.produk.length} Produk',
      if (entry.catatan != null && entry.catatan!.isNotEmpty) entry.catatan!,
    ].join('  -  ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.kode,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x1),
                  Text(
                    subtitle,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _StatusBadge(entry.status),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);

  final ProduksiStokStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ProduksiStokStatus.posted => ('Posted', AppColors.tertiary),
      ProduksiStokStatus.draft => ('Draft', Colors.orange),
      ProduksiStokStatus.cancelled => ('Cancelled', AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3,
        vertical: AppSpacing.x1,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: AppRadius.xs,
      ),
      child: Text(
        label,
        style: AppTypography.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Toolbar buttons ───────────────────────────────────────────────────────────

class _CalendarIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.sm,
      child: InkWell(
        onTap: () {},
        borderRadius: AppRadius.sm,
        child: const SizedBox(
          width: 45,
          height: 45,
          child: Icon(
            Icons.calendar_month_rounded,
            color: AppColors.onPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _TambahButton extends StatelessWidget {
  const _TambahButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
          textStyle: AppTypography.textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
        ),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Tambah'),
      ),
    );
  }
}
