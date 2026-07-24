import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/log_transaksi_entry.dart';
import '../../providers/log_transaksi_provider.dart';
import 'laporan_date_panel.dart';

/// Visual style (label, warna, ikon) untuk sebuah tipe log.
typedef _TipeStyle = ({String label, Color color, IconData icon});

_TipeStyle _styleFor(String tipe) {
  switch (tipe.toUpperCase()) {
    case 'ADD_QTY':
    case 'ADD_ITEM':
      return (label: 'Tambah Item', color: AppColors.tertiary, icon: Icons.add_rounded);
    case 'VOID_ITEM':
    case 'REMOVE_ITEM':
      return (label: 'Void Item', color: AppColors.error, icon: Icons.remove_rounded);
    case 'PAYMENT':
    case 'BAYAR':
      return (label: 'Pembayaran', color: AppColors.primary, icon: Icons.payments_rounded);
    case 'RETURN':
    case 'RETUR':
    case 'REFUND':
      return (label: 'Retur', color: AppColors.warning, icon: Icons.undo_rounded);
    case 'DISCOUNT':
    case 'DISKON':
      return (label: 'Diskon', color: AppColors.primary, icon: Icons.local_offer_rounded);
    default:
      return (label: _humanize(tipe), color: AppColors.onSurfaceVariant, icon: Icons.receipt_long_rounded);
  }
}

String _humanize(String raw) => raw
    .split(RegExp(r'[_\s]+'))
    .where((w) => w.isNotEmpty)
    .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
    .join(' ');

class LaporanLogPanel extends StatelessWidget {
  const LaporanLogPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogTransaksiProvider>();
    // Terbaru di paling atas.
    final items = [...provider.filtered]
      ..sort((a, b) => b.waktu.compareTo(a.waktu));

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LogHeader(
            tipeFilter: provider.tipeFilter,
            count: items.length,
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.x4),
                        itemCount: items.length,
                        itemBuilder: (context, i) => Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                i == items.length - 1 ? 0 : AppSpacing.x3,
                          ),
                          child: _LogEntryTile(entry: items[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_toggle_off_rounded,
              size: 48, color: Colors.grey.shade400),
          const SizedBox(height: AppSpacing.x3),
          Text(
            'Tidak ada log transaksi',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header with filter ────────────────────────────────────────────────────────

class _LogHeader extends StatelessWidget {
  const _LogHeader({required this.tipeFilter, required this.count});

  final String? tipeFilter;
  final int count;

  @override
  Widget build(BuildContext context) {
    final label = tipeFilter == null ? 'Semua Tipe' : _styleFor(tipeFilter!).label;
    return SizedBox(
      height: LaporanDatePanel.headerHeight,
      child: ColoredBox(
        color: AppColors.tertiary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
          child: Row(
            children: [
              const Icon(Icons.receipt_long_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: AppSpacing.x2),
              Text(
                'Log Transaksi',
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppRadius.full,
                ),
                child: Text(
                  '$count',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              // Filter pill
              Material(
                color: Colors.white,
                borderRadius: AppRadius.sm,
                child: InkWell(
                  onTap: () => _showTipeFilter(context),
                  borderRadius: AppRadius.sm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x3, vertical: AppSpacing.x2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_list_rounded,
                            color: AppColors.onSurface, size: 18),
                        const SizedBox(width: AppSpacing.x2),
                        Text(
                          label,
                          style:
                              AppTypography.textTheme.labelMedium?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down_rounded,
                            color: AppColors.onSurfaceVariant, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTipeFilter(BuildContext context) {
    final provider = context.read<LogTransaksiProvider>();
    final types = provider.availableTipes.toList()..sort();
    if (types.isEmpty) return;

    showDialog<String?>(
      context: context,
      builder: (_) => _TipeFilterDialog(
        types: types,
        selected: provider.tipeFilter,
      ),
    ).then((picked) {
      if (picked == null) return;
      provider.setTipeFilter(picked.isEmpty ? null : picked);
    });
  }
}

class _TipeFilterDialog extends StatelessWidget {
  const _TipeFilterDialog({required this.types, required this.selected});

  final List<String> types;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    final options = [('', 'Semua Tipe'), ...types.map((t) => (t, _styleFor(t).label))];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.3,
        vertical: AppSpacing.x8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColoredBox(
            color: AppColors.tertiary,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
                vertical: AppSpacing.x3,
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_list_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: AppSpacing.x3),
                  Expanded(
                    child: Text(
                      'Filter Tipe Log',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: ColoredBox(
              color: AppColors.surface,
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: options.length,
                separatorBuilder: (_, _) => const Divider(
                    height: 1, thickness: 1, color: AppColors.outlineVariant),
                itemBuilder: (context, i) {
                  final opt = options[i];
                  final isSelected = (opt.$1 == '') == (selected == null) ||
                      opt.$1 == selected;
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(opt.$1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x4,
                        vertical: AppSpacing.x4,
                      ),
                      child: Row(
                        children: [
                          if (opt.$1.isNotEmpty) ...[
                            Icon(_styleFor(opt.$1).icon,
                                size: 18, color: _styleFor(opt.$1).color),
                            const SizedBox(width: AppSpacing.x3),
                          ],
                          Expanded(
                            child: Text(
                              opt.$2,
                              style: AppTypography.textTheme.bodyMedium,
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_rounded,
                                size: 18, color: AppColors.tertiary),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Log entry tile ────────────────────────────────────────────────────────────

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({required this.entry});

  final LogTransaksiEntry entry;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(entry.tipe);
    final dt = entry.waktu;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(AppSpacing.x3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type avatar
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: style.color.withValues(alpha: 0.12),
              borderRadius: AppRadius.sm,
            ),
            child: Icon(style.icon, size: 20, color: style.color),
          ),
          const SizedBox(width: AppSpacing.x3),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: style.color.withValues(alpha: 0.12),
                        borderRadius: AppRadius.full,
                      ),
                      child: Text(
                        style.label,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: style.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    Flexible(
                      child: Text(
                        entry.kodeTransaksi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x2),
                Text(
                  entry.deskripsi,
                  style: AppTypography.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.x1),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 13, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      entry.namaKasir,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          // Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('HH:mm').format(dt),
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${dt.day} ${_months[dt.month - 1]} ${dt.year}',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
