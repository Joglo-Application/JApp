import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../owner/domain/entities/stok_gudang_item.dart';
import '../../../owner/presentation/providers/stok_gudang_provider.dart';

class InventoriPilihBahanPage extends StatelessWidget {
  const InventoriPilihBahanPage({super.key, this.alreadyAdded = const []});

  /// bahanId yang sudah dipakai di resep — ditampilkan nonaktif agar tak ganda.
  final List<int> alreadyAdded;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StokGudangProvider()..load(),
      child: _PilihBahanView(alreadyAdded: alreadyAdded),
    );
  }
}

class _PilihBahanView extends StatefulWidget {
  const _PilihBahanView({required this.alreadyAdded});

  final List<int> alreadyAdded;

  @override
  State<_PilihBahanView> createState() => _PilihBahanViewState();
}

class _PilihBahanViewState extends State<_PilihBahanView> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StokGudangProvider>();
    final items = provider.filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            _buildSearchBar(context),
            if (provider.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (provider.error != null)
              Expanded(
                child: Center(
                  child: Text(
                    provider.error!,
                    style: AppTypography.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.error),
                  ),
                ),
              )
            else if (items.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'Tidak ada bahan.',
                    style: AppTypography.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.x4),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.x2),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final sudah = widget.alreadyAdded.contains(item.bahanId);
                    // Bahan yang stoknya habis tak bisa dipakai di resep.
                    final habis = item.qtyStok <= 0;
                    return _BahanTile(
                      item: item,
                      sudahDipilih: sudah,
                      habis: habis,
                      onTap: (sudah || habis) ? null : () => context.pop(item),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.shellBackground),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x4,
            AppSpacing.x3,
            AppSpacing.x3,
            AppSpacing.x4,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.md,
                ),
                child: const Icon(Icons.warehouse_rounded,
                    color: AppColors.onPrimary, size: 22),
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Bahan',
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        color: AppColors.onSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Dari stok gudang untuk resep',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.pop<StokGudangItem>(null),
                icon: const Icon(Icons.close_rounded),
                color: AppColors.onSecondary,
                iconSize: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x4,
          AppSpacing.x3,
          AppSpacing.x4,
          AppSpacing.x3,
        ),
        child: TextField(
          controller: _searchCtrl,
          style: AppTypography.textTheme.bodyMedium,
          onChanged: (q) => context.read<StokGudangProvider>().search(q),
          decoration: InputDecoration(
            hintText: 'Cari bahan',
            hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.onSurfaceVariant, size: 22),
            filled: true,
            fillColor: AppColors.background,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x3,
              vertical: AppSpacing.x3,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _BahanTile extends StatelessWidget {
  const _BahanTile({
    required this.item,
    required this.sudahDipilih,
    required this.habis,
    required this.onTap,
  });

  final StokGudangItem item;
  final bool sudahDipilih;
  final bool habis;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final huruf = item.nama.isNotEmpty ? item.nama[0].toUpperCase() : '?';

    return Opacity(
      opacity: (sudahDipilih || habis) ? 0.55 : 1,
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.md,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.x3),
            decoration: BoxDecoration(
              borderRadius: AppRadius.md,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x1),
                      _StokChip(item: item),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.x2),
                if (sudahDipilih)
                  Text(
                    'Ditambahkan',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else if (habis)
                  Text(
                    'Stok habis',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  const Icon(Icons.add_circle_outline_rounded,
                      color: AppColors.primary, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StokChip extends StatelessWidget {
  const _StokChip({required this.item});

  final StokGudangItem item;

  @override
  Widget build(BuildContext context) {
    final color = switch (item.status) {
      StokGudangStatus.aman => Colors.green.shade700,
      StokGudangStatus.rendah => Colors.orange.shade800,
      StokGudangStatus.habis => AppColors.error,
    };
    final unit = item.unitProduk.isNotEmpty ? ' ${item.unitProduk}' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_rounded, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            'Stok ${item.qtyStok}$unit',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
