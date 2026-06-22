import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/stok_masuk_entry.dart';

class OwnerStokMasukDetailPage extends StatelessWidget {
  const OwnerStokMasukDetailPage({super.key, required this.entry});

  final StokMasukEntry entry;

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
                  _buildDateRow(),
                  const Divider(height: 1),
                  _buildLabelValueRow('Created By', entry.createdBy),
                  const Divider(height: 1),
                  _buildSection('Supplier', entry.supplier ?? 'Nama Supplier',
                      isPlaceholder: entry.supplier == null),
                  const Divider(height: 1),
                  _buildSection('Catatan', entry.catatan ?? 'Catatan',
                      isPlaceholder: entry.catatan == null),
                  const Divider(height: 1),
                  ...entry.produk.map(
                    (item) => Column(
                      children: [
                        _ProdukDetailRow(item: item),
                        const Divider(height: 1),
                      ],
                    ),
                  ),
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
      StokMasukStatus.posted => (
          AppColors.tertiary,
          Icons.check_rounded,
          'Posted',
          AppColors.tertiary,
        ),
      StokMasukStatus.draft => (
          Colors.orange,
          Icons.bookmark_rounded,
          'Draft',
          Colors.orange,
        ),
      StokMasukStatus.cancelled => (
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
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: AppRadius.xs,
            ),
            child: const Icon(
              Icons.download_rounded,
              color: AppColors.onPrimary,
              size: 20,
            ),
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
}

class _ProdukDetailRow extends StatelessWidget {
  const _ProdukDetailRow({required this.item});

  final StokMasukProdukItem item;

  @override
  Widget build(BuildContext context) {
    final isInventori = item.source == ProdukSource.inventori;
    final iconColor = isInventori ? Colors.deepOrange : AppColors.primary;
    final icon =
        isInventori ? Icons.inventory_2_rounded : Icons.groups_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Text(
              item.nama,
              style: AppTypography.textTheme.bodyMedium,
            ),
          ),
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
