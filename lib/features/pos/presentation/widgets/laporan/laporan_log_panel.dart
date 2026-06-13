import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/log_transaksi_entry.dart';
import '../../providers/log_transaksi_provider.dart';

class LaporanLogPanel extends StatelessWidget {
  const LaporanLogPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogTransaksiProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LogHeader(
          tipeFilter: provider.tipeFilter,
          availableTipes: provider.availableTipes,
        ),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada log transaksi',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: provider.filtered.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.outlineVariant,
                      ),
                      itemBuilder: (context, i) =>
                          _LogEntryTile(entry: provider.filtered[i]),
                    ),
        ),
      ],
    );
  }
}

// ── Header with filter ────────────────────────────────────────────────────────

class _LogHeader extends StatelessWidget {
  const _LogHeader({
    required this.tipeFilter,
    required this.availableTipes,
  });

  final String? tipeFilter;
  final Set<String> availableTipes;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.tertiary,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _showTipeFilter(context),
              child: const Icon(
                Icons.swap_vert_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: GestureDetector(
                onTap: () => _showTipeFilter(context),
                child: Text(
                  tipeFilter ?? 'Tipe Log Transaksi',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
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
    final options = [('', 'Semua Tipe'), ...types.map((t) => (t, t))];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.3,
        vertical: AppSpacing.x8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
                        'Tipe Log',
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
            ColoredBox(
              color: AppColors.surface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < options.length; i++) ...[
                    if (i > 0)
                      const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.outlineVariant),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(options[i].$1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x4,
                          vertical: AppSpacing.x4,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                options[i].$2,
                                style: AppTypography.textTheme.bodyMedium,
                              ),
                            ),
                            if ((options[i].$1 == '') == (selected == null) ||
                                options[i].$1 == selected)
                              const Icon(Icons.check_rounded,
                                  size: 18, color: AppColors.tertiary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Log entry tile ────────────────────────────────────────────────────────────

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({required this.entry});

  final LogTransaksiEntry entry;

  static const _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatWaktu(DateTime dt) {
    final day = _days[dt.weekday - 1];
    final month = _months[dt.month - 1];
    final time = DateFormat('HH:mm').format(dt);
    return '$day, ${dt.day} $month ${dt.year} $time';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.tipe,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.kodeTransaksi} - ${entry.namaKasir}',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.deskripsi,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          Text(
            _formatWaktu(entry.waktu),
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
