import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/router/app_routes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';

class TransaksiSectionList extends StatelessWidget {
  const TransaksiSectionList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _TransaksiNavSection(
          title: 'Transaksi',
          onTap: () => context.push(AppRoutes.ownerTransaksiList),
        ),
        _TransaksiNavSection(
          title: 'Diskon & Voucher',
          onTap: () => context.push(AppRoutes.ownerDiskonVoucher),
        ),
        _TransaksiNavSection(
          title: 'Loyalty Point',
          onTap: () => context.push(AppRoutes.ownerLoyaltyPoint),
        ),
        _TransaksiNavSection(
          title: 'Metode Pembayaran',
          onTap: () => context.push(AppRoutes.ownerMetodePembayaran),
        ),
      ],
    );
  }
}

class _TransaksiNavSection extends StatelessWidget {
  const _TransaksiNavSection({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x8,
          vertical: AppSpacing.x2,
        ),
        tileColor: AppColors.surface,
        title: Text(
          title,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.onSurface),
        onTap: onTap,
      ),
    );
  }
}

