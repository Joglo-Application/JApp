import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'owner_tambah_loyalty_diskon_page.dart';
import 'owner_tambah_loyalty_produk_gratis_page.dart';

enum _LoyaltyType { diskon, produkGratis }

class _LoyaltyItem {
  const _LoyaltyItem({
    required this.type,
    required this.title,
    required this.points,
  });

  final _LoyaltyType type;
  final String title;
  final int points;
}

class OwnerLoyaltyPointPage extends StatefulWidget {
  const OwnerLoyaltyPointPage({super.key});

  @override
  State<OwnerLoyaltyPointPage> createState() => _OwnerLoyaltyPointPageState();
}

class _OwnerLoyaltyPointPageState extends State<OwnerLoyaltyPointPage> {
  final List<_LoyaltyItem> _items = [
    const _LoyaltyItem(type: _LoyaltyType.diskon, title: 'Diskon IDR 25.000', points: 10),
    const _LoyaltyItem(type: _LoyaltyType.diskon, title: 'Diskon 50%', points: 10),
    const _LoyaltyItem(type: _LoyaltyType.produkGratis, title: 'Gratis 1 Pizza', points: 10),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
                vertical: AppSpacing.x4,
              ),
              child: Text(
                'Penukaran Point',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.x3),
                itemBuilder: (_, i) => _LoyaltyItemCard(
                  item: _items[i],
                  onEdit: () {},
                ),
              ),
            ),
            _TambahButton(onTap: _onTambah),
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
            'Loyalty Point',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          InkWell(
            onTap: () => context.pop(),
            borderRadius: AppRadius.full,
            child: const Icon(Icons.close_rounded, size: 24),
          ),
        ],
      ),
    );
  }

  Future<void> _onTambah() async {
    final type = await showDialog<_LoyaltyType>(
      context: context,
      builder: (_) => const _PilihJenisDialog(),
    );
    if (type == null || !mounted) return;

    switch (type) {
      case _LoyaltyType.diskon:
        final result = await context.push<LoyaltyDiskonResult>(
          AppRoutes.ownerTambahLoyaltyDiskon,
        );
        if (result != null && mounted) {
          setState(() {
            _items.add(_LoyaltyItem(
              type: _LoyaltyType.diskon,
              title: 'Diskon ${result.diskonDisplay}',
              points: result.points,
            ));
          });
        }
      case _LoyaltyType.produkGratis:
        final result = await context.push<LoyaltyProdukGratisResult>(
          AppRoutes.ownerTambahLoyaltyProdukGratis,
        );
        if (result != null && mounted) {
          setState(() {
            _items.add(_LoyaltyItem(
              type: _LoyaltyType.produkGratis,
              title: 'Gratis ${result.qty} ${result.productName}',
              points: result.points,
            ));
          });
        }
    }
  }
}

class _LoyaltyItemCard extends StatelessWidget {
  const _LoyaltyItemCard({required this.item, required this.onEdit});

  final _LoyaltyItem item;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: AppRadius.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            _LoyaltyIcon(type: item.type),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x1),
                  Text(
                    '${item.points} Poin',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onEdit,
              child: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoyaltyIcon extends StatelessWidget {
  const _LoyaltyIcon({required this.type});

  final _LoyaltyType type;

  @override
  Widget build(BuildContext context) {
    final isDiskon = type == _LoyaltyType.diskon;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDiskon ? AppColors.error : AppColors.tertiary,
        borderRadius: AppRadius.sm,
      ),
      child: Icon(
        isDiskon ? Icons.discount_rounded : Icons.card_giftcard_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}

class _TambahButton extends StatelessWidget {
  const _TambahButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x5),
        color: AppColors.tertiary,
        alignment: Alignment.center,
        child: Text(
          'Tambah',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.onTertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _PilihJenisDialog extends StatelessWidget {
  const _PilihJenisDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Pilih',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: AppRadius.full,
                  child: const Icon(Icons.close_rounded, size: 24),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x2),
            _DialogOption(
              icon: Icons.discount_rounded,
              iconColor: AppColors.error,
              label: 'Diskon',
              onTap: () => Navigator.of(context).pop(_LoyaltyType.diskon),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant),
            _DialogOption(
              icon: Icons.card_giftcard_rounded,
              iconColor: AppColors.tertiary,
              label: 'Produk Gratis',
              onTap: () => Navigator.of(context).pop(_LoyaltyType.produkGratis),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogOption extends StatelessWidget {
  const _DialogOption({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.sm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x2,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: AppRadius.sm,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Text(
                label,
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
