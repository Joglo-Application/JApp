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
  const InventoriPilihBahanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StokGudangProvider()..load(),
      child: const _PilihBahanView(),
    );
  }
}

class _PilihBahanView extends StatefulWidget {
  const _PilihBahanView();

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
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const Divider(
                height: 1, thickness: 1, color: AppColors.outlineVariant),
            _buildSearchBar(context),
            const Divider(
                height: 1, thickness: 1, color: AppColors.outlineVariant),
            if (provider.isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
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
            else
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.outlineVariant,
                  ),
                  itemBuilder: (context, index) =>
                      _BahanTile(item: items[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Stok Gudang',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          InkWell(
            onTap: () => context.pop<StokGudangItem>(null),
            borderRadius: AppRadius.full,
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.x1),
              child: Icon(Icons.close_rounded,
                  size: 24, color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: AppRadius.sm,
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.x3),
              child: Icon(Icons.search_rounded,
                  color: AppColors.onSurfaceVariant, size: 22),
            ),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari',
                  hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.x3,
                  ),
                ),
                onChanged: (q) =>
                    context.read<StokGudangProvider>().search(q),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BahanTile extends StatelessWidget {
  const _BahanTile({required this.item});
  final StokGudangItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pop(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x5,
        ),
        child: Text(
          item.nama,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}
