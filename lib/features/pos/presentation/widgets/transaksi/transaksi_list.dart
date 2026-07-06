import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/utils/currency_formatter.dart';
import '../../../../../../core/widgets/empty_state_widget.dart';
import '../../../domain/entities/transaksi.dart';
import '../../providers/transaksi_provider.dart';

class TransaksiList extends StatelessWidget {
  const TransaksiList({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<TransaksiProvider, bool>((p) => p.isLoading);
    final error = context.select<TransaksiProvider, String?>((p) => p.error);
    final items = context.select<TransaksiProvider, List<Transaksi>>(
      (p) => p.filtered,
    );

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return EmptyStateWidget(
        message: error,
        icon: Icons.wifi_off_rounded,
        actionLabel: 'Coba Lagi',
        onAction: () => context.read<TransaksiProvider>().load(),
      );
    }

    if (items.isEmpty) {
      final searchQuery = context.select<TransaksiProvider, String>(
        (p) => p.searchQuery.trim(),
      );
      if (searchQuery.isNotEmpty) {
        return EmptyStateWidget(
          message: 'Transaksi dengan kode "$searchQuery" tidak ditemukan',
          icon: Icons.search_off_rounded,
        );
      }
      return const EmptyStateWidget(
        message: 'Tidak ada transaksi pada hari ini',
        icon: Icons.receipt_long_rounded,
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, i) => const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.outlineVariant,
      ),
      itemBuilder: (_, i) {
        final trx = items[i];
        return _TransaksiTile(trx: trx);
      },
    );
  }
}

class _TransaksiTile extends StatelessWidget {
  const _TransaksiTile({required this.trx});

  final Transaksi trx;

  static const _timeMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String get _timeLabel {
    final h = trx.waktu.hour.toString().padLeft(2, '0');
    final m = trx.waktu.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get _dateLabel {
    final d = trx.waktu.day;
    final mo = _timeMonths[trx.waktu.month - 1];
    return '$d $mo';
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = context.select<TransaksiProvider, bool>(
      (p) => p.selected == trx,
    );
    return InkWell(
      onTap: () => context.read<TransaksiProvider>().select(
            isSelected ? null : trx,
          ),
      child: ColoredBox(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x3,
          ),
          child: Row(
            children: [
              _TrxIcon(isReturned: trx.isReturned),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trx.kode,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: trx.isReturned ? AppColors.error : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trx.itemLabels.join(', '),
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: trx.isReturned
                            ? AppColors.error
                            : AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _paymentLabel,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: trx.isReturned
                            ? AppColors.error
                            : AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _timeLabel,
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _dateLabel,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _paymentLabel {
    final nominal = CurrencyFormatter.format(trx.nominalPembayaran);
    final contact = trx.namaKontak.isNotEmpty ? ' · ${trx.namaKontak}' : '';
    return '$nominal - ${trx.tipePembayaran}$contact';
  }
}

class _TrxIcon extends StatelessWidget {
  const _TrxIcon({required this.isReturned});

  final bool isReturned;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isReturned ? AppColors.errorContainer : AppColors.tertiaryContainer,
        borderRadius: AppRadius.md,
      ),
      child: Center(
        child: isReturned
            ? Icon(Icons.currency_exchange_rounded,
                color: AppColors.error, size: 22)
            : const Text('💵', style: TextStyle(fontSize: 22)),
      ),
    );
  }
}
