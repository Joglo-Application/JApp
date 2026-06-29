import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/supplier_item.dart';
import '../providers/supplier_provider.dart';
import '../widgets/navigation/supplier_drawer.dart';
import 'supplier_edit_stok_page.dart';
import 'supplier_tambah_stok_baru_page.dart';
import 'supplier_tambah_stok_gudang_page.dart';

// ── Page ─────────────────────────────────────────────────────────────────────

class SupplierMainPage extends StatelessWidget {
  const SupplierMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SupplierProvider()..load(),
      child: const _SupplierMainView(),
    );
  }
}

class _SupplierMainView extends StatelessWidget {
  const _SupplierMainView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SupplierDrawer(
        activePage: SupplierDrawerPage.gudangSupplier,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SupplierAppBar(),
          const _TableHeader(),
          const Expanded(child: _SupplierTable()),
          SafeArea(
            top: false,
            child: _TambahProdukButton(
              onTap: () => _showPilihDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showPilihDialog(BuildContext context) {
    final provider = context.read<SupplierProvider>();
    showDialog<void>(
      context: context,
      builder: (_) => _PilihDialog(provider: provider),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _SupplierAppBar extends StatelessWidget {
  const _SupplierAppBar();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        border: Border(
          bottom: BorderSide(color: AppColors.secondaryContainer),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x3,
          ),
          child: Row(
            children: [
              _HamburgerButton(),
              const SizedBox(width: AppSpacing.x3),
              Text(
                'Gudang / Supplier',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HamburgerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: () => Scaffold.of(context).openDrawer(),
        borderRadius: AppRadius.md,
        child: const SizedBox(
          width: 45,
          height: 45,
          child: Icon(Icons.menu_rounded, color: AppColors.onPrimary, size: 28),
        ),
      ),
    );
  }
}

// ── Table ─────────────────────────────────────────────────────────────────────

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
            const SizedBox(width: 48 + AppSpacing.x3),
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

class _SupplierTable extends StatelessWidget {
  const _SupplierTable();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Text(
          provider.error!,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.error,
          ),
        ),
      );
    }

    final items = provider.items;

    if (items.isEmpty) {
      return Center(
        child: Text(
          'Belum ada produk.',
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.outlineVariant,
      ),
      itemBuilder: (context, index) => _SupplierRow(
            item: items[index],
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                fullscreenDialog: true,
                builder: (_) => SupplierEditStokPage(
                  item: items[index],
                  provider: provider,
                ),
              ),
            ),
          ),
    );
  }
}

class _SupplierRow extends StatelessWidget {
  const _SupplierRow({required this.item, required this.onTap});

  final SupplierItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
    ),
    );
  }
}

class _ProductAvatar extends StatelessWidget {
  const _ProductAvatar({required this.item});

  final SupplierItem item;

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

  final SupplierItemStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == SupplierItemStatus.aman) return const SizedBox.shrink();

    final color = switch (status) {
      SupplierItemStatus.rendah => AppColors.error,
      SupplierItemStatus.habis => AppColors.onSurfaceVariant,
      SupplierItemStatus.aman => Colors.transparent,
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

// ── Tambah Produk button ──────────────────────────────────────────────────────

class _TambahProdukButton extends StatelessWidget {
  const _TambahProdukButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.tertiary,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: AppColors.onTertiary, size: 22),
              const SizedBox(width: AppSpacing.x2),
              Text(
                'Tambah Produk',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.onTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pilih dialog ──────────────────────────────────────────────────────────────

class _PilihDialog extends StatelessWidget {
  const _PilihDialog({required this.provider});

  final SupplierProvider provider;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: AppRadius.toShape(AppRadius.md),
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x4,
                AppSpacing.x4,
                AppSpacing.x2,
                AppSpacing.x4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pilih',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _PilihOption(
              label: 'Stok Baru',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (_) =>
                        SupplierTambahStokBaruPage(provider: provider),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            _PilihOption(
              label: 'Tambah Stok Gudang',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (_) =>
                        SupplierTambahStokGudangPage(provider: provider),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PilihOption extends StatelessWidget {
  const _PilihOption({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x4,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
