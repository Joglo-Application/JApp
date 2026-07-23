import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/kategori_stok_gudang.dart';
import '../providers/kategori_stok_gudang_provider.dart';
import '../widgets/navigation/supplier_drawer.dart';
import 'supplier_edit_kategori_stok_gudang_page.dart';

class SupplierKategoriStokGudangPage extends StatelessWidget {
  const SupplierKategoriStokGudangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KategoriStokGudangProvider()..load(),
      child: Scaffold(
        drawer: const SupplierDrawer(
          activePage: SupplierDrawerPage.kategoriStokGudang,
        ),
        body: const Column(
          children: [
            _AppBar(),
            Expanded(child: _KategoriList()),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _HamburgerButton(),
              const SizedBox(width: 12),
              Text(
                'Kategori Stok Gudang',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _TambahButton(onPressed: () => _openTambahDialog(context)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openTambahDialog(BuildContext context) async {
    final provider = context.read<KategoriStokGudangProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final nama = await showDialog<String>(
      context: context,
      builder: (_) => const _TambahKategoriDialog(),
    );
    if (nama == null || nama.trim().isEmpty) return;
    final ok = await provider.addKategori(nama.trim());
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Gagal menambah kategori')),
      );
    }
  }
}

class _KategoriList extends StatelessWidget {
  const _KategoriList();

  @override
  Widget build(BuildContext context) {
    final list = context.select<KategoriStokGudangProvider, List<KategoriStokGudang>>(
      (p) => p.list,
    );
    final isLoading = context.select<KategoriStokGudangProvider, bool>(
      (p) => p.isLoading,
    );
    final provider = context.read<KategoriStokGudangProvider>();

    if (isLoading && list.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 56,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.x3),
            Text(
              'Belum ada kategori',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x4,
            AppSpacing.x3,
            AppSpacing.x4,
            AppSpacing.x2,
          ),
          child: Text(
            '${list.length} kategori',
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x4,
              0,
              AppSpacing.x4,
              AppSpacing.x4,
            ),
            itemCount: list.length,
            onReorder: provider.reorderKategori,
            buildDefaultDragHandles: false,
            itemBuilder: (context, i) => _KategoriRow(
              key: ValueKey(list[i].id),
              index: i,
              kategori: list[i],
              onEdit: () => _openEditPage(context, provider, list[i]),
            ),
          ),
        ),
      ],
    );
  }

  void _openEditPage(
    BuildContext context,
    KategoriStokGudangProvider provider,
    KategoriStokGudang kategori,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SupplierEditKategoriStokGudangPage(
          kategori: kategori,
          provider: provider,
        ),
      ),
    );
  }
}

class _KategoriRow extends StatelessWidget {
  const _KategoriRow({
    super.key,
    required this.index,
    required this.kategori,
    required this.onEdit,
  });

  final int index;
  final KategoriStokGudang kategori;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final huruf =
        kategori.nama.isNotEmpty ? kategori.nama[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.x2),
      padding: const EdgeInsets.all(AppSpacing.x3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Icon(
              Icons.drag_handle_rounded,
              color: AppColors.onSurfaceVariant,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: AppRadius.sm,
            ),
            child: Text(
              huruf,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Text(
              kategori.nama,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          _ProdukBadge(count: kategori.produkCount),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, size: 20),
            color: AppColors.onSurfaceVariant,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _ProdukBadge extends StatelessWidget {
  const _ProdukBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
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
        '$count Produk',
        style: AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
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
      height: 40,
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

class _TambahKategoriDialog extends StatefulWidget {
  const _TambahKategoriDialog();

  @override
  State<_TambahKategoriDialog> createState() => _TambahKategoriDialogState();
}

class _TambahKategoriDialogState extends State<_TambahKategoriDialog> {
  late final TextEditingController _namaCtrl;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController();
    _namaCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _namaCtrl.text.trim().isNotEmpty;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
      content: TextField(
        controller: _namaCtrl,
        autofocus: true,
        style: AppTypography.textTheme.bodyMedium,
        decoration: const InputDecoration(labelText: 'Nama kategori'),
        onSubmitted: (_) {
          if (canConfirm) Navigator.of(context).pop(_namaCtrl.text);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
          child: const Text('BATAL'),
        ),
        TextButton(
          onPressed: canConfirm
              ? () => Navigator.of(context).pop(_namaCtrl.text)
              : null,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          child: const Text('KONFIRMASI'),
        ),
      ],
    );
  }
}

class _HamburgerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => Scaffold.of(context).openDrawer(),
        borderRadius: BorderRadius.circular(8),
        child: const SizedBox(
          width: 45,
          height: 45,
          child: Icon(Icons.menu_rounded, color: AppColors.onPrimary, size: 28),
        ),
      ),
    );
  }
}
