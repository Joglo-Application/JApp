import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// "Notifikasi" settings — currently just the Email channel list. Each row
/// is a placeholder for future per-notification configuration; the
/// trailing chevron has no expand behavior yet.
class OwnerPengaturanNotifikasiPage extends StatelessWidget {
  const OwnerPengaturanNotifikasiPage({super.key});

  static const _emailItems = [
    _NotifikasiItem(label: 'Konfirmasi Pesanan', color: Colors.blue),
    _NotifikasiItem(label: 'Notifikasi Pesanan Baru', color: Colors.blue),
    _NotifikasiItem(label: 'Pembatalan Pesanan', color: AppColors.error),
    _NotifikasiItem(label: 'Notifikasi Pengembalian', color: AppColors.error),
    _NotifikasiItem(label: 'Notifikasi Pembayaran', color: Colors.orange),
    _NotifikasiItem(
      label: 'Notifikasi Terima Pembayaran',
      color: Colors.orange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.outlineVariant,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.x4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Email',
                      textAlign: TextAlign.center,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    for (var i = 0; i < _emailItems.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.x3),
                      _NotifikasiRow(item: _emailItems[i]),
                    ],
                  ],
                ),
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
            'Notifikasi',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          InkWell(
            onTap: () => context.pop(),
            borderRadius: AppRadius.full,
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifikasiItem {
  const _NotifikasiItem({required this.label, required this.color});

  final String label;
  final Color color;
}

class _NotifikasiRow extends StatelessWidget {
  const _NotifikasiRow({required this.item});

  final _NotifikasiItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: AppRadius.md,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: AppRadius.sm,
            ),
            child: const Icon(
              Icons.mail_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Text(
              item.label,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.onSurfaceVariant,
            size: 24,
          ),
        ],
      ),
    );
  }
}
