import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/produksi_stok_entry.dart';

class OwnerProduksiStokDetailPage extends StatelessWidget {
  const OwnerProduksiStokDetailPage({super.key, required this.entry});

  final ProduksiStokEntry entry;

  static String _formatTanggal(DateTime d) {
    const hari = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
    ];
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${hari[d.weekday - 1]}, ${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitleRow(context),
            _buildDocumentHeader(),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                children: [
                  ...entry.produk.map(
                    (item) => Column(
                      children: [
                        _ProdukDetailRow(item: item),
                        const Divider(height: 1),
                      ],
                    ),
                  ),
                  _buildDateRow(),
                  const Divider(height: 1),
                  _buildLabelValueRow('Created By', entry.createdBy),
                  const Divider(height: 1),
                  _buildSection('Catatan', entry.catatan ?? 'Catatan',
                      isPlaceholder: entry.catatan == null),
                  const Divider(height: 1),
                  _buildDownloadRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          const Spacer(),
          Text(
            'Stok Detail',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            iconSize: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentHeader() {
    final (bgColor, icon, statusLabel, statusColor) = switch (entry.status) {
      ProduksiStokStatus.posted => (
          AppColors.tertiary,
          Icons.check_rounded,
          'Posted',
          AppColors.tertiary,
        ),
      ProduksiStokStatus.draft => (
          Colors.orange,
          Icons.bookmark_rounded,
          'Draft',
          Colors.orange,
        ),
      ProduksiStokStatus.cancelled => (
          AppColors.error,
          Icons.close_rounded,
          'Cancelled',
          AppColors.error,
        ),
    };

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x4),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadius.sm,
            ),
            child: Icon(icon, color: AppColors.onPrimary, size: 26),
          ),
          const SizedBox(width: AppSpacing.x3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.kode,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                statusLabel,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 20,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.x3),
          Text(
            'Date',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            _formatTanggal(entry.tanggal),
            style: AppTypography.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLabelValueRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          Text(label, style: AppTypography.textTheme.bodyMedium),
          const Spacer(),
          Text(value, style: AppTypography.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildSection(String label, String value,
      {bool isPlaceholder = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          Text(
            value,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: isPlaceholder
                  ? AppColors.onSurfaceVariant
                  : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.download_rounded, size: 20),
          const SizedBox(width: AppSpacing.x2),
          Text('Download', style: AppTypography.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ProdukDetailRow extends StatelessWidget {
  const _ProdukDetailRow({required this.item});

  final ProduksiStokProdukItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: AppRadius.xs,
            ),
            child: const Icon(
              Icons.image_rounded,
              color: AppColors.onSurfaceVariant,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Row(
              children: [
                Text(item.nama, style: AppTypography.textTheme.bodyMedium),
                if (item.resep.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.x4),
                  Text(
                    'Resep  :  ${item.resep.join(', ')}',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          _QuantityBox(value: item.jumlah),
        ],
      ),
    );
  }
}

class _QuantityBox extends StatelessWidget {
  const _QuantityBox({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: AppRadius.xs,
      ),
      child: Text(
        '$value',
        style: AppTypography.textTheme.bodyMedium,
      ),
    );
  }
}
